import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:room_finder/main.dart';
import 'package:room_finder/model/ad_model.dart';
import 'package:room_finder/presentation/components/ads_box.dart';
import 'package:room_finder/presentation/components/buttons/circle_buttons.dart';
import 'package:room_finder/presentation/components/error_messages.dart';
import 'package:room_finder/presentation/components/filter_panel.dart';
import 'package:room_finder/presentation/components/screens_templates.dart';
import 'package:room_finder/presentation/components/search_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:room_finder/presentation/components/snackbar.dart';
import 'package:room_finder/presentation/screens/facility_detail_page.dart';
import 'package:room_finder/provider/ad_provider.dart';
import 'package:room_finder/style/color_palette.dart';
import 'package:room_finder/util/network_handler.dart';

class SearchResultsPage extends ConsumerStatefulWidget {
  final bool isLogged;
  final String currentUserUid;

  final String searchCity;

  // fields used to search filtered ads
  final int? minRent;
  final int? maxRent;
  final List<String>? requiredServices;
  final int? minBedrooms;
  final int? minBeds;
  final int? minBathrooms;
  final int? roommates;

  const SearchResultsPage(
      {super.key,
      required this.isLogged,
      required this.currentUserUid,
      required this.searchCity,
      this.minRent,
      this.maxRent,
      this.requiredServices,
      this.minBedrooms,
      this.minBeds,
      this.minBathrooms,
      this.roommates});

  @override
  ConsumerState<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends ConsumerState<SearchResultsPage> {
  List<AdData> filteredAds = [];
  bool isOnLoad = true;
  bool areFiltersApplied = false;

  late RangeValues _currentRangeValues;
  late Map<String, bool> _amenitiesSwitches;
  late Map<String, int> _selectedRoomIndex;

  @override
  void initState() {
    super.initState();

    // Initialize with passed filters or default values
    _currentRangeValues = RangeValues(
      widget.minRent?.toDouble() ?? 0,
      widget.maxRent?.toDouble() ?? 1000,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _amenitiesSwitches = {
      AppLocalizations.of(context)!.lblWiFi: widget.requiredServices
              ?.contains(AppLocalizations.of(context)!.lblWiFi) ??
          false,
      AppLocalizations.of(context)!.lblDishwasher: widget.requiredServices
              ?.contains(AppLocalizations.of(context)!.lblDishwasher) ??
          false,
      AppLocalizations.of(context)!.lblWashingMachine: widget.requiredServices
              ?.contains(AppLocalizations.of(context)!.lblWashingMachine) ??
          false,
      AppLocalizations.of(context)!.lblDedicatedParking: widget.requiredServices
              ?.contains(AppLocalizations.of(context)!.lblDedicatedParking) ??
          false,
      AppLocalizations.of(context)!.lblAirConditioning: widget.requiredServices
              ?.contains(AppLocalizations.of(context)!.lblAirConditioning) ??
          false,
    };

    _selectedRoomIndex = {
      AppLocalizations.of(context)!.lblBedrooms: widget.minBedrooms ?? 0,
      AppLocalizations.of(context)!.lblBeds: widget.minBeds ?? 0,
      AppLocalizations.of(context)!.lblBathrooms: widget.minBathrooms ?? 0,
      AppLocalizations.of(context)!.lblRoommates: widget.roommates ?? 0,
    };

    // Determine if filters are applied
    areFiltersApplied = _currentRangeValues.start > 0 ||
        _currentRangeValues.end < 1000 ||
        _amenitiesSwitches.containsValue(true) ||
        _selectedRoomIndex.values.any((value) => value > 0);

    // Fetch the ads after dependencies have been set
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ref.read(adNotifierProvider.notifier).getFilteredAds(
          city: widget.searchCity,
          minRent: widget.minRent,
          maxRent: widget.maxRent,
          requiredServices: widget.requiredServices,
          minBedrooms: widget.minBedrooms,
          minBeds: widget.minBeds,
          minBathrooms: widget.minBathrooms,
          roommates: widget.roommates);
    });
  }

  void _showSearchFilterPanel() {
    _showFilterPanel();
  }

  Future _showFilterPanel() {
    return showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: ColorPalette.lavenderBlue,
      builder: (context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
          return SearchFilterPanel(
            context: context,
            panelTitle: AppLocalizations.of(context)!.lblFilters,
            buttonLabel: AppLocalizations.of(context)!.btnApplyFilters,
            onConfirmPressed: () {
              // Get the selected filters
              final minRent = _currentRangeValues.start.toInt();
              final maxRent = _currentRangeValues.end.toInt();

              // Collect selected amenities
              final selectedAmenities = _amenitiesSwitches.entries
                  .where((entry) => entry.value)
                  .map((entry) => entry.key)
                  .toList();

              // Collect selected room-related filters
              final minBedrooms =
                  _selectedRoomIndex[AppLocalizations.of(context)!.lblBedrooms];
              final minBeds =
                  _selectedRoomIndex[AppLocalizations.of(context)!.lblBeds];
              final minBathrooms = _selectedRoomIndex[
                  AppLocalizations.of(context)!.lblBathrooms];
              final roommates = _selectedRoomIndex[
                  AppLocalizations.of(context)!.lblRoommates];

              // Check if any filters are applied
              bool areFiltersApplied = minRent > 0 ||
                  maxRent < 1000 ||
                  selectedAmenities.isNotEmpty ||
                  minBedrooms! > 0 ||
                  minBeds! > 0 ||
                  minBathrooms! > 0 ||
                  roommates! > 0;

              if (areFiltersApplied) {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) {
                  return SearchResultsPage(
                    isLogged: widget.isLogged,
                    currentUserUid: widget.currentUserUid,
                    searchCity: widget.searchCity,
                    minRent: minRent,
                    maxRent: maxRent,
                    requiredServices:
                        selectedAmenities.isEmpty ? null : selectedAmenities,
                    minBedrooms: minBedrooms == 0 ? null : minBedrooms,
                    minBeds: minBeds == 0 ? null : minBeds,
                    minBathrooms: minBathrooms == 0 ? null : minBathrooms,
                    roommates: roommates == 0 ? null : roommates,
                  );
                }));
              }
            },
            onClosedPressed: () => Navigator.pop(context),
            currentRangeValues: _currentRangeValues,
            onPriceChanged: (values) {
              setModalState(() {
                _currentRangeValues = values;
              });
            },
            amenitiesSwitches: _amenitiesSwitches,
            onServiceChanged: (key, value) {
              setModalState(() {
                _amenitiesSwitches[key] = value;
              });
            },
            selectedRoomIndex: _selectedRoomIndex,
            onRoomIndexSelected: (key, value, entry) {
              setModalState(() {
                _selectedRoomIndex[key] = value ? entry : 0;
              });
            },
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(adNotifierProvider, (previous, next) {
      next.maybeWhen(
          orElse: () => {},
          multipleFailedReads: () {
            showErrorSnackBar(
                context,
                AppLocalizations.of(context)!
                    .lblFailOperation("retrieving ads"));

            setState(() {
              isOnLoad = false;
            });
          },
          multipleSuccessfulReads: (adsData) {
            filteredAds = adsData;

            setState(() {
              isOnLoad = false;
            });
          });
    });

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) {
          return;
        }
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return const MyHomePage();
        }));
      },
      child: SecondaryTemplateScreen(
          leftHeaderWidget: DarkBackButton(
              onPressed: () =>
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const MyHomePage();
                  }))),
          centerHeaderWidget: CustomSearchBar(
            hintText: widget.searchCity,
            isLogged: widget.isLogged,
            currentUserUid: widget.currentUserUid,
            isInvokedFromHome: false,
          ),
          rightHeaderWidget:
              FilterButton(onPressed: () => _showSearchFilterPanel()),
          rightHeaderWidgetVisibility: true,
          content: isOnLoad
              ? const Expanded(
                  child: Center(
                  child: CircularProgressIndicator(),
                ))
              : ref.read(networkAwareProvider) == NetworkStatus.off
                  ? Expanded(
                      child: Center(
                        child: NoInternetErrorMessage(context: context),
                      ),
                    )
                  : filteredAds.isEmpty
                      ? Expanded(
                          child: Column(
                            children: [
                              // If filters are applied, show the "Remove Filters" button
                              if (areFiltersApplied)
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10.h),
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      // Remove filters by reinvoking SearchResultsPage without filters
                                      Navigator.pushReplacement(context,
                                          MaterialPageRoute(builder: (context) {
                                        return SearchResultsPage(
                                          isLogged: widget.isLogged,
                                          searchCity: widget.searchCity,
                                          currentUserUid: widget.currentUserUid,
                                        );
                                      }));
                                    },
                                    label: Text(AppLocalizations.of(context)!
                                        .btnRemoveFilters),
                                    icon: const Icon(Icons.clear_rounded),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor:
                                          Theme.of(context).colorScheme.error,
                                      side: BorderSide(
                                        color:
                                            Theme.of(context).colorScheme.error,
                                      ),
                                    ),
                                  ),
                                ),
                              Expanded(
                                child: Center(
                                  child: NoDataErrorMessage(
                                    context: context,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Expanded(
                          child: Column(
                            children: [
                              areFiltersApplied
                                  ? Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 10.h),
                                      child: OutlinedButton.icon(
                                        onPressed: () {
                                          // Remove filters by reinvoking SearchResultsPage without filters
                                          Navigator.pushReplacement(context,
                                              MaterialPageRoute(
                                                  builder: (context) {
                                            return SearchResultsPage(
                                                isLogged: widget.isLogged,
                                                searchCity: widget.searchCity,
                                                currentUserUid:
                                                    widget.currentUserUid);
                                          }));
                                        },
                                        label: Text(
                                            AppLocalizations.of(context)!
                                                .btnRemoveFilters),
                                        icon: const Icon(Icons.clear_rounded),
                                        style: OutlinedButton.styleFrom(
                                            foregroundColor: Theme.of(context)
                                                .colorScheme
                                                .error,
                                            side: BorderSide(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .error)),
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                              Expanded(
                                child: ListView.separated(
                                  padding: EdgeInsets.all(20.w),
                                  itemCount: filteredAds.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return AdsBox(
                                        imageUrl: filteredAds[index]
                                            .photosURLs!
                                            .first,
                                        city: filteredAds[index].address.city,
                                        street:
                                            filteredAds[index].address.street,
                                        price: filteredAds[index].monthlyRent,
                                        onPressed: () => {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      FacilityDetailPage(
                                                    isLogged: widget.isLogged,
                                                    isStudent: true,
                                                    isWizardPage: false,
                                                    ad: filteredAds[index],
                                                    adUid:
                                                        filteredAds[index].uid,
                                                    studentUid:
                                                        widget.currentUserUid,
                                                    isEditingMode: false,
                                                  ),
                                                ),
                                              ),
                                            });
                                  },
                                  separatorBuilder:
                                      (BuildContext context, int index) {
                                    return SizedBox(height: 20.h);
                                  },
                                ),
                              ),
                            ],
                          ),
                        )),
    );
  }
}
