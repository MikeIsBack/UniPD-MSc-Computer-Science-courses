import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:room_finder/main.dart';
import 'package:room_finder/model/ad_model.dart';
import 'package:room_finder/model/user_model.dart';
import 'package:room_finder/presentation/components/ads_box.dart';
import 'package:room_finder/presentation/components/buttons/circle_buttons.dart';
import 'package:room_finder/presentation/components/error_messages.dart';
import 'package:room_finder/presentation/components/screens_templates.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:room_finder/presentation/components/search_bar.dart';
import 'package:room_finder/presentation/components/snackbar.dart';
import 'package:room_finder/presentation/screens/facility_detail_page.dart';
import 'package:room_finder/presentation/screens/wizard_screens/wizard_page1.dart';
import 'package:room_finder/provider/ad_provider.dart';
import 'package:room_finder/util/network_handler.dart';

class StudentHomePage extends StatelessWidget {
  final bool isLogged;
  final UserData studentUser;

  const StudentHomePage(
      {super.key, required this.isLogged, required this.studentUser});

  @override
  Widget build(BuildContext context) {
    return MainTemplateScreen(
      screenLabel: isLogged
          ? AppLocalizations.of(context)!.lblWelcomeUser(studentUser.name!)
          : AppLocalizations.of(context)!.lblWelcomeNotLogged,
      screenContent:
          _StudentHomePageBody(isLogged: isLogged, studentUser: studentUser),
    );
  }
}

class _StudentHomePageBody extends ConsumerStatefulWidget {
  final bool isLogged;
  final UserData studentUser;

  const _StudentHomePageBody(
      {required this.isLogged, required this.studentUser});

  @override
  ConsumerState<_StudentHomePageBody> createState() =>
      _StudentHomePageBodyState();
}

class _StudentHomePageBodyState extends ConsumerState<_StudentHomePageBody> {
  bool isConnected = false;
  List<AdData> randomCityAds = [];
  bool isOnLoad = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      var connectivityStatusProvider = ref.watch(networkAwareProvider);
      setState(() {
        isConnected = connectivityStatusProvider == NetworkStatus.on;
      });

      ref.read(adNotifierProvider.notifier).getAdsForRandomCity();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(adNotifierProvider, (previous, next) {
      next.maybeWhen(
        orElse: () => null,
        multipleRandomFailedReads: () {
          showErrorSnackBar(context,
              AppLocalizations.of(context)!.lblFailOperation("retrieving ads"));
        setState(() {
            isOnLoad = false;
          });
        },
        multipleRandomSuccessfulReads: (adsData) {
          randomCityAds = adsData;

          setState(() {
            isOnLoad = false;
          });
        },
      );
    });

    if (ref.read(networkAwareProvider) == NetworkStatus.off) {
      isOnLoad = false;
    }

    return Expanded(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.w),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(AppLocalizations.of(context)!.lblFindRoom),
                ),
                SizedBox(height: 30.h),
                CustomSearchBar(
                    hintText: AppLocalizations.of(context)!.lblEnterCity,
                    isLogged: widget.isLogged,
                    currentUserUid: widget.studentUser.uid!,
                    isInvokedFromHome: true),
                SizedBox(height: 60.h),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    AppLocalizations.of(context)!.lblExploreSolutions,
                  ),
                ),
                SizedBox(height: 30.h),
              ],
            ),
          ),
          ref.read(networkAwareProvider) == NetworkStatus.off
              ? Expanded(
                  child: Center(
                    child: NoInternetErrorMessage(context: context),
                  ),
                )
              : isOnLoad
                  ? const Expanded(
                      child: Center(
                      child: CircularProgressIndicator(),
                    ))
                  : randomCityAds.isEmpty
                      ? Expanded(
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 10.h),
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    Navigator.pushReplacement(context,
                                        MaterialPageRoute(builder: (context) {
                                      return const MyHomePage();
                                    }));
                                  },
                                  label: Text(AppLocalizations.of(context)!
                                      .lblReloadPage),
                                  icon: const Icon(Icons.refresh),
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
                          child: ListView.separated(
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            itemCount: randomCityAds.length,
                            itemBuilder: (BuildContext context, int index) {
                              return AdsBox(
                                  imageUrl:
                                      randomCityAds[index].photosURLs!.first,
                                  city: randomCityAds[index].address.city,
                                  street: randomCityAds[index].address.street,
                                  price: randomCityAds[index].monthlyRent,
                                  onPressed: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            FacilityDetailPage(
                                          isLogged: widget.isLogged,
                                          isStudent: true,
                                          isWizardPage: false,
                                          ad: randomCityAds[index],
                                          adUid: randomCityAds[index].uid,
                                          studentUid: widget.studentUser.uid,
                                          isEditingMode: false,
                                        ),
                                      ),
                                    );
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
    );
  }
}

class HostHomePage extends StatelessWidget {
  final UserData hostUser;
  const HostHomePage({super.key, required this.hostUser});

  @override
  Widget build(BuildContext context) {
    return MainTemplateScreen(
      screenLabel: AppLocalizations.of(context)!.lblWelcomeUser(hostUser.name!),
      screenContent: _HostHomePageBody(
        hostUser: hostUser,
      ),
    );
  }
}

class _HostHomePageBody extends ConsumerStatefulWidget {
  final UserData hostUser;
  const _HostHomePageBody({required this.hostUser});

  @override
  ConsumerState<_HostHomePageBody> createState() => _HostHomePageBodyState();
}

class _HostHomePageBodyState extends ConsumerState<_HostHomePageBody> {
  bool isConnected = false;
  List<AdData> hostAds = [];
  bool isOnLoad = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () async {
      var connectivityStatusProvider = ref.watch(networkAwareProvider);

      setState(() {
        isConnected = connectivityStatusProvider == NetworkStatus.on;
      });

      ref
          .read(adNotifierProvider.notifier)
          .getAdsByHostUid(hostUid: widget.hostUser.uid!);
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(adNotifierProvider, (previous, next) {
      next.maybeWhen(
        orElse: () => null,
        multipleFailedReads: () {
          showErrorSnackBar(context,
              AppLocalizations.of(context)!.lblFailOperation("retrieving ads"));
        setState(() {
            isOnLoad = false;
          });
        },
        multipleSuccessfulReads: (adsData) {
          hostAds = adsData;

          setState(() {
            isOnLoad = false;
          });
        },
      );
    });

    return PopScope(
      canPop: false,
      child: Expanded(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.w),
              child: Column(
                children: [
                  FittedBox(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(AppLocalizations.of(context)!.lblCreateAds),
                        AddRemoveButton(
                          isAddButton: true,
                          size: 40.w,
                          onPressed: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return WizardPage1(
                                hostUser: widget.hostUser,
                                isEditingMode: false,
                              );
                            }));
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            ref.read(networkAwareProvider) == NetworkStatus.off
                ? Expanded(
                    child: Center(
                      child: NoInternetErrorMessage(context: context),
                    ),
                  )
                : isOnLoad
                    ? const Expanded(
                        child: Center(
                        child: CircularProgressIndicator(),
                      ))
                    : hostAds.isEmpty
                        ? Expanded(
                            child: Center(
                            child: NoDataErrorMessage(
                              context: context,
                            ),
                          ))
                        : Expanded(
                            child: ListView.separated(
                              padding: EdgeInsets.all(20.w),
                              itemCount: hostAds.length,
                              itemBuilder: (BuildContext context, int index) {
                                return AdsBox(
                                    imageUrl: hostAds[index].photosURLs!.first,
                                    city: hostAds[index].address.city,
                                    street: hostAds[index].address.street,
                                    price: hostAds[index].monthlyRent,
                                    onPressed: () => {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  FacilityDetailPage(
                                                isLogged: true,
                                                isStudent: false,
                                                isWizardPage: false,
                                                ad: hostAds[index],
                                                adUid: hostAds[index].uid,
                                                host: widget.hostUser,
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
      ),
    );
  }
}
