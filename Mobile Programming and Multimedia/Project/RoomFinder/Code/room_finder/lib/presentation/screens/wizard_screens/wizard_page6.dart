import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:room_finder/model/ad_model.dart';
import 'package:room_finder/model/user_model.dart';
import 'package:room_finder/presentation/components/alert_dialogs.dart';
import 'package:room_finder/presentation/components/buttons/circle_buttons.dart';
import 'package:room_finder/presentation/components/screens_templates.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:room_finder/presentation/screens/wizard_screens/wizard_page7.dart';

class WizardPage6 extends StatefulWidget {
  final Address address;
  final List<Room> rooms;
  final int rentersCapacity;
  final List<Renter> renters;
  final List<String> services;
  final int monthlyRent;
  final UserData hostUser;
  final bool isEditingMode;
  final AdData? adToEdit;

  const WizardPage6(
      {super.key,
      required this.address,
      required this.rooms,
      required this.rentersCapacity,
      required this.renters,
      required this.services,
      required this.monthlyRent,
      required this.hostUser,
      required this.isEditingMode,
      this.adToEdit});

  @override
  State<WizardPage6> createState() => _WizardPage6State();
}

class _WizardPage6State extends State<WizardPage6> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    if (widget.isEditingMode) {
      _controller = TextEditingController(text: widget.adToEdit!.name);
    } else {
      _controller = TextEditingController();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _controller,
      builder: (context, TextEditingValue value, _) {
        return WizardTemplateScreen(
          leftButton: DarkBackButton(onPressed: () {
            Navigator.of(context).pop();
          }),
          rightButton: CancelButton(onPressed: () {
            showOptionsDialog(
                context: context,
                androidDialog: ActionsAndroidDialog(
                    title: AppLocalizations.of(context)!.lblWarningTitleDialog,
                    content:
                        Text(AppLocalizations.of(context)!.lblCancelWizard),
                    context: context,
                    onOk: () {
                      backToHostHomePage(context);
                    },
                    onCancel: () {
                      Navigator.of(context).pop();
                    }),
                iosDialog: ActionsIosDialog(
                    title: AppLocalizations.of(context)!.lblWarningTitleDialog,
                    content:
                        Text(AppLocalizations.of(context)!.lblCancelWizard),
                    context: context,
                    onOk: () {
                      backToHostHomePage(context);
                    },
                    onCancel: () {
                      Navigator.of(context).pop();
                    }));
          }),
          rightButtonVisibility: true,
          screenTitle: AppLocalizations.of(context)!.lblAdsTitle,
          dialogContent: AppLocalizations.of(context)!.lblContentDialogWizard6,
          currentStep: 6,
          btnNextLabel: AppLocalizations.of(context)!.btnNext,
          onNextPressed: _controller.value.text.isEmpty
              ? null
              : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => WizardPage7(
                              address: widget.address,
                              rooms: widget.rooms,
                              rentersCapacity: widget.rentersCapacity,
                              renters: widget.renters,
                              services: widget.services,
                              monthlyRent: widget.monthlyRent,
                              name: _controller.text,
                              hostUser: widget.hostUser,
                              isEditingMode: widget.isEditingMode,
                              adToEdit: widget.adToEdit,
                            )),
                  );
                },
          onOkDialog: () => Navigator.of(context).pop(),
          screenContent: Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.h, vertical: 20.h),
              child: Column(
                children: [
                  TextField(
                    textAlign: TextAlign.start,
                    keyboardType: TextInputType.multiline,
                    maxLength: 20,
                    maxLines: 4,
                    controller: _controller,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: AppLocalizations.of(context)!.lblEnterTitle,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
