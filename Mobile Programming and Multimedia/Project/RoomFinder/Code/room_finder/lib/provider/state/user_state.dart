import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:room_finder/model/ad_model.dart';
import 'package:room_finder/model/user_model.dart';

part "user_state.freezed.dart";

@freezed
class UserState with _$UserState {
  const factory UserState.initial() = _Initial;

  const factory UserState.loading() = _Loading;

  const factory UserState.failedRead() = _FailedRead;

  const factory UserState.successfulRead({required UserData userData}) = _SuccessfulRead;

  const factory UserState.failedSaveAd() = _FailedSaveAd;

  const factory UserState.successfulSaveAd() = _SuccessfulSaveAd;

  const factory UserState.failedRemoveSavedAd() = _FailedRemoveSavedAd;

  const factory UserState.successfulRemoveSavedAd() = _SucessfulRemoveSavedAd;

  const factory UserState.failedSavedAdRead() = _FailedSavedAdRead;

  const factory UserState.successfulSavedAdRead({required bool isAdSaved, required int index}) = _SuccessfulSavedAdRead;

  const factory UserState.failedMultipleReads() = _FailedMultipleReads;

  const factory UserState.successfulMultipleReads({required List<AdData?> adsData}) = _SuccessfulMultipleReads;
}
