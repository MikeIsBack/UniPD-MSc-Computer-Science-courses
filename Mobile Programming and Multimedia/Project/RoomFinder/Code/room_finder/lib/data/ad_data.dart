import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:room_finder/model/ad_model.dart';
import 'package:room_finder/provider/firebase_providers.dart';

/// List of fields for ads' documents
const String _hostUidField = 'hostUid';
const String _hostNameField = "hostName";
const String _hostPhotoURLField = "hostPhotoURL";
const String _nameField = 'name';
const String _rentersCapacityField = 'rentersCapacity';
const String _monthlyRentField = 'monthlyRent';
const String _servicesField = 'services';
const String _addressSubcollectionName = 'address';
const String _roomsSubcollectionName = 'rooms';
const String _rentersSubcollectionName = 'renters';
const String _adsCollectionName = 'ads';
const String _photosAdsRef = "photos/ads";

const String _roomName = "name";
const String _roomQuantity = "quantity";
const String _numBeds = "numBeds";
/// This class allow to handle the ads collection in Firestore
///
/// [_adCollection] refers to corresponding collection in Firestore
///
/// [_adRef] refers to path on Storage to access ad photos
class AdDataSource {
  final CollectionReference _adCollection;
  final Reference _adRef;

  AdDataSource(this._adCollection, this._adRef);

  /// The method [getAd] returns an individual ad passing as parameter its unique identifier [adUid]
  Future<Either<String, AdData?>> getAd(
      {required String adUid, required bool isHost}) async {
    try {
      final docSnap = await _adCollection.doc(adUid).get();

      // Fetch renters subcollection
      final rentersSnap =
          await docSnap.reference.collection(_rentersSubcollectionName).get();
      final List<Renter> renters = rentersSnap.docs.map((renterDoc) {
        final renterData = renterDoc.data();
        return Renter(
          name: renterData['name'],
          age: renterData['age'],
          facultyOfStudies: renterData['facultyOfStudies'],
          interests: renterData['interests'],
          contractDeadline: DateTime.parse(renterData['contractDeadline']),
        );
      }).toList();

      final rentersCapacity = docSnap.get(_rentersCapacityField);

      // If the user is a student and the facility has reached its maximum capacity don't return it
      if (!isHost && renters.length == rentersCapacity) {
        return right(null);
      }

      // Fetch address subcollection
      final addressSnap =
          await docSnap.reference.collection(_addressSubcollectionName).get();
      final address = Address(
        street: addressSnap.docs.first['street'],
        city: addressSnap.docs.first['city'],
      );

      // Fetch rooms subcollection
      final roomsSnap =
          await docSnap.reference.collection(_roomsSubcollectionName).get();
      final List<Room> rooms = roomsSnap.docs.map((roomDoc) {
        final roomData = roomDoc.data();
        if (roomData.containsKey('numBeds')) {
          return Bedroom(
            name: roomData['name'],
            quantity: roomData['quantity'],
            numBeds: List<int>.from(roomData['numBeds']),
          );
        } else {
          return Room(
            name: roomData['name'],
            quantity: roomData['quantity'],
          );
        }
      }).toList();

      // Fetch services field
      final services = List<String>.from(docSnap[_servicesField] ?? []);

      // Fetch photos from Firebase Storage
      final adPhotos = await _adRef.child(adUid).listAll();
      final List<String> adPhotosURLs = await Future.wait(
          adPhotos.items.map((item) => item.getDownloadURL()));

      // Return the populated AdData object
      return right(AdData(
        uid: adUid,
        hostUid: docSnap[_hostUidField],
        hostName: docSnap[_hostNameField],
        hostPhotoURL: docSnap[_hostPhotoURLField],
        name: docSnap[_nameField],
        address: address,
        rooms: rooms,
        rentersCapacity: docSnap[_rentersCapacityField],
        renters: renters,
        services: services,
        monthlyRent: docSnap[_monthlyRentField],
        photosURLs: adPhotosURLs,
      ));
    } on FirebaseException catch (e) {
      return left(e.message ?? "Failed to get the ad data");
    }
  }

  /// The method [addNewAd] allows to add a new ad that respects the passed parameters
  Future<Either<String, void>> addNewAd(
      {required AdData newAd,
      required List<File> photosPaths}) async {
    try {
      // 1. Add standard fields
      DocumentReference adDocRef = await _adCollection.add({
        _hostUidField: newAd.hostUid,
        _hostNameField: newAd.hostName,
        _hostPhotoURLField: newAd.hostPhotoURL,
        _nameField: newAd.name,
        _rentersCapacityField: newAd.rentersCapacity,
        _monthlyRentField: newAd.monthlyRent,
        _servicesField: newAd.services,
      });

      // 2. Add sub-collections
      await adDocRef.collection(_addressSubcollectionName).add({
        'street': newAd.address.street,
        'city': newAd.address.city,
      });

      for (Room room in newAd.rooms) {
        final roomData = {
          _roomName: room.name,
          _roomQuantity: room.quantity,
        };

        // If the room is a Bedroom add the [numBeds] parameter
        if (room is Bedroom) {
          roomData[_numBeds] = room.numBeds;
        }

        await adDocRef.collection(_roomsSubcollectionName).add(roomData);
      }

      for (Renter renter in newAd.renters) {
        await adDocRef.collection(_rentersSubcollectionName).add({
          'name': renter.name,
          'age': renter.age,
          'facultyOfStudies': renter.facultyOfStudies,
          'interests': renter.interests,
          'contractDeadline': renter.contractDeadline.toIso8601String(),
        });
      }

      // 3. Upload photos to Firebase Storage
      for (File photo in photosPaths) {
        final imageData = await photo.readAsBytes();
        String photoName = photo.uri.pathSegments.last; // Get the file name
        Reference photoRef = _adRef
            .child(adDocRef.id)
            .child(photoName); // Append the photo under [adDocRef.id] folder

        await photoRef.putData(imageData);
        // await photoRef.putFile(photo);
      }

      return right(null);
    } on FirebaseException catch (e) {
      return left(e.message ?? 'Failed to add new ad');
    }
  }

  /// The method [deleteAd] allows to delete an ad passing as parameter its unique identifier [adUid]
  Future<Either<String, void>> deleteAd({required String adUid}) async {
    try {
      // 1. Delete photos from Firebase Storage
      final adPhotosRef = _adRef.child(adUid);
      final adPhotos = await adPhotosRef.listAll();
      for (final item in adPhotos.items) {
        await item.delete();
      }

      // 2. Delete subcollections
      final adDocRef = _adCollection.doc(adUid);

      final subcollections = [
        _addressSubcollectionName,
        _roomsSubcollectionName,
        _rentersSubcollectionName,
      ];

      // Delete all subcollections and each document inside
      for (final subcollection in subcollections) {
        final snapshot = await adDocRef.collection(subcollection).get();
        for (final doc in snapshot.docs) {
          await doc.reference.delete();
        }
      }

      // 3. Delete the ad document
      await adDocRef.delete();

      return right(null);
    } on FirebaseException catch (e) {
      return left(e.message ?? 'Failed to delete ad');
    }
  }

  /// The method [updateAd] allows to update an ad represented by its unique identifier [updatedAd.uid] and that meets the passed parameters
  Future<Either<String, void>> updateAd({
    required AdData updatedAd,
    required List<File> newPhotosPaths,
  }) async {
    try {
      final adDocRef = _adCollection.doc(updatedAd.uid);

      // 1. Update standard fields
      await adDocRef.update({
        _nameField: updatedAd.name,
        _rentersCapacityField: updatedAd.rentersCapacity,
        _monthlyRentField: updatedAd.monthlyRent,
        _servicesField: updatedAd.services,
      });

      // 2. Update subcollections

      // Update Address
      final addressSnapshot =
          await adDocRef.collection(_addressSubcollectionName).get();

      await addressSnapshot.docs.first.reference.update({
        'street': updatedAd.address.street,
        'city': updatedAd.address.city,
      });

      // Update Rooms
      final roomsSnapshot =
          await adDocRef.collection(_roomsSubcollectionName).get();
      for (final doc in roomsSnapshot.docs) {
        await doc.reference.delete();
      }

      for (final room in updatedAd.rooms) {
        final roomData = {
          'name': room.name,
          'quantity': room.quantity,
        };
        if (room is Bedroom) {
          roomData['numBeds'] = room.numBeds;
        }
        await adDocRef.collection(_roomsSubcollectionName).add(roomData);
      }

      // Update Renters
      final rentersSnapshot =
          await adDocRef.collection(_rentersSubcollectionName).get();
      for (final doc in rentersSnapshot.docs) {
        await doc.reference.delete();
      }
      for (final renter in updatedAd.renters) {
        await adDocRef.collection(_rentersSubcollectionName).add({
          'name': renter.name,
          'age': renter.age,
          'facultyOfStudies': renter.facultyOfStudies,
          'interests': renter.interests,
          'contractDeadline': renter.contractDeadline.toIso8601String(),
        });
      }

      // 3. Update photos in Firebase Storage
      final adPhotosRef = _adRef.child(updatedAd.uid!);
      final adPhotos = await adPhotosRef.listAll();

      // Delete old photos
      for (final item in adPhotos.items) {
        await item.delete();
      }

      // Upload new photos
      for (File photo in newPhotosPaths) {
        final imageData = await photo.readAsBytes();
        String photoName = photo.uri.pathSegments.last; // Get the file name
        Reference photoRef = _adRef
            .child(updatedAd.uid!)
            .child(photoName); // Reference for the new photo
        await photoRef.putData(imageData);
      }

      return right(null);
    } on FirebaseException catch (e) {
      return left(e.message ?? 'Failed to update ad');
    }
  }

  /// The method [getAdsForRandomCity] returns a list of ads located in a random city
  Future<Either<String, List<AdData>>> getAdsForRandomCity() async {
    try {
      // 1. Fetch all ads
      final adsSnapshot = await _adCollection.get();
      final ads = adsSnapshot.docs; // list of all 'ads' collections

      // 2. Filter ads by random city
      if (ads.isEmpty) {
        return right([]);
      }
      // Get a random document
      final DocumentSnapshot randomAdDoc = (ads..shuffle()).first;
      final addressSnapshot = await randomAdDoc.reference
          .collection(_addressSubcollectionName)
          .get();
      // Extract its city
      final randomCity = addressSnapshot.docs.first['city'];

      // Get ads in which their city is the same as [randomCity]
      final List<QueryDocumentSnapshot<Object?>> cityAdsSnapshot = [];
      for (var element in ads) {
        final addressSnap =
            await element.reference.collection(_addressSubcollectionName).get();
        if (addressSnap.docs.first['city'] == randomCity) {
          cityAdsSnapshot.add(element);
        }
      }

      // Create AdData list with [cityAdsSnapshot] elements
      List<AdData> adsList = [];
      for (final doc in cityAdsSnapshot) {
        final adUid = doc.id;

        // Fetch renters
        final rentersSnapshot =
            await doc.reference.collection(_rentersSubcollectionName).get();
        List<Renter> rentersList = rentersSnapshot.docs.map((renterDoc) {
          final renterData = renterDoc.data();
          return Renter(
            name: renterData['name'],
            age: renterData['age'],
            facultyOfStudies: renterData['facultyOfStudies'],
            interests: renterData['interests'],
            contractDeadline: DateTime.parse(renterData['contractDeadline']),
          );
        }).toList();

        final rentersCapacity = doc[_rentersCapacityField] as int;

        // Skip the ad if renters count equals the rentersCapacity
        if (rentersList.length == rentersCapacity) {
          continue;
        }

        // Fetch ad address
        final addressSnapshot =
            await doc.reference.collection(_addressSubcollectionName).get();
        final addressData = addressSnapshot.docs.first.data();
        Address address =
            Address(street: addressData['street'], city: addressData['city']);

        // Fetch ad photos
        final adPhotos = await _adRef.child(adUid).listAll();
        final List<String> adPhotosURLs = await Future.wait(
            adPhotos.items.map((item) => item.getDownloadURL()));

        // Fetch rooms
        final roomsSnapshot =
            await doc.reference.collection(_roomsSubcollectionName).get();
        List<Room> roomsList = roomsSnapshot.docs.map((roomDoc) {
          final roomData = roomDoc.data();
          if (roomData.containsKey('numBeds')) {
            return Bedroom(
              name: roomData['name'],
              quantity: roomData['quantity'],
              numBeds: List<int>.from(roomData['numBeds']),
            );
          } else {
            return Room(
              name: roomData['name'],
              quantity: roomData['quantity'],
            );
          }
        }).toList();

        // Fetch services field
        final services = List<String>.from(doc[_servicesField] ?? []);

        adsList.add(AdData(
          uid: adUid,
          hostUid: doc[_hostUidField],
          hostName: doc[_hostNameField],
          hostPhotoURL: doc[_hostPhotoURLField],
          name: doc[_nameField],
          address: address,
          rooms: roomsList,
          rentersCapacity: doc[_rentersCapacityField],
          renters: rentersList,
          services: services,
          monthlyRent: doc[_monthlyRentField],
          photosURLs: adPhotosURLs,
        ));
      }

      return right(adsList);
    } on FirebaseException catch (e) {
      return left(e.message ?? "Failed to fetch ads");
    }
  }

  /// The method [getAdsByHostUid] returns a host ads list searching for the host unique identifier [hostUid]
  Future<Either<String, List<AdData>>> getAdsByHostUid(
      {required String hostUid}) async {
    try {
      // Fetch ads by hostUid
      final adsSnapshot =
          await _adCollection.where(_hostUidField, isEqualTo: hostUid).get();
      final ads = adsSnapshot.docs;

      List<AdData> adsList = [];
      for (final doc in ads) {
        final adUid = doc.id;

        // Retrieve subcollection data
        final addressSnap =
            await doc.reference.collection(_addressSubcollectionName).get();
        final addressData = addressSnap.docs.first.data();

        final roomsSnap =
            await doc.reference.collection(_roomsSubcollectionName).get();
        final rooms = roomsSnap.docs.map((roomDoc) {
          final roomData = roomDoc.data();
          if (roomData.containsKey('numBeds')) {
            return Bedroom(
              name: roomData['name'],
              quantity: roomData['quantity'],
              numBeds: List<int>.from(roomData['numBeds']),
            );
          } else {
            return Room(
              name: roomData['name'],
              quantity: roomData['quantity'],
            );
          }
        }).toList();

        final rentersSnap =
            await doc.reference.collection(_rentersSubcollectionName).get();
        final renters = rentersSnap.docs
            .map((renterDoc) => Renter(
                  name: renterDoc['name'],
                  age: renterDoc['age'],
                  facultyOfStudies: renterDoc['facultyOfStudies'],
                  interests: renterDoc['interests'],
                  contractDeadline:
                      DateTime.parse(renterDoc['contractDeadline']),
                ))
            .toList();

        final services = List<String>.from(doc[_servicesField] ?? []);

        // Retrieve photo URLs
        final adPhotos = await _adRef.child(adUid).listAll();
        final List<String> adPhotosURLs = await Future.wait(
            adPhotos.items.map((item) => item.getDownloadURL()));

        // Add the ad data to the list
        adsList.add(AdData(
          uid: adUid,
          hostUid: doc[_hostUidField],
          hostName: doc[_hostNameField],
          hostPhotoURL: doc[_hostPhotoURLField],
          name: doc[_nameField],
          address: Address(
            street: addressData['street'],
            city: addressData['city'],
          ),
          rooms: rooms,
          rentersCapacity: doc[_rentersCapacityField],
          renters: renters,
          services: services,
          monthlyRent: doc[_monthlyRentField],
          photosURLs: adPhotosURLs,
        ));
      }

      return right(adsList);
    } on FirebaseException catch (e) {
      return left(e.message ?? "Failed to fetch ads by host UID");
    }
  }

  /// The method [getFilteredAds] returns a list of filtered ads following the passed filters:
  /// - [city], used to fetch the digited city in the search bar in the moment user wants to apply filters on the uploaded results
  /// - [minRent] and [maxRent] to determine the ideal rent
  /// - [requiredServices], to search only for facilities that offer the searched services
  /// - at least [minBedrooms] bedrooms
  /// - at least [minBeds] bedrooms
  /// - at least [minBathrooms] bedrooms
  /// - with exactly [roommates] roomates
  Future<Either<String, List<AdData>>> getFilteredAds({
    required String city,
    int? minRent,
    int? maxRent,
    List<String>? requiredServices,
    int? minBedrooms,
    int? minBeds,
    int? minBathrooms,
    int? roommates,
  }) async {
    try {
      // Fetch all ads
      final adsSnapshot = await _adCollection.get();
      final ads = adsSnapshot.docs; // list of all 'ads' collections

      if (ads.isEmpty) {
        return right([]);
      }

      // Apply city filter
      final List<QueryDocumentSnapshot<Object?>> filteredList = [];
      // capitalize the first letter of the city
      city = "${city[0].toUpperCase()}${city.substring(1).toLowerCase()}";

      for (var element in ads) {
        final addressSnap =
            await element.reference.collection(_addressSubcollectionName).get();
        if (addressSnap.docs.first['city'] == city) {
          filteredList.add(element);
        }
      }

      // Apply price range filter
      if (minRent != null) {
        filteredList.removeWhere((item) => item[_monthlyRentField] < minRent);
      }
      if (maxRent != null) {
        filteredList.removeWhere((item) => item[_monthlyRentField] > maxRent);
      }

      List<AdData> filteredAds = [];

      for (final doc in filteredList) {
        final adUid = doc.id;

        // Fetch renters subcollection
        final rentersSnap =
            await doc.reference.collection(_rentersSubcollectionName).get();
        List<Renter> rentersList = rentersSnap.docs.map((renterDoc) {
          final renterData = renterDoc.data();
          return Renter(
            name: renterData['name'],
            age: renterData['age'],
            facultyOfStudies: renterData['facultyOfStudies'],
            interests: renterData['interests'],
            contractDeadline: DateTime.parse(renterData['contractDeadline']),
          );
        }).toList();

        final rentersCapacity = doc[_rentersCapacityField] as int;

        // Skip the ad if renters count equals the rentersCapacity
        if (rentersList.length == rentersCapacity) {
          continue;
        }

        // Apply renter filters
        if (roommates != null && rentersList.length != roommates) {
          continue;
        }

        // Fetch address subcollection
        final addressSnap =
            await doc.reference.collection(_addressSubcollectionName).get();
        final address = Address(
          street: addressSnap.docs.first['street'],
          city: addressSnap.docs.first['city'],
        );

        int numberOfBeds = 0;
        int numberOfBedrooms = 0;
        int numberOfBathrooms = 0;

        // Fetch rooms subcollection
        final roomsSnap =
            await doc.reference.collection(_roomsSubcollectionName).get();
        List<Room> roomsList = roomsSnap.docs.map((roomDoc) {
          final roomData = roomDoc.data();
          if (roomData.containsKey('numBeds')) {
            numberOfBedrooms = numberOfBedrooms + (roomData['quantity'] as int);
            numberOfBeds = List<int>.from(roomData['numBeds'])
                .reduce((bedsSum, b) => bedsSum + b);

            return Bedroom(
              name: roomData['name'],
              quantity: roomData['quantity'],
              numBeds: List<int>.from(roomData['numBeds']),
            );
          } else {
            if (roomData['name'] == 'Bathrooms') {
              numberOfBathrooms =
                  numberOfBathrooms + (roomData['quantity'] as int);
            }

            return Room(
              name: roomData['name'],
              quantity: roomData['quantity'],
            );
          }
        }).toList();

        // Apply room filters (skip the rest of the code if any of these conditions is not respected)
        if (minBedrooms != null && numberOfBedrooms < minBedrooms) {
          continue;
        }
        if (minBeds != null && numberOfBeds < minBeds) {
          continue;
        }
        if (minBathrooms != null && numberOfBathrooms < minBathrooms) {
          continue;
        }

        // Fetch services field
        // Capitalizing the first letter for every required service
        if (requiredServices != null) {
          for (var element in requiredServices) {
            element =
                "${element[0].toUpperCase()}${element.substring(1).toLowerCase()}";
          }
        }
        final services = List<String>.from(doc[_servicesField] ?? []);
        if (requiredServices != null &&
            !requiredServices.every((service) => services.contains(service))) {
          continue;
        }

        // Fetch photos from Firebase Storage
        final adPhotos = await _adRef.child(adUid).listAll();
        final List<String> adPhotosURLs = await Future.wait(
            adPhotos.items.map((item) => item.getDownloadURL()));

        // Add filtered ad data to final list
        filteredAds.add(AdData(
          uid: adUid,
          hostUid: doc[_hostUidField],
          hostName: doc[_hostNameField],
          hostPhotoURL: doc[_hostPhotoURLField],
          name: doc[_nameField],
          address: address,
          rooms: roomsList,
          rentersCapacity: rentersCapacity,
          renters: rentersList,
          services: services,
          monthlyRent: doc[_monthlyRentField],
          photosURLs: adPhotosURLs,
        ));
      }

      return right(filteredAds);
    } on FirebaseException catch (e) {
      return left(e.message ?? "Failed to fetch filtered ads");
    }
  }
}

final adDataSourceProvider = Provider<AdDataSource>((ref) => AdDataSource(
    ref.read(firebaseFirestoreProvider).collection(_adsCollectionName),
    ref.read(firebaseStorageProvider).ref().child(_photosAdsRef)));
