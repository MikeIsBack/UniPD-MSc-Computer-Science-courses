import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:room_finder/model/ad_model.dart';
import 'package:room_finder/model/user_model.dart';
import 'package:room_finder/presentation/components/add_on.dart';
import 'package:room_finder/presentation/components/alert_dialogs.dart';
import 'package:room_finder/presentation/components/buttons/circle_buttons.dart';
import 'package:room_finder/presentation/components/room_option.dart';
import 'package:room_finder/presentation/components/screens_templates.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:room_finder/presentation/screens/wizard_screens/wizard_page3.dart';

class WizardPage2 extends StatefulWidget {
  final Address address;
  final UserData hostUser;
  final bool isEditingMode;
  final AdData? adToEdit;

  const WizardPage2(
      {super.key,
      required this.address,
      required this.hostUser,
      required this.isEditingMode,
      this.adToEdit});

  @override
  State<WizardPage2> createState() => _WizardPage2State();
}

class _WizardPage2State extends State<WizardPage2> {
  late TextEditingController _controller;

  late List<Room> _rooms;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    if (!widget.isEditingMode) {
      _rooms = <Room>[];
    } else {
      _rooms = widget.adToEdit!.rooms;
      setState(() {});
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!widget.isEditingMode) {
      _rooms = <Room>[
        Room(name: AppLocalizations.of(context)!.lblBathrooms, quantity: 0),
        Room(name: AppLocalizations.of(context)!.lblKitchens, quantity: 0),
        Room(name: AppLocalizations.of(context)!.lblLivingRoom, quantity: 0),
        Bedroom(
            name: AppLocalizations.of(context)!.lblBedrooms,
            quantity: 0,
            numBeds: []),
      ];
    }
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
      screenTitle: AppLocalizations.of(context)!.lblSetRooms,
      dialogContent: AppLocalizations.of(context)!.lblContentDialogWizard2,
      onOkDialog: () => Navigator.of(context).pop(),
      currentStep: 2,
      btnNextLabel: AppLocalizations.of(context)!.btnNext,
      onNextPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => WizardPage3(
                    address: widget.address,
                    rooms: _rooms,
                    hostUser: widget.hostUser,
                    isEditingMode: widget.isEditingMode,
                    adToEdit: widget.adToEdit,
                  )),
        );
      },
      screenContent: Expanded(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.h, vertical: 20.h),
          child: Column(
            children: <Widget>[
              AddOn(
                  label: AppLocalizations.of(context)!.lblAddRooms,
                  onPressed: () {
                    _addRoom(context);
                  }),
              SizedBox(height: 20.h),
              Expanded(
                child: ListView.separated(
                    itemCount: _rooms.length,
                    separatorBuilder: (BuildContext context, int index) {
                      return SizedBox(
                          height: 20.h); // Add padding between items
                    },
                    itemBuilder: (context, index) {
                      return RoomOption(
                        roomName: _rooms[index].name,
                        roomCounter: _rooms[index].quantity,
                        onRoomIncrement: () => setState(() {
                          _rooms[index].quantity++;
                          if (_rooms[index].runtimeType == Bedroom) {
                            (_rooms[index] as Bedroom).numBeds.add(1);
                          }
                        }),
                        onRoomDecrement: () {
                          if (_rooms[index].quantity > 0) {
                            setState(() {
                              _rooms[index].quantity--;
                            });
                            if (_rooms[index].runtimeType == Bedroom) {
                              (_rooms[index] as Bedroom).numBeds.remove(
                                  (_rooms[index] as Bedroom).numBeds.last);
                            }
                          }
                        },
                        bedCounter: _rooms[index].runtimeType == Bedroom
                            ? (_rooms[index] as Bedroom).numBeds
                            : [],
                        onBedDecrement: (bedIndex) {
                          if (_rooms[index].runtimeType == Bedroom &&
                              (_rooms[index] as Bedroom).numBeds[bedIndex] >
                                  0) {
                            setState(() {
                              _rooms[index].runtimeType == Bedroom
                                  ? (_rooms[index] as Bedroom)
                                      .numBeds[bedIndex]--
                                  : null;
                            });
                          }
                        },
                        onBedIncrement: (bedIndex) => setState(() {
                          (_rooms[index] as Bedroom).numBeds[bedIndex]++;
                        }),
                      );
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addRoom(BuildContext context) {
    return showOptionsDialog(
        context: context,
        androidDialog: ActionsAndroidDialog(
            context: context,
            title: AppLocalizations.of(context)!.lblAddNewRoom,
            content: TextField(
              controller: _controller,
            ),
            onCancel: () {
              _onCancel(context);
            },
            onOk: () {
              _onOk(context);
            }),
        iosDialog: ActionsIosDialog(
            context: context,
            title: AppLocalizations.of(context)!.lblAddNewRoom,
            content: CupertinoTextField(
              controller: _controller,
            ),
            onCancel: () {
              _onCancel(context);
            },
            onOk: () {
              _onOk(context);
            }));
  }

  void _onOk(BuildContext context) {
    setState(() {
      _rooms.add(Room(name: _controller.text, quantity: 0));
    });
    _controller.clear();
    Navigator.of(context).pop();
  }

  void _onCancel(BuildContext context) {
    _controller.clear();
    Navigator.of(context).pop();
  }
}
