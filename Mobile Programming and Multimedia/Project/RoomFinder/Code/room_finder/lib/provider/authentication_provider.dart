import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:room_finder/data/authentication_data.dart';
import 'package:room_finder/data/user_data.dart';
import 'package:room_finder/model/authentication_model.dart';
import 'package:room_finder/model/user_model.dart';
import 'package:room_finder/provider/state/authentication_state.dart';

class AuthNotifier extends StateNotifier<AuthenticationState> {
  final AuthDataSource _authDataSource;
  final UserDataSource _userDataSource;

  AuthNotifier(this._authDataSource, this._userDataSource)
      : super(const AuthenticationState.initial());

  /// Get the user's info from Authentication
  User? get currentUser => _authDataSource.currentUser;

  /// This method check if the current user is still logged
  bool isLogged() {
    return _authDataSource.currentUser != null;
  }

  /// This method allow the user to signup into the application
  ///
  /// [AuthArgs] the user's credential to store in Authentication
  ///
  /// [UserData] the user's data to store in Firestore
  Future<void> signup(
      {required AuthArgs userCredential, required UserData user}) async {
    state = const AuthenticationState.loading();
    // register the new user to the Authentication db
    final response = await _authDataSource.signup(
        userCredential: userCredential, user: user);

    state = response.fold((error) => const AuthenticationState.unregistered(),
        (response) {
      // on success, then
      // add the new user registered to the Firestore db
      Future.delayed(const Duration(seconds: 0), () async {
        await _userDataSource.addNewUser(
            newUserUid: response.uid, isHost: user.isHost);
      });
      return AuthenticationState.registered(user: response);
    });
  }

  /// This method allow the user to login into the application
  ///
  /// [AuthArgs] is required to check the user's credential
  Future<void> login({required AuthArgs userCredential}) async {
    state = const AuthenticationState.loading();

    final response =
        await _authDataSource.login(userCredential: userCredential);

    state = response.fold(
        (error) => const AuthenticationState.unauthenticated(),
        (response) => AuthenticationState.authenticated(user: response));
  }

  /// This method allow the user to logout from the application
  Future<void> logout() async {
    state = const AuthenticationState.loading();

    final response = await _authDataSource.logout();

    state = response.fold((error) => const AuthenticationState.failedLogout(),
        (response) => const AuthenticationState.successfulLogout());
  }

  Future<void> updatePersonalInformation(
      {String? newUserName, String? imageName, File? imageFile}) async {
    state = const AuthenticationState.loading();

    if (newUserName != null) {
      await updateName(newUserName: newUserName);
    }

    if (imageName != null && imageFile != null) {
      await updatePhoto(imageName: imageName, imageFile: imageFile);
    }
  }

  Future<void> updateName({required String newUserName}) async {
    state = const AuthenticationState.loading();

    final response = await _authDataSource.updateName(newUserName: newUserName);

    state = response.fold(
        (error) => const AuthenticationState.nameNotUpdated(),
        (response) => AuthenticationState.personalInfoUpdated(
            name: response, photoURL: ''));
  }

  Future<void> updatePhoto(
      {required String imageName, required File imageFile}) async {
    state = const AuthenticationState.loading();
    // upload the photo to Storage
    final photoResponse = await _userDataSource.updatePhoto(
        imageFile: imageFile, imageName: imageName);

    state = photoResponse.fold(
        (error) => const AuthenticationState.photoNotUpdated(),
        (response) => AuthenticationState.personalInfoUpdated(
            name: '', photoURL: response));

    Either<String, String> response = left('Error on uploading');

    if (photoResponse.isRight()) {
      response = await _authDataSource.updatePhotoURL(
          newPhotoURL: photoResponse.getOrElse(() => ''));
    }

    state = response.fold(
        (error) => const AuthenticationState.photoNotUpdated(),
        (response) => AuthenticationState.personalInfoUpdated(
            name: '', photoURL: response));
  }

  Future<void> updatePassword({required String newPassword}) async {
    state = const AuthenticationState.loading();

    final response =
        await _authDataSource.updatePassword(newPassword: newPassword);

    state = response.fold(
        (error) => const AuthenticationState.passwordNotUpdated(),
        (response) => const AuthenticationState.passwordUpdated());
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthenticationState>((ref) =>
        AuthNotifier(ref.read(authDataSourceProvider),
            ref.read(userDataSourceProvider)));
