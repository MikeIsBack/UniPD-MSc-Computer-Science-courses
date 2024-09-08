import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:room_finder/data/ad_data.dart';
import 'package:room_finder/model/ad_model.dart';
import 'package:room_finder/model/user_model.dart';
import 'package:room_finder/provider/firebase_providers.dart';

/// List of fields for users' documents
const String _isHostField = 'isHost';
const String _savedAdsField = 'savedAds';
const String _userCollectionName = 'users';
const String _photoUserRef = "photos/users";

/// This class allow to handle the 'users' collection in Firestore
///
/// [_userCollection] refers to corresponding collection in Firestore
///
/// [_usersRef] refers to path on Storage for uploading profile picture
class UserDataSource {
  final CollectionReference _userCollection;
  final Reference _usersRef;
  final Ref _ref;

  UserDataSource(this._ref, this._userCollection, this._usersRef);

  /// The method [getUser] returns an individual user passing as parameter its unique identifier [userUid]
  Future<Either<String, UserData>> getUser({required String userUid}) async {
    try {
      final docSnap = await _userCollection.doc(userUid).get();
      List<String> savedAds = List<String>.from(docSnap[_savedAdsField] ?? []);

      return right(UserData(isHost: docSnap[_isHostField], savedAds: savedAds));
    } on FirebaseException catch (e) {
      return left(e.message ?? "Failed to get the user data");
    }
  }

  /// This method set a new document with [newUserUid] id and set the fiels 'isHost' with [isHost] value
  Future<void> addNewUser(
      {required String newUserUid, required bool isHost}) async {
    final docData = {
      _isHostField: isHost,
      _savedAdsField: []
    };
    await _userCollection.doc(newUserUid).set(docData);
  }

  /// The method [updatePhoto] allows to update the user profile photo passing as parameters:
  /// - [imageFile], the new image to upload
  /// - [imageName], the name of the new image
  Future<Either<String, String>> updatePhoto(
      {required File imageFile, required String imageName}) async {
    try {
      // if (image != null )
      // var imageFile = File(image.path);
      final imageRef = _usersRef.child("$imageName.jpg");
      final uploadTask = await imageRef.putFile(imageFile);
      final response = await uploadTask.ref.getDownloadURL();

      return right(response);
    } on FirebaseException catch (e) {
      return left(e.message ?? "Failed to upload the photo");
    }
  }

  /// The method [saveAd] allows to save an ad of interest by passing the parameters:
  /// - [adUid], the ad uid
  /// - [userUid], the id of the user who want to save the ad
  Future<Either<String, void>> saveAd(
      {required String adUid, required String userUid}) async {
    try {
      final userDocRef = _userCollection.doc(userUid);

      await userDocRef.update({
        _savedAdsField: FieldValue.arrayUnion([adUid]),
      });

      return right(null);
    } on FirebaseException catch (e) {
      return left(e.message ?? "Failed to save the ad");
    }
  }

  /// The method [removeSavedAd] allows to remove a saved ad by passing the parameters:
  /// - [adUid], the ad uid
  /// - [userUid], the id of the user who want to save the ad
  Future<Either<String, void>> removeSavedAd(
      {required String adUid, required String userUid}) async {
    try {
      final userDocRef = _userCollection.doc(userUid);

      await userDocRef.update({
        _savedAdsField: FieldValue.arrayRemove([adUid]),
      });

      return right(null);
    } on FirebaseException catch (e) {
      return left(e.message ?? "Failed to remove the saved ad");
    }
  }

  /// The method [isAdSaved] checks if an ad has been saved by the current user by passing the parameters:
  /// - [adUid], the ad uid
  /// - [userUid], the id of the user who want to save the ad
  Future<Either<String, bool>> isAdSaved(
      {required String adUid, required String userUid}) async {
    try {
      final userDocRef = _userCollection.doc(userUid);
      final docSnap = await userDocRef.get();

      // Retrieve the user savedAds list
      List<String> savedAds = List<String>.from(docSnap[_savedAdsField] ?? []);

      // Check if the adUid exists in the savedAds list
      bool isAdSaved = savedAds.contains(adUid);
      return right(isAdSaved);
    } on FirebaseException catch (e) {
      return left(e.message ?? "Failed to save the ad");
    }
  }

  /// The method [getSavedAds] allows to retrieve the list of all the user's saved ads by passing as parameter the list of user saved ads uids
  Future<Either<String, List<AdData?>>> getSavedAds(
      {required List<String> savedAds}) async {
    if (savedAds.isEmpty) {
      return right([]); // Return an empty list if there are no ads
    }

    try {
      final List<AdData?> adsList = [];

      for (String adUid in savedAds) {
        final adResult = await _ref
            .read(adDataSourceProvider)
            .getAd(adUid: adUid, isHost: false);
        adResult.fold(
          (failure) => null,
          (adData) => adsList.add(adData),
        );
      }

      return right(adsList);
    } on FirebaseException catch (e) {
      return left(e.message ?? "Failed to retrieve saved ads");
    }
  }
}

final userDataSourceProvider = Provider<UserDataSource>((ref) => UserDataSource(
    ref,
    ref.read(firebaseFirestoreProvider).collection(_userCollectionName),
    ref.read(firebaseStorageProvider).ref().child(_photoUserRef)));
