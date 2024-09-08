import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:room_finder/model/authentication_model.dart';
import 'package:room_finder/model/user_model.dart';
import 'package:room_finder/provider/firebase_providers.dart';

/// This class allow to handle the user account in Authentication
class AuthDataSource {
  final FirebaseAuth _auth;

  AuthDataSource(this._auth);

  /// This method allow to get the current logged user's info
  User? get currentUser => _auth.currentUser;

  /// This method allow the user to signup into the application
  ///
  /// [AuthArgs] the user's credential to store in Authentication
  ///
  /// [UserData] the user's data to store in Firestore
  Future<Either<String, User>> signup(
      {required AuthArgs userCredential, required UserData user}) async {
    try {
      // create a new user
      final response = await _auth.createUserWithEmailAndPassword(
          email: userCredential.email, password: userCredential.password);
      // setting the name
      await response.user!.updateDisplayName(user.name);
      return right(response.user!);
    } on FirebaseAuthException catch (e) {
      return left(e.message ?? 'Failed to Signup');
    }
  }

  /// This method allow the user to login into the application
  ///
  /// [AuthArgs] is required to check the user's credential
  Future<Either<String, User>> login({required AuthArgs userCredential}) async {
    try {
      final response = await _auth.signInWithEmailAndPassword(
          email: userCredential.email, password: userCredential.password);
      return right(response.user!);
    } on FirebaseAuthException catch (e) {
      return left(e.message ?? 'Failed to Login');
    }
  }

  /// This method allow the user to logout from the application
  Future<Either<String, void>> logout() async {
    try {
      await _auth.signOut();
      return right(null);
    } on FirebaseAuthException catch (e) {
      return left(e.message ?? 'Failed to logout');
    }
  }

  Future<Either<String, String>> updateName(
      {required String newUserName}) async {
    try {
      await currentUser!.updateDisplayName(newUserName);
      return right(newUserName);
    } on FirebaseAuthException catch (e) {
      return left(e.message ?? 'Failed to update the name');
    }
  }

  Future<Either<String, String>> updatePhotoURL(
      {required String newPhotoURL}) async {
    try {
      await currentUser!.updatePhotoURL(newPhotoURL);
      return right(newPhotoURL);
    } on FirebaseAuthException catch (e) {
      return left(e.message ?? 'Failed to update the photo URL');
    }
  }

  Future<Either<String, void>> updatePassword(
      {required String newPassword}) async {
    try {
      await currentUser!.updatePassword(newPassword);

      return right(null);
    } on FirebaseAuthException catch (e) {
      return left(e.message ?? "Failed to update the password");
    }
  }
}

final authDataSourceProvider = Provider<AuthDataSource>(
  (ref) => AuthDataSource(ref.read(firebaseAuthProvider)),
);
