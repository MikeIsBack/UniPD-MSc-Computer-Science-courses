import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:room_finder/model/ad_model.dart';
import 'package:room_finder/presentation/components/buttons/circle_buttons.dart';
import 'package:room_finder/presentation/components/error_messages.dart';
import 'package:room_finder/presentation/components/renter_box.dart';
import 'package:room_finder/presentation/components/screens_templates.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:room_finder/util/network_handler.dart';

class CurrentRentersPage extends ConsumerWidget {
  final String facilityName;
  final Address facilityAddress;
  final int facilityMaximumRentersCapacity;
  final List<Renter> facilityRenters;

  const CurrentRentersPage({
    super.key,
    required this.facilityName,
    required this.facilityAddress,
    required this.facilityMaximumRentersCapacity,
    required this.facilityRenters});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var connectivityStatusProvider = ref.watch(networkAwareProvider);
    bool isOffline = connectivityStatusProvider == NetworkStatus.off;

    return SecondaryTemplateScreen(
      leftHeaderWidget: DarkBackButton(onPressed: () => Navigator.pop(context)),
      centerHeaderWidget: Align(
        alignment: Alignment.center,
        child: isOffline
            ? const SizedBox.shrink()
            : RichText(
                text: TextSpan(
                  text: facilityName,
                  style: Theme.of(context).textTheme.displaySmall,
                  children: [
                    TextSpan(
                      text: "\n${facilityAddress.city} - ${facilityAddress.street}",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
      ),
      content: isOffline
          ? Expanded(
              child: NoInternetErrorMessage(
                context: context,
              ),
            )
          : _CurrentRentersBody(facilityMaximumRentersCapacity, facilityRenters),
    );
  }
}

class _CurrentRentersBody extends StatelessWidget {
  final int maxRenters;
  final List<Renter> renters;
  
  const _CurrentRentersBody(
    this.maxRenters,
    this.renters
  );

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.w),
            child: Column(
              children: [
                SizedBox(height: 30.h),
                Text(
                  AppLocalizations.of(context)!.lblCurrRentDesc,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30.h),
                Text(AppLocalizations.of(context)!.lblCurrentRenters(renters.length, maxRenters),
                    style: Theme.of(context).textTheme.displaySmall),
                SizedBox(height: 20.h),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.all(20.w),
              itemCount: renters.length,
              itemBuilder: (BuildContext context, int index) {
                return StudentRenterBox(
                  name: renters[index].name,
                  age: renters[index].age,
                  facultyOfStudies: renters[index].facultyOfStudies,
                  interests: renters[index].interests,
                  contractDeadline: renters[index].contractDeadline,
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return SizedBox(height: 20.h); 
              },
            ),
          ),
        ],
      ),
    );
  }
}
