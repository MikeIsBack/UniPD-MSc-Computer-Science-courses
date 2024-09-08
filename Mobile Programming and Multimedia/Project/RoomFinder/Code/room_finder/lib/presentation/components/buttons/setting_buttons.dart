import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:room_finder/style/color_palette.dart';

/// The class [SettingButtons] is a widget that represents buttons for the settings page.
/// It contains a label and an icon to represent a setting.
class SettingButtons extends StatelessWidget {
  final void Function()? onPressed;
  final String label;
  final IconData icon;

  const SettingButtons(
      {super.key,
      required this.onPressed,
      required this.label,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextButton(
          onPressed: onPressed,
          child: Row(
            children: [
              Icon(icon),
              SizedBox(width: 10.w),
              Text(
                label,
                style: TextStyle(
                  color: ColorPalette.oxfordBlue,
                  fontSize: 18.sp,
                ),
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios),
            ],
          ),
        ),
        Divider(
          indent: 5.w,
          endIndent: 5.w,
          color: ColorPalette.blueberry,
        ),
      ],
    );
  }
}
