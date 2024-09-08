import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

abstract class ErrorMessage extends StatelessWidget {
  const ErrorMessage({super.key});

  String get message;
  IconData get icon;
  String get desc;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.error,
          size: 50.sp,
        ),
        Align(
          alignment: Alignment.center,
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
                text: message,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp),
                children: [
                  TextSpan(
                    text: desc,
                    style: const TextStyle(fontWeight: FontWeight.normal),
                  ),
                ]),
          ),
        ),
      ],
    );
  }
}

class NoInternetErrorMessage extends ErrorMessage {
  final BuildContext context;

  const NoInternetErrorMessage({super.key, required this.context});

  @override
  String get message => AppLocalizations.of(context)!.lblConnectioError;

  @override
  IconData get icon => Icons.wifi_off;

  @override
  String get desc =>
      "\n${AppLocalizations.of(context)!.lblConnectionErrorDesc}";
}

class NoDataErrorMessage extends ErrorMessage {
  final BuildContext context;

  const NoDataErrorMessage({super.key, required this.context});

  @override
  String get message => AppLocalizations.of(context)!.lblNoResults;

  @override
  IconData get icon => Icons.error_outline;

  @override
  String get desc => '';
}
