import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:room_finder/model/ad_model.dart';
import 'package:room_finder/model/user_model.dart';
import 'package:room_finder/presentation/components/alert_dialogs.dart';
import 'package:room_finder/presentation/components/buttons/circle_buttons.dart';
import 'package:room_finder/presentation/components/input_text_fields.dart';
import 'package:room_finder/presentation/components/screens_templates.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:room_finder/presentation/screens/wizard_screens/wizard_page2.dart';

class WizardPage1 extends StatefulWidget {
  final UserData hostUser;
  final bool isEditingMode;
  final AdData? adToEdit;

  const WizardPage1(
      {super.key,
      required this.hostUser,
      required this.isEditingMode,
      this.adToEdit});

  @override
  State<WizardPage1> createState() => _WizardPage1State();
}

class _WizardPage1State extends State<WizardPage1> {
  late TextEditingController _cityController;
  late TextEditingController _streetController;

  bool _isCityValid = false;
  bool _isStreetValid = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEditingMode) {
      _cityController =
          TextEditingController(text: widget.adToEdit!.address.city);
      _streetController =
          TextEditingController(text: widget.adToEdit!.address.street);
      setState(() {
        _isCityValid = true;
        _isStreetValid = true;
      });
    } else {
      _cityController = TextEditingController();
      _streetController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _cityController.dispose();
    _streetController.dispose();
    super.dispose();
  }

  void _onCityValidityChanged(bool isValid) {
    setState(() {
      _isCityValid = isValid;
    });
  }

  void _onAddressValidityChanged(bool isValid) {
    setState(() {
      _isStreetValid = isValid;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) {
          return;
        }
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
      },
      child: WizardTemplateScreen(
        leftButton: CancelButton(onPressed: () {
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
        screenTitle: AppLocalizations.of(context)!.lblAddress,
        currentStep: 1,
        btnNextLabel: AppLocalizations.of(context)!.btnNext,
        dialogContent: AppLocalizations.of(context)!.lblContentDialogWizard1,
        onOkDialog: () => Navigator.of(context).pop(),
        onNextPressed: (_isCityValid && _isStreetValid)
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => WizardPage2(
                            address: Address(
                                street: _streetController.text,
                                city: _cityController.text),
                            hostUser: widget.hostUser,
                            isEditingMode: widget.isEditingMode,
                            adToEdit: widget.adToEdit,
                          )),
                );
              }
            : null,
        screenContent: Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.h, vertical: 20.h),
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Center(
                    child: Image(
                      image: const AssetImage('assets/images/Address-form.png'),
                      width: 200.w,
                      height: 200.h,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  StandardTextField(
                    label: AppLocalizations.of(context)!.lblCity,
                    onValueValidityChanged: _onCityValidityChanged,
                    controller: _cityController,
                  ),
                  SizedBox(height: 20.h),
                  StandardTextField(
                    label: AppLocalizations.of(context)!.lblStreet,
                    onValueValidityChanged: _onAddressValidityChanged,
                    controller: _streetController,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
