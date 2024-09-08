import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:room_finder/style/color_palette.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// The class [RenterBox] defines a widget that represents a current renter for a specific facility.
/// The widget is characterized by the following parameters:
/// - [name];
/// - [age];
/// - [interests];
/// - [facultyOfStudies];
/// - [contractDeadline] that determines the end of renter's current contract;
/// - [hostView], to allow or not editing on renters' information;
/// - [onRemovePressed] to define the remove functionality;
/// - [onEditPressed] to define the editing functionality.
abstract class RenterBox extends StatelessWidget {
  final String name;
  final int? age;
  final String? facultyOfStudies;
  final String? interests;
  final DateTime contractDeadline;
  final void Function()? onEditPressed;
  final void Function()? onRemovePressed;

  const RenterBox(
      {super.key,
      required this.name,
      this.age,
      this.facultyOfStudies,
      this.interests,
      required this.contractDeadline,
      this.onEditPressed,
      this.onRemovePressed,});

  bool get hostView;

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat('dd/MM/yyyy');
    final String formattedDate = formatter.format(contractDeadline);

    return Center(
      child: Container(
        width: 349.w,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: ColorPalette.lavenderBlue,
          borderRadius: BorderRadius.circular(15.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: Theme.of(context).textTheme.displaySmall),
            SizedBox(height: 10.h),
            if(age != null) ...[
              RichText(
                text: TextSpan(
                  text: AppLocalizations.of(context)!.lblRenterAge,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                  children: [
                    TextSpan(
                      text: '$age',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
            if(facultyOfStudies != null) ...[
              SizedBox(height: 10.h),
              RichText(
                text: TextSpan(
                  text: AppLocalizations.of(context)!.lblRenterStudies,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                  children: [
                    TextSpan(
                      text: facultyOfStudies,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
            if(interests != null) ...[
              SizedBox(height: 10.h),
              RichText(
                text: TextSpan(
                  text: AppLocalizations.of(context)!.lblRenterInterests,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                  children: [
                    TextSpan(
                      text: interests,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10.h),
            ],
            RichText(
              text: TextSpan(
                text: AppLocalizations.of(context)!.lblRenterContract,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                children: [
                  TextSpan(
                    text: formattedDate,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            if (hostView) ...[
              SizedBox(
                height: 20.h,
              ),
              const Divider(
                color: ColorPalette.oxfordBlue,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      onRemovePressed!();
                    },
                    child: Text(
                      AppLocalizations.of(context)!.btnRemove,
                      style: TextStyle(
                          color: Colors.red,
                          fontSize: 16.h,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.red),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      onEditPressed!();
                    },
                    child: Text(
                      AppLocalizations.of(context)!.btnEdit,
                      style: TextStyle(
                        color: ColorPalette.oxfordBlue,
                        fontSize: 16.h,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class StudentRenterBox extends RenterBox {
  const StudentRenterBox(
      {super.key,
      required super.name,
      required super.age,
      required super.facultyOfStudies,
      required super.interests,
      required super.contractDeadline,
      super.onEditPressed,
      super.onRemovePressed,});

  @override
  bool get hostView => false;
}

class HostRenterBox extends RenterBox {
  const HostRenterBox(
      {super.key,
      required super.name,
      required super.age,
      required super.facultyOfStudies,
      required super.interests,
      required super.contractDeadline,
      super.onEditPressed,
      super.onRemovePressed,});

  @override
  bool get hostView => true;
}

class HostFacilityDetailPageRenterBox extends RenterBox {
  const HostFacilityDetailPageRenterBox(
      {super.key,
      required super.name,
      required super.contractDeadline});

  @override
  bool get hostView => false;
}
