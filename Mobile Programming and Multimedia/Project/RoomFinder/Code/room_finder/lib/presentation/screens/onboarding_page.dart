import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:room_finder/main.dart';
import 'package:room_finder/presentation/components/buttons/rectangle_buttons.dart';
import 'package:room_finder/style/color_palette.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:room_finder/util/shared_preferences.dart';

/// The on boarding page of the application
///
/// This page is shown to the user when they first open the application.
///
/// The user is shown a welcome message and an image.
///
/// The user is also shown a message about the application and a button to start using the application.
class OnBoardingPage extends StatelessWidget {
  const OnBoardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              Text(
                AppLocalizations.of(context)!.lblWelcome,
                style: Theme.of(context).textTheme.displaySmall!.copyWith(
                      fontSize: 24.sp,
                      color: ColorPalette.oxfordBlue,
                    ),
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 2),
              Image(
                image: const AssetImage('assets/images/Welcome-image.png'),
                width: 269.w,
                height: 251.h,
              ),
              const Spacer(flex: 2),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 50.w),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                      text: AppLocalizations.of(context)!.lblWelcomeMessage1,
                      style: Theme.of(context).textTheme.bodyMedium,
                      children: [
                        TextSpan(
                          text:
                              "\n\n${AppLocalizations.of(context)!.lblWelcomeMessage2}",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        TextSpan(
                          text:
                              "\n\n${AppLocalizations.of(context)!.lblWelcomeMessage3}",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        TextSpan(
                          text:
                              AppLocalizations.of(context)!.lblWelcomeMessage4,
                          style:
                              Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        TextSpan(
                          text:
                              AppLocalizations.of(context)!.lblWelcomeMessage5,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ]),
                ),
              ),
              const Spacer(flex: 2),
              RectangleButton(
                  label: AppLocalizations.of(context)!.btnStart,
                  onPressed: () async {
                    // Set the on boarding screen as shown
                    await OnBoardingScreenPreferences.setWasShown();

                    if (context.mounted) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const MyHomePage(),
                        ),
                      );
                    }
                  }),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}
