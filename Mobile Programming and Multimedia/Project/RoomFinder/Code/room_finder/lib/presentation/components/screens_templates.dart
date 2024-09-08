import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:room_finder/main.dart';
import 'package:room_finder/presentation/components/alert_dialogs.dart';
import 'package:room_finder/presentation/components/buttons/circle_buttons.dart';
import 'package:room_finder/presentation/components/buttons/rectangle_buttons.dart';
import 'package:room_finder/presentation/components/wizard_stepper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// [MainTemplateScreen] is an abstract class that represents the main template screen.
///
/// Implementing this class will create a screen with a bottom navigation bar.
///
/// * The [screenLabel] getter is used to set the title of the screen.
///
/// * The [screenContent] getter is used to set the content of the screen.
class MainTemplateScreen extends StatelessWidget {
  const MainTemplateScreen(
      {super.key, required this.screenLabel, required this.screenContent});

  final String screenLabel;
  final Widget screenContent;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 30.h),
          child: Align(
            alignment: Alignment.centerLeft,
            child: FittedBox(
              fit: BoxFit.fitWidth, 
              child: Text(screenLabel,
                  style: Theme.of(context).textTheme.displayMedium),
            ),
          ),
        ),
        screenContent,
      ],
    );
  }
}

/// [SecondaryTemplateScreen] is an abstract class that represents the secondary template screen.
///
/// The one that does not have a bottom navigation bar.
///
/// Implementing this class will create a screen without a bottom navigation bar.
///
/// The [leftHeaderWidget] is the widget placed on the left side of the header.
///
/// The [centerHeaderWidget] is the widget placed in the center of the header.
///
/// The [rightHeaderWidget] is the widget placed on the right side of the header.
///
/// The [rightHeaderWidgetVisibility] is used to determine if the right widget is visible or not, default is false. And in case it is false, the portion of the header where the right widget is placed will not empty. If [rightHeaderWidget] will be not passed and [rightHeaderWidgetVisibility] will be set to true, nothing will be shown.
class SecondaryTemplateScreen extends StatelessWidget {
  final Widget leftHeaderWidget;
  final Widget centerHeaderWidget;
  final Widget? rightHeaderWidget;
  final bool rightHeaderWidgetVisibility;

  final Widget content;

  const SecondaryTemplateScreen(
      {super.key,
      required this.leftHeaderWidget,
      required this.centerHeaderWidget,
      this.rightHeaderWidget,
      this.rightHeaderWidgetVisibility = false,
      required this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              _SecondaryScreenHeader(
                leftWidget: leftHeaderWidget,
                centerWidget: centerHeaderWidget,
                rightWidget: rightHeaderWidget,
                rightWidgetVisibility: rightHeaderWidgetVisibility,
              ),
              content,
            ],
          ),
        ),
      ),
    );
  }
}

/// [_SecondaryScreenHeader] is a class that represents the header of a screen withouth a bottom navigation bar.
///
/// The header is composed by a [leftWidget], a [centerWidget] and an optional [rightWidget].
///
/// [leftWidget] is the widget placed on the left side of the header.
///
/// [centerWidget] is the widget placed in the center of the header.
///
/// [rightWidget] is the widget placed on the right side of the header.
///
/// [rightWidgetVisibility] is used to determine if the right widget is visible or not, default is false. And in case it is false, the portion of the header where the right widget is placed will not empty.
class _SecondaryScreenHeader extends StatelessWidget {
  final Widget leftWidget;
  final Widget centerWidget;
  final Widget? rightWidget;
  final bool rightWidgetVisibility;

  const _SecondaryScreenHeader(
      {required this.leftWidget,
      required this.centerWidget,
      // ignore: unused_element
      this.rightWidget,
      // ignore: unused_element
      this.rightWidgetVisibility = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 1,
            child: leftWidget,
          ),
          Expanded(
            flex: 2,
            child: Align(alignment: Alignment.center, child: centerWidget),
          ),
          Expanded(
              flex: 1,
              child: Visibility(
                visible: rightWidgetVisibility,
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                child: rightWidget ?? const SizedBox.shrink(),
              )),
        ],
      ),
    );
  }
}

/// [WizardTemplateScreen] is a class that represents the wizard template screen.
///
/// This class is used to create a screen with a wizard stepper.
///
/// The [leftButton] is the widget placed on the left side of the header.
///
/// The [rightButton] is the optional widget placed on the right side of the header.
///
/// The [rightButtonVisibility] is used to determine if the right widget is visible or not, default is false. And in case it is false, the portion of the header where the right widget is placed will not empty.
///
/// The [screenTitle] is used to set the title of the screen.
///
/// The [screenContent] is used to set the content of the screen.
///
/// The [dialogContent] is used to set the content of the dialog.
///
/// The [currentStep] is used to set the current step of the wizard stepper.
///
/// The [btnNextLabel] is used to set the label of the next button.
///
/// The [onNextPressed] is used to set the onPressed method of the next button.
class WizardTemplateScreen extends StatelessWidget {
  final CustomButton leftButton;
  final CustomButton? rightButton;
  final bool rightButtonVisibility;

  final String screenTitle;
  final String? screenDesc;
  final Widget screenContent;

  final String dialogContent;

  final int currentStep;

  final String btnNextLabel;
  final void Function()? onNextPressed;

  final void Function() onOkDialog;

  const WizardTemplateScreen(
      {super.key,
      required this.leftButton,
      this.rightButton,
      this.rightButtonVisibility = false,
      required this.screenTitle,
      this.screenDesc,
      required this.screenContent,
      required this.dialogContent,
      required this.currentStep,
      required this.btnNextLabel,
      required this.onNextPressed,
      required this.onOkDialog});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 10.h, bottom: 30.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    leftButton,
                    Visibility(
                      visible: rightButtonVisibility,
                      maintainSize: true,
                      maintainAnimation: true,
                      maintainState: true,
                      child: rightButton ?? const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  Text(screenTitle,
                      style: Theme.of(context).textTheme.displaySmall!.copyWith(
                          fontSize: 24.sp, fontWeight: FontWeight.w600)),
                  Expanded(
                    child: InfoButton(
                      size: 20.w,
                      onPressed: () {
                        showOptionsDialog(
                          context: context,
                          androidDialog: ActionsAndroidDialog(
                            context: context,
                            title: AppLocalizations.of(context)!
                                .lblTitleDialogWizard,
                            content: Text(dialogContent),
                            onOk: onOkDialog,
                          ),
                          iosDialog: ActionsIosDialog(
                            context: context,
                            title: AppLocalizations.of(context)!
                                .lblTitleDialogWizard,
                            content: Text(dialogContent),
                            onOk: onOkDialog,
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
              screenDesc != null
                  ? Text(screenDesc!,
                      style: Theme.of(context).textTheme.bodyMedium)
                  : const SizedBox.shrink(),

              screenContent,

              Padding(
                padding: EdgeInsets.only(bottom: 30.h),
                child: WizardStepper(
                  context: context,
                  currentStep: currentStep,
                ),
              ),
            ],
          ),
        ),
      ),
      persistentFooterAlignment: AlignmentDirectional.center,
      persistentFooterButtons: [
        RectangleButton(
          label: btnNextLabel,
          onPressed: onNextPressed,
        ),
      ],
    );
  }
}

/// Method used to navigate back to the host home page from wizard pages.
void backToHostHomePage(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
        builder: (context) => const MyHomePage(),)
  );
}
