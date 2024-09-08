import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// [WizardStepper] is a widget that represents the steps of a wizard
/// [currentStep] is the current step in the wizard
/// if [currentStep] is 0 then the widget is not shown
/// if [currentStep] is 1 then the first step is the current step and so on until 7
/// if [currentStep] is greater than 7 then all steps are shown but no step is the current step
class WizardStepper extends StatelessWidget {
  final BuildContext context;
  final int currentStep;

  const WizardStepper({super.key, required this.context, this.currentStep = 0});

  @override
  Widget build(BuildContext context) {
    final steppers = List<Widget>.generate(
        7,
        (index) => _Stepper(
            context: context, currentStep: currentStep, numStep: index + 1));

    if (currentStep == 0) {
      return const SizedBox.shrink();
    } else {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: steppers,
      );
    }
  }
}

/// [_Stepper] is a private class that represents a single step in the wizard
/// [currentStep] is the current step in the wizard
/// [numStep] is the number of the step assigned to this widget
/// if [currentStep] is equal to [numStep] then that step is the current step
class _Stepper extends StatelessWidget {
  final BuildContext context;
  final int currentStep;
  final int numStep;

  const _Stepper(
      {required this.context,
      required this.currentStep,
      required this.numStep});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Divider(
        thickness: currentStep == numStep ? 6.h : 3.h,
        indent: 3.w,
        endIndent: 3.w,
        color: currentStep == numStep
            ? Theme.of(context).colorScheme.onSurface
            : Theme.of(context).colorScheme.onSurface.withOpacity(0.50),
      ),
    );
  }
}
