import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:room_finder/model/ad_model.dart';
import 'package:room_finder/presentation/components/ads_box.dart';
import 'package:room_finder/presentation/components/error_messages.dart';
import 'package:room_finder/presentation/components/screens_templates.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:room_finder/presentation/components/snackbar.dart';
import 'package:room_finder/presentation/screens/facility_detail_page.dart';
import 'package:room_finder/provider/user_provider.dart';
import 'package:room_finder/util/network_handler.dart';

class SavedAdsPage extends ConsumerWidget {
  final String currentUserUid;

  const SavedAdsPage({
    super.key,
    required this.currentUserUid,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final networkStatus = ref.watch(networkAwareProvider);

    return MainTemplateScreen(
      screenLabel: AppLocalizations.of(context)!.lblSavedAds,
      screenContent: networkStatus == NetworkStatus.off
          ? Center(
              heightFactor: 6.h,
              child: NoInternetErrorMessage(context: context))
          : _SavedAdsPageBody(currentUserUid),
    );
  }
}

class _SavedAdsPageBody extends ConsumerStatefulWidget {
  final String currentUserUid;

  const _SavedAdsPageBody(
    this.currentUserUid,
  );

  @override
  ConsumerState<_SavedAdsPageBody> createState() => _StudentHomePageBodyState();
}

class _StudentHomePageBodyState extends ConsumerState<_SavedAdsPageBody> {
  List<String> savedAdsUids = [];
  List<AdData?> savedAds = [];
  bool isOnLoad = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ref
          .read(userNotifierProvider.notifier)
          .getUser(userUid: widget.currentUserUid);
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(userNotifierProvider, (previous, next) {
      next.maybeWhen(
          orElse: () => null,
          failedRead: () => showErrorSnackBar(context,
              AppLocalizations.of(context)!.lblFailOperation("reading user")),
          successfulRead: (userData) {
            savedAdsUids = userData.savedAds!;

            ref
                .read(userNotifierProvider.notifier)
                .getSavedAds(savedAds: savedAdsUids);
          },
          failedMultipleReads: () {
            showErrorSnackBar(context,
              AppLocalizations.of(context)!.lblFailOperation("retrieving saved ads"));
              setState(() {
              isOnLoad = false;
            });
          },
          successfulMultipleReads: (adsData) {
            savedAds = adsData;

            setState(() {
              isOnLoad = false;
            });
          });
    });

    return Expanded(
        child: Column(children: [
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 30.w),
        child: Text(AppLocalizations.of(context)!.lblSavedAdsDesc),
      ),
      SizedBox(height: 20.h),
      isOnLoad
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
              : savedAds.isEmpty
                  ? Expanded(
                      child: Center(
                      child: NoDataErrorMessage(
                        context: context,
                      ),
                    ))
                  : Expanded(
                      child: ListView.separated(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        itemCount: savedAds.length,
                        itemBuilder: (BuildContext context, int index) {
                          return AdsBox(
                              imageUrl: savedAds[index]!.photosURLs!.first,
                              city: savedAds[index]!.address.city,
                              street: savedAds[index]!.address.street,
                              price: savedAds[index]!.monthlyRent,
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FacilityDetailPage(
                                      isLogged:
                                          widget.currentUserUid.isNotEmpty,
                                      isStudent: true,
                                      isWizardPage: false,
                                      ad: savedAds[index]!,
                                      adUid: savedAds[index]!.uid,
                                      studentUid: widget.currentUserUid,
                                      isEditingMode: false,
                                    ),
                                  ),
                                );
                                // refreshing
                                if (true) {
                                  setState(() {
                                    isOnLoad = true;
                                  });
                                  await ref
                                    .read(userNotifierProvider.notifier)
                                    .getUser(userUid: widget.currentUserUid);
                                }
                              });
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return SizedBox(
                              height: 20.h); // Add padding between items
                        },
                      ),
                    )
    ]));
  }
}
