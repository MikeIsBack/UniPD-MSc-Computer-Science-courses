import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:room_finder/model/ad_model.dart';
import 'package:room_finder/model/user_model.dart';
import 'package:room_finder/presentation/components/add_on.dart';
import 'package:room_finder/presentation/components/alert_dialogs.dart';
import 'package:room_finder/presentation/components/amenities_option.dart';
import 'package:room_finder/presentation/components/buttons/circle_buttons.dart';
import 'package:room_finder/presentation/components/screens_templates.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:room_finder/presentation/screens/wizard_screens/wizard_page5.dart';

class WizardPage4 extends StatefulWidget {
  final Address address;
  final List<Room> rooms;
  final int rentersCapacity;
  final List<Renter> renters;
  final UserData hostUser;
  final bool isEditingMode;
  final AdData? adToEdit;

  const WizardPage4(
      {super.key,
      required this.address,
      required this.rooms,
      required this.rentersCapacity,
      required this.renters,
      required this.hostUser,
      required this.isEditingMode,
      this.adToEdit});

  @override
  State<WizardPage4> createState() => _WizardPage4State();
}

class _WizardPage4State extends State<WizardPage4> {
  late TextEditingController _controller = TextEditingController();
  late List<AmenitiesOption> _amenities;
  late Map<String, bool> _amenitiesSwitches;

  @override
  void initState() {
    super.initState();
    if (widget.isEditingMode) {
      _amenitiesSwitches = {
        for (var item in widget.adToEdit!.services) item: true
      };
    } else {
      _amenities = <AmenitiesOption>[];
      _amenitiesSwitches = {};
    }
    _controller = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_amenitiesSwitches.keys
        .contains(AppLocalizations.of(context)!.lblWiFi)) {
      _amenitiesSwitches
          .addEntries({AppLocalizations.of(context)!.lblWiFi: false}.entries);
    }
    if (!_amenitiesSwitches.keys
        .contains(AppLocalizations.of(context)!.lblDishwasher)) {
      _amenitiesSwitches
          .addEntries({AppLocalizations.of(context)!.lblDishwasher: false}.entries);
    }
    if (!_amenitiesSwitches.keys
        .contains(AppLocalizations.of(context)!.lblWashingMachine)) {
      _amenitiesSwitches
          .addEntries({AppLocalizations.of(context)!.lblWashingMachine: false}.entries);
    }
    if (!_amenitiesSwitches.keys
        .contains(AppLocalizations.of(context)!.lblDedicatedParking)) {
      _amenitiesSwitches
          .addEntries({AppLocalizations.of(context)!.lblDedicatedParking: false}.entries);
    }
    if (!_amenitiesSwitches.keys
        .contains(AppLocalizations.of(context)!.lblAirConditioning)) {
      _amenitiesSwitches
          .addEntries({AppLocalizations.of(context)!.lblAirConditioning: false}.entries);
    }

    _amenities = _amenitiesSwitches.entries
        .map((entry) => AmenitiesOption(
              label: entry.key,
              isChecked: entry.value,
              onChanged: (value) {
                setState(() {
                  _amenitiesSwitches[entry.key] = value;
                });
              },
            ))
        .toList();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
      screenTitle: AppLocalizations.of(context)!.lblAmenitieService,
      dialogContent: AppLocalizations.of(context)!.lblContentDialogWizard4,
      currentStep: 4,
      btnNextLabel: AppLocalizations.of(context)!.btnNext,
      onNextPressed: _amenitiesSwitches.values.contains(true)
          ? () {
              List<String> services = [];
              // get selected services
              for (int i = 0;
                  i < _amenitiesSwitches.values.toList().length;
                  i++) {
                if (_amenitiesSwitches.values.toList()[i]) {
                  services.add(_amenitiesSwitches.keys.toList()[i]);
                }
              }

              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => WizardPage5(
                          address: widget.address,
                          rooms: widget.rooms,
                          rentersCapacity: widget.rentersCapacity,
                          renters: widget.renters,
                          services: services,
                          hostUser: widget.hostUser,
                          isEditingMode: widget.isEditingMode,
                          adToEdit: widget.adToEdit,
                        )),
              );
            }
          : null,
      onOkDialog: () => Navigator.of(context).pop(),
      screenContent: Expanded(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20.h),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.h),
                child: AddOn(
                  label: AppLocalizations.of(context)!.lblAddService,
                  onPressed: () {
                    _addService(context);
                  },
                ),
              ),
              SizedBox(height: 20.h),
              Expanded(
                child: ListView.separated(
                  itemCount: _amenities.length,
                  separatorBuilder: (BuildContext context, int index) {
                    return SizedBox(height: 5.h); // Add padding between items
                  },
                  itemBuilder: (context, index) {
                    return AmenitiesOption(
                      label: _amenitiesSwitches.keys.elementAt(index),
                      onChanged: (value) {
                        setState(() {
                          _amenitiesSwitches[
                              _amenitiesSwitches.keys.elementAt(index)] = value;
                        });
                      },
                      isChecked: _amenitiesSwitches.values.elementAt(index),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addService(BuildContext context) {
    return showOptionsDialog(
      context: context,
      androidDialog: ActionsAndroidDialog(
          title: AppLocalizations.of(context)!.lblAddNewService,
          content: TextField(
            controller: _controller,
          ),
          context: context,
          onOk: () => _onOk(context),
          onCancel: () => _onCancel(context)),
      iosDialog: ActionsIosDialog(
          title: AppLocalizations.of(context)!.lblAddNewService,
          content: CupertinoTextField(
            controller: _controller,
          ),
          context: context,
          onOk: () => _onOk(context),
          onCancel: () => _onCancel(context)),
    );
  }

  void _onOk(BuildContext context) {
    setState(() {
      if (_controller.text.isNotEmpty) {
        _amenitiesSwitches.addEntries({_controller.text: true}.entries);
        _amenities.add(AmenitiesOption(
          label: _amenitiesSwitches.keys.last,
          isChecked: _amenitiesSwitches.values.last,
          onChanged: (value) {
            setState(() {
              _amenitiesSwitches[_amenitiesSwitches.keys.last] = value;
            });
          },
        ));
      }
    });
    _controller.clear();
    Navigator.of(context).pop();
  }

  void _onCancel(BuildContext context) {
    _controller.clear();
    Navigator.of(context).pop();
  }
}
