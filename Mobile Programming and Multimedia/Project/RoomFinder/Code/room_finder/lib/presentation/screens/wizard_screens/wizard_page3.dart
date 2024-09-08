import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:room_finder/model/ad_model.dart';
import 'package:room_finder/model/user_model.dart';
import 'package:room_finder/presentation/components/add_on.dart';
import 'package:room_finder/presentation/components/alert_dialogs.dart';
import 'package:room_finder/presentation/components/base_panel.dart';
import 'package:room_finder/presentation/components/buttons/circle_buttons.dart';
import 'package:room_finder/presentation/components/renter_box.dart';
import 'package:room_finder/presentation/components/renter_panel.dart';
import 'package:room_finder/presentation/components/screens_templates.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:room_finder/presentation/screens/wizard_screens/wizard_page4.dart';
import 'package:room_finder/style/color_palette.dart';

class WizardPage3 extends StatefulWidget {
  final Address address;
  final List<Room> rooms;
  final UserData hostUser;
  final bool isEditingMode;
  final AdData? adToEdit;

  const WizardPage3(
      {super.key,
      required this.address,
      required this.rooms,
      required this.hostUser,
      required this.isEditingMode,
      this.adToEdit});

  @override
  State<WizardPage3> createState() => _WizardPage3State();
}

class _WizardPage3State extends State<WizardPage3> {
  late TextEditingController nameController;
  late TextEditingController studiesController;
  late TextEditingController interestsController;
  late TextEditingController ageController;
  late DateTime selectedDate;

  late int maxRenter;

  late List<Renter> _renters;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController();
    studiesController = TextEditingController();
    interestsController = TextEditingController();
    ageController = TextEditingController();

    selectedDate = DateTime.now();

    if (widget.isEditingMode) {
      _renters = widget.adToEdit!.renters;

      maxRenter = widget.adToEdit!.rentersCapacity;
    } else {
      _renters = <Renter>[];
      
      maxRenter = 0;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    studiesController.dispose();
    interestsController.dispose();
    super.dispose();
  }

  void _increment() {
    setState(() {
      maxRenter++;
    });
  }

  void _decrement() {
    setState(() {
      if (maxRenter > 0) maxRenter--;
    });
  }

  bool _isMaxRenterReached() {
    return maxRenter == 0 || maxRenter == _renters.length;
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
      screenTitle: AppLocalizations.of(context)!.lblManageRenters,
      dialogContent: AppLocalizations.of(context)!.lblContentDialogWizard3,
      currentStep: 3,
      btnNextLabel: AppLocalizations.of(context)!.btnNext,
      onNextPressed: maxRenter == 0
          ? null
          : () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => WizardPage4(
                          address: widget.address,
                          rooms: widget.rooms,
                          rentersCapacity: maxRenter,
                          renters: _renters,
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
            children: <Widget>[
              _MaxRenterSetter(
                maxRenter: maxRenter,
                onAddPressed: _increment,
                onRemovePressed: _decrement,
              ),
              SizedBox(height: 60.h),
              AddOn(
                  label: AppLocalizations.of(context)!.lblAddCurrentRenters,
                  // disable the button when the maxRenter is reached or when the maxRenter is 0
                  onPressed: _isMaxRenterReached()
                      ? null
                      : () {
                          // show the panel to add a new renter
                          _addNewRenter(context);
                        }),
              SizedBox(height: 30.h),
              Expanded(
                child: ListView.separated(
                    itemCount: _renters.length,
                    separatorBuilder: (BuildContext context, int index) {
                      return SizedBox(
                          height: 20.h); // Add padding between items
                    },
                    itemBuilder: (context, index) {
                      return HostRenterBox(
                        name: _renters[index].name,
                        age: _renters[index].age,
                        facultyOfStudies: _renters[index].facultyOfStudies,
                        interests: _renters[index].interests,
                        contractDeadline: _renters[index].contractDeadline,
                        onEditPressed: () {
                          // set the text fields with the current values
                          nameController.text = _renters[index].name;
                          studiesController.text =
                              _renters[index].facultyOfStudies;
                          interestsController.text = _renters[index].interests;
                          selectedDate = _renters[index].contractDeadline;
                          ageController.text = _renters[index].age.toString();
                          // show the panel to edit the fields
                          _editRenter(context, index);
                        },
                        // remove the renter from the list
                        onRemovePressed: () {
                          setState(() {
                            _renters.removeAt(index);
                          });
                        },
                      );
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<dynamic> _editRenter(BuildContext context, int index) {
    return showModalPanel(
        context: context,
        panel: RenterPanel(
            context: context,
            title: AppLocalizations.of(context)!.lblAddEditRenters,
            btnLabel: AppLocalizations.of(context)!.btnConfirm,
            onDateChanged: (DateTime? date) {
              setState(() {
                selectedDate = date!;
              });
            },
            onConfirmPressed: () {
              setState(() {
                _renters[index] = Renter(
                  name: nameController.text,
                  facultyOfStudies: studiesController.text,
                  interests: interestsController.text,
                  contractDeadline: selectedDate,
                  age: int.parse(ageController.text),
                );
              });

              nameController.clear();
              studiesController.clear();
              interestsController.clear();
              ageController.clear();

              Navigator.of(context).pop();
            },
            nameController: nameController,
            studiesController: studiesController,
            interestsController: interestsController,
            ageController: ageController,
            selectedDate: selectedDate,
            onClosedPressed: () {
              nameController.clear();
              studiesController.clear();
              interestsController.clear();

              Navigator.of(context).pop();
            }));
  }

  Future<dynamic> _addNewRenter(BuildContext context) {
    return showModalPanel(
        context: context,
        panel: RenterPanel(
            context: context,
            title: AppLocalizations.of(context)!.lblAddEditRenters,
            btnLabel: AppLocalizations.of(context)!.btnConfirm,
            onDateChanged: (DateTime? date) {
              setState(() {
                selectedDate = date!;
              });
            },
            onConfirmPressed: () {
              setState(() {
                _renters.add(Renter(
                  name: nameController.text,
                  facultyOfStudies: studiesController.text,
                  interests: interestsController.text,
                  contractDeadline: selectedDate,
                  age: int.parse(ageController.text),
                ));
              });

              nameController.clear();
              studiesController.clear();
              interestsController.clear();
              ageController.clear();

              Navigator.of(context).pop();
            },
            nameController: nameController,
            studiesController: studiesController,
            interestsController: interestsController,
            ageController: ageController,
            selectedDate: selectedDate,
            onClosedPressed: () {
              nameController.clear();
              studiesController.clear();
              interestsController.clear();
              Navigator.of(context).pop();
            }));
  }
}

// ignore: must_be_immutable
class _MaxRenterSetter extends StatefulWidget {
  int maxRenter;
  final void Function() onAddPressed;
  final void Function() onRemovePressed;

  _MaxRenterSetter(
      {required this.maxRenter,
      required this.onAddPressed,
      required this.onRemovePressed});

  @override
  State<_MaxRenterSetter> createState() => _MaxRenterSetterState();
}

class _MaxRenterSetterState extends State<_MaxRenterSetter> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        AddRemoveButton(
            isAddButton: false, size: 30, onPressed: widget.onRemovePressed),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: ColorPalette.oxfordBlue,
            ),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 15.h),
            child: Text("${widget.maxRenter}"),
          ),
        ),
        AddRemoveButton(
            isAddButton: true, size: 30, onPressed: widget.onAddPressed),
      ],
    );
  }
}
