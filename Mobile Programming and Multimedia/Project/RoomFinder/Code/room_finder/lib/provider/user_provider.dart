import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:room_finder/data/authentication_data.dart';
import 'package:room_finder/data/user_data.dart';
import 'package:room_finder/model/user_model.dart';
import 'package:room_finder/provider/state/user_state.dart';

class UserNotifier extends StateNotifier<UserState> {
  final UserDataSource _userDataSource;
  final AuthDataSource _authDataSource;

  UserNotifier(this._userDataSource, this._authDataSource)
      : super(const UserState.initial());

  /// The method [getUser] returns an individual user passing as parameter its unique identifier [userUid]
  Future<void> getUser({required String userUid}) async {
    state = const UserState.loading();

    final user = _authDataSource.currentUser;

    final response = await _userDataSource.getUser(userUid: userUid);

    state = response.fold((error) => const UserState.failedRead(),
        (response) => UserState.successfulRead(userData: UserData(
          uid: user!.uid,
          name: user.displayName,
          email: user.email,
          photoUrl: user.photoURL,
          isHost: response.isHost,
          savedAds: response.savedAds
          )));
  }

  /// The method [saveAd] allows to save an ad of interest by passing the parameters:
  /// - [adUid], the ad uid
  /// - [userUid], the id of the user who want to save the ad
  Future<void> saveAd({required String adUid, required String userUid}) async {
    state = const UserState.loading();

    final response =
        await _userDataSource.saveAd(adUid: adUid, userUid: userUid);

    state = response.fold((error) => const UserState.failedSaveAd(),
        (response) => const UserState.successfulSaveAd());
  }

  /// The method [removeSavedAd] allows to remove a saved ad by passing the parameters:
  /// - [adUid], the ad uid
  /// - [userUid], the id of the user who want to save the ad
  Future<void> removeSavedAd(
      {required String adUid, required String userUid}) async {
    state = const UserState.loading();

    final response =
        await _userDataSource.removeSavedAd(adUid: adUid, userUid: userUid);

    state = response.fold((error) => const UserState.failedRemoveSavedAd(),
        (response) => const UserState.successfulRemoveSavedAd());
  }

  /// The method [isAdSaved] checks if an ad has been saved by the current user by passing the parameters:
  /// - [adUid], the ad uid
  /// - [userUid], the id of the user who want to save the ad
  Future<void> isAdSaved(
      {required String adUid,
      required String userUid,
      required int index}) async {
    state = const UserState.loading();

    final response =
        await _userDataSource.isAdSaved(adUid: adUid, userUid: userUid);

    state = response.fold(
        (error) => const UserState.failedSavedAdRead(),
        (response) =>
            UserState.successfulSavedAdRead(isAdSaved: response, index: index));
  }

  /// The method [getSavedAds] allows to retrieve the list of all the user's saved ads by passing as parameter the list of user saved ads uids
  Future<void> getSavedAds({required List<String> savedAds}) async {
    state = const UserState.loading();

    final response = await _userDataSource.getSavedAds(savedAds: savedAds);

    state = response.fold((error) => const UserState.failedMultipleReads(),
        (response) => UserState.successfulMultipleReads(adsData: response));
  }
}

final userNotifierProvider = StateNotifierProvider<UserNotifier, UserState>(
    (ref) => UserNotifier(
        ref.read(userDataSourceProvider), ref.read(authDataSourceProvider)));
