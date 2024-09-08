import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part "authentication_state.freezed.dart";

@freezed
class AuthenticationState with _$AuthenticationState {
  const factory AuthenticationState.initial() = _Initial;

  const factory AuthenticationState.loading() = _Loading;

  const factory AuthenticationState.unauthenticated() =
      _UnAuthentication;

  const factory AuthenticationState.authenticated({required User user}) =
      _Authenticated;

  const factory AuthenticationState.registered({required User user}) =
      _Registrered;
    
  const factory AuthenticationState.unregistered() =
      _Unregistrered;

  const factory AuthenticationState.successfulLogout() = _Logout;

  const factory AuthenticationState.failedLogout() = _notLogout;

  const factory AuthenticationState.nameNotUpdated() = _nameNotUpdated;

  const factory AuthenticationState.photoNotUpdated() = _photoNotUpdated;

   const factory AuthenticationState.personalInfoUpdated({required String name, required String photoURL}) = _personalInfoUpdated;

  const factory AuthenticationState.passwordNotUpdated() = _passwordNotUpdated;

  const factory AuthenticationState.passwordUpdated() = _passwordUpdated;
}
