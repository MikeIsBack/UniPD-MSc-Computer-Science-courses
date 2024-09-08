import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:room_finder/presentation/components/buttons/circle_buttons.dart';
import 'package:room_finder/style/color_palette.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// This class contains the [SwitchTypeAccountButton] widget, which is a switch button that allows the user to select between two predifined options.
class SwitchTypeAccountButton extends StatefulWidget {
  final void Function() onInfo;
  final bool isStudentSelected;
  final void Function()? onStudent;
  final void Function()? onHost;

  const SwitchTypeAccountButton(
      {super.key, required this.onInfo, required this.isStudentSelected, required this.onStudent, required this.onHost});

  @override
  State<SwitchTypeAccountButton> createState() =>
      _SwitchTypeAccountButtonState();
}

class _SwitchTypeAccountButtonState extends State<SwitchTypeAccountButton> {
  // Widget state
  // bool isStudentSelected = true;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(children: [
        SizedBox(
          width: 335.w,
          child: Row(children: [
            Text(AppLocalizations.of(context)!.lblAccountType,
                style: Theme.of(context).textTheme.displaySmall),
            InfoButton(size: 30.w, onPressed: widget.onInfo)
          ]),
        ),
        SizedBox(
          height: 20.h,
        ),
        SizedBox(
          width: 335.w,
          height: 52.h,
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: widget.onStudent,
                  child: Container(
                    decoration: BoxDecoration(
                      color: widget.isStudentSelected
                          ? const Color.fromRGBO(24, 60, 129, 80)
                          : const Color.fromRGBO(198, 208, 250, 50),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8.0),
                        bottomLeft: Radius.circular(8.0),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Student',
                      style: TextStyle(
                        fontSize: 20,
                        color: widget.isStudentSelected
                            ? ColorPalette.aliceBlue
                            : ColorPalette.oxfordBlue,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: widget.onHost,
                  child: Container(
                    decoration: BoxDecoration(
                      color: widget.isStudentSelected
                          ? const Color.fromRGBO(198, 208, 250, 50)
                          : const Color.fromRGBO(24, 60, 129, 80),
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(8.0),
                        bottomRight: Radius.circular(8.0),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Host',
                      style: TextStyle(
                        fontSize: 20,
                        color: widget.isStudentSelected
                            ? ColorPalette.oxfordBlue
                            : ColorPalette.aliceBlue,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
      ]),
    );
  }
}
