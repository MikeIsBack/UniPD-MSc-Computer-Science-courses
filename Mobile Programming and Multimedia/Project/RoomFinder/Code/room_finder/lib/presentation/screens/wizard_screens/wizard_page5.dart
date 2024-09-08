import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:room_finder/model/ad_model.dart';
import 'package:room_finder/model/user_model.dart';
import 'package:room_finder/presentation/components/alert_dialogs.dart';
import 'package:room_finder/presentation/components/buttons/circle_buttons.dart';
import 'package:room_finder/presentation/components/screens_templates.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:room_finder/presentation/screens/wizard_screens/wizard_page6.dart';

class WizardPage5 extends StatefulWidget {
  final Address address;
  final List<Room> rooms;
  final int rentersCapacity;
  final List<Renter> renters;
  final List<String> services;
  final UserData hostUser;
  final bool isEditingMode;
  final AdData? adToEdit;

  const WizardPage5(
      {super.key,
      required this.address,
      required this.rooms,
      required this.rentersCapacity,
      required this.renters,
      required this.services,
      required this.hostUser,
      required this.isEditingMode,
      this.adToEdit});

  @override
  State<WizardPage5> createState() => _WizardPage5State();
}

class _WizardPage5State extends State<WizardPage5> {
  late double _currentSliderValue;

  @override
  void initState() {
    super.initState();

    if (widget.isEditingMode) {
      _currentSliderValue = widget.adToEdit!.monthlyRent.toDouble();
    } else {
      _currentSliderValue = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WizardTemplateScreen(
      leftButton: DarkBackButton(onPressed: () {
        Navigator.of(context).pop();
      }),
      rightButton: CancelButton(onPressed: () {
        showOptionsDialog(
            context: context,
            androidDialog: ActionsAndroidDialog(
                title: AppLocalizations.of(context)!.lblWarningTitleDialog,
                content: Text(AppLocalizations.of(context)!.lblCancelWizard),
                context: context,
                onOk: () {
                  backToHostHomePage(context);
                },
                onCancel: () {
                  Navigator.of(context).pop();
                }),
            iosDialog: ActionsIosDialog(
                title: AppLocalizations.of(context)!.lblWarningTitleDialog,
                content: Text(AppLocalizations.of(context)!.lblCancelWizard),
                context: context,
                onOk: () {
                  backToHostHomePage(context);
                },
                onCancel: () {
                  Navigator.of(context).pop();
                }));
      }),
      rightButtonVisibility: true,
      screenTitle: AppLocalizations.of(context)!.lblSetMonthlyRent,
      dialogContent: AppLocalizations.of(context)!.lblContentDialogWizard5,
      currentStep: 5,
      btnNextLabel: AppLocalizations.of(context)!.btnNext,
      onNextPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => WizardPage6(
                    address: widget.address,
                    rooms: widget.rooms,
                    rentersCapacity: widget.rentersCapacity,
                    renters: widget.renters,
                    services: widget.services,
                    monthlyRent: _currentSliderValue.truncate(),
                    hostUser: widget.hostUser,
                    isEditingMode: widget.isEditingMode,
                    adToEdit: widget.adToEdit,
                  )),
        );
      },
      onOkDialog: () => Navigator.of(context).pop(),
      screenContent: Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 40.w, vertical: 20.h),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 1.w,
                ),
              ),
              child: Text(
                "${_currentSliderValue.round().toString()} €",
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontSize: 70.sp,
                    ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Slider(
                inactiveColor: Colors.grey,
                value: _currentSliderValue,
                max: 1000,
                divisions: 100,
                label: _currentSliderValue.round().toString(),
                onChanged: (double value) {
                  setState(() {
                    _currentSliderValue = value;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
