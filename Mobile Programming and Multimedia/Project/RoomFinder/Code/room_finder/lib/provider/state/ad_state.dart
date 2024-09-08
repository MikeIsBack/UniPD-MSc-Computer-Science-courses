import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:room_finder/model/ad_model.dart';

part "ad_state.freezed.dart";

@freezed
class AdState with _$AdState {
  const factory AdState.initial() = _Initial;

  const factory AdState.loading() = _Loading;

  const factory AdState.singleFailedRead() = _SingleFailedRead;

  const factory AdState.singleSuccessfulRead({required AdData? adData}) = _SingleSuccessfulRead;

  const factory AdState.multipleRandomFailedReads() = _MultipleRandomFailedRead;

  const factory AdState.multipleRandomSuccessfulReads({required List<AdData> adsData}) = _MultipleRandomSuccessfulRead;

  const factory AdState.multipleFailedReads() = _MultipleFailedRead;

  const factory AdState.multipleSuccessfulReads({required List<AdData> adsData}) = _MultipleSuccessfulRead;

  const factory AdState.failedAddNewAd() = _FailedAddNewAd;

  const factory AdState.successfulAddNewAd() = _SuccessfulAddNewAd;

  const factory AdState.failedDeleteAd() = _FailedDeleteAd;

  const factory AdState.successfulDeleteAd() = _SuccessfulDeleteAd;

  const factory AdState.failedUpdateAd() = _FailedUpdateAd;

  const factory AdState.successfulUpdateAd() = _SuccessfulUpdateAd;
}
