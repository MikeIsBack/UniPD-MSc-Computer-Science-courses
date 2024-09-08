import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:room_finder/style/color_palette.dart';

/// The class [AmenitiesOption] is a widget that represents an option for the amenities that a room can have.
/// It contains a label and a checkbox to select the option.
class AmenitiesOption extends StatelessWidget {
  final String label;
  final bool isChecked;
  final ValueChanged<bool> onChanged;

  const AmenitiesOption(
      {super.key, required this.label, required this.onChanged, required this.isChecked});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(left: 33.w, right: 33.w),
          child: CheckboxListTile(
            title: Text(label),
            value: isChecked,
            onChanged: (bool? value) {
              onChanged(value!);
            },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.r),
                ),
          ),
        ),
        Divider(
          indent: 30.w,
          endIndent: 30.w,
          color: ColorPalette.blueberry,
        ),
      ],
    );
  }
}
