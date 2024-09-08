import 'dart:async';
import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:room_finder/data/ad_data.dart';
import 'package:room_finder/model/ad_model.dart';
import 'package:room_finder/provider/state/ad_state.dart';

class AdNotifier extends StateNotifier<AdState> {
  final AdDataSource _adDataSource;

  AdNotifier(this._adDataSource) : super(const AdState.initial());

  /// The method [getAd] returns an individual ad passing as parameter its unique identifier [adUid]
  Future<void> getAd({required String adUid, required bool isHost}) async {
    state = const AdState.loading();

    final response = await _adDataSource.getAd(adUid: adUid, isHost: isHost);

    state = response.fold((error) => const AdState.singleFailedRead(),
        (response) => AdState.singleSuccessfulRead(adData: response));
  }

  /// The method [addNewAd] allows to add a new ad that respects the passed parameters
  Future<void> addNewAd(
      {required AdData newAd,
      required List<File> photosPaths}) async {
    state = const AdState.loading();

    final response = await _adDataSource.addNewAd(
        newAd: newAd,
        photosPaths: photosPaths);

    state = response.fold((error) => const AdState.failedAddNewAd(),
        (response) => const AdState.successfulAddNewAd());
  }

  /// The method [deleteAd] allows to delete an ad passing as parameter its unique identifier [adUid]
  Future<void> deleteAd({required String adUid}) async {
    state = const AdState.loading();

    final response = await _adDataSource.deleteAd(adUid: adUid);

    state = response.fold((error) => const AdState.failedDeleteAd(),
        (response) => const AdState.successfulDeleteAd());
  }

  /// The method [updateAd] allows to update an ad represented by its unique identifier [adUid] and that meets the passed parameters
  Future<void> updateAd({
    required AdData updatedAd,
    required List<File> newPhotosPaths,
  }) async {
    state = const AdState.loading();

    final response = await _adDataSource.updateAd(
        updatedAd: updatedAd,
        newPhotosPaths: newPhotosPaths);

    state = response.fold((error) => const AdState.failedUpdateAd(),
        (response) => const AdState.successfulUpdateAd());
  }

  /// The method [getAdsForRandomCity] returns a list of ads located in a random city
  Future<void> getAdsForRandomCity() async {
    state = const AdState.loading();

    final response = await _adDataSource.getAdsForRandomCity();

    state = response.fold((error) => const AdState.multipleRandomFailedReads(),
        (response) => AdState.multipleRandomSuccessfulReads(adsData: response));
  }

  /// The method [getAdsByHostUid] returns a host ads list searching for the host unique identifier [hostUid]
  Future<void> getAdsByHostUid({required String hostUid}) async {
    state = const AdState.loading();

    final response = await _adDataSource.getAdsByHostUid(hostUid: hostUid);

    state = response.fold((error) => const AdState.multipleFailedReads(),
        (response) => AdState.multipleSuccessfulReads(adsData: response));
  }

  /// The method [getFilteredAds] returns a list of filtered ads following the passed filters:
  /// - [city], used to fetch the digited city in the search bar in the moment user wants to apply filters on the uploaded results
  /// - [minRent] and [maxRent] to determine the ideal rent
  /// - [requiredServices], to search only for facilities that offer the searched services
  /// - at least [minBedrooms] bedrooms
  /// - at least [minBeds] bedrooms
  /// - at least [minBathrooms] bedrooms
  /// - with exactly [roommates] roomates
  Future<void> getFilteredAds({
    required String city,
    int? minRent,
    int? maxRent,
    List<String>? requiredServices,
    int? minBedrooms,
    int? minBeds,
    int? minBathrooms,
    int? roommates,
  }) async {
    state = const AdState.loading();

    final response = await _adDataSource.getFilteredAds(
        city: city,
        minRent: minRent,
        maxRent: maxRent,
        requiredServices: requiredServices,
        minBedrooms: minBedrooms,
        minBeds: minBeds,
        minBathrooms: minBathrooms,
        roommates: roommates);

    state = response.fold((error) => const AdState.multipleFailedReads(),
        (response) => AdState.multipleSuccessfulReads(adsData: response));
  }
}

final adNotifierProvider = StateNotifierProvider<AdNotifier, AdState>(
    (ref) => AdNotifier(ref.read(adDataSourceProvider)));
