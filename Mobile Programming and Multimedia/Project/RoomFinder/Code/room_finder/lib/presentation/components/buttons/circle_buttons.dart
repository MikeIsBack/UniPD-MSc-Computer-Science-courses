import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:room_finder/style/color_palette.dart';

/// This file contains the implementations of all circle buttons used in the app.

/// This abstract class [CustomButton] defines a standard fixed-size circle button that you can find in the app. The only things that you need to define when you try to implement this class are the following parameters:
/// - [buttonColor], the background color of the button;
/// - [icon], the button icon;
/// - [iconColor], the color of the icon;
/// - [onPressed], the onPressed method.
abstract class CustomButton extends StatelessWidget {
  final void Function() onPressed;

  const CustomButton({
    super.key,
    required this.onPressed,
  });

  Color get buttonColor;
  IconData get icon;
  Color get iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 4.r,
            blurRadius: 60.r,
          )
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          shape: const CircleBorder(),
          minimumSize: Size(50.w, 50.h), // Fixed dimensions
        ),
        onPressed: onPressed,
        child: Icon(icon, color: iconColor, size: 30.w),
      ),
    );
  }
}

// Back button (Light version)
class LightBackButton extends CustomButton {
  const LightBackButton({super.key, required super.onPressed});

  @override
  Color get buttonColor => ColorPalette.aliceBlue;

  @override
  IconData get icon => Icons.arrow_back;

  @override
  Color get iconColor => ColorPalette.oxfordBlue;
}

// Back button (Dark version)
class DarkBackButton extends CustomButton {
  const DarkBackButton({super.key, required super.onPressed});

  @override
  Color get buttonColor => const Color.fromRGBO(24, 60, 129, 90);

  @override
  IconData get icon => Icons.arrow_back;

  @override
  Color get iconColor => ColorPalette.aliceBlue;
}

// Filter button
class FilterButton extends CustomButton {
  const FilterButton({super.key, required super.onPressed});

  @override
  Color get buttonColor => const Color.fromRGBO(24, 60, 129, 90);

  @override
  IconData get icon => Icons.filter_alt_outlined;

  @override
  Color get iconColor => ColorPalette.aliceBlue;
}

// Cancel button
class CancelButton extends CustomButton {
  const CancelButton({super.key, required super.onPressed});

  @override
  Color get buttonColor => const Color.fromRGBO(24, 60, 129, 90);

  @override
  IconData get icon => Icons.close;

  @override
  Color get iconColor => ColorPalette.aliceBlue;
}

// Edit button
class EditButton extends CustomButton {
  const EditButton({super.key, required super.onPressed});

  @override
  Color get buttonColor => ColorPalette.aliceBlue;

  @override
  IconData get icon => Icons.mode_edit_outlined;

  @override
  Color get iconColor => ColorPalette.oxfordBlue;
}

// Delete button
class DeleteButton extends CustomButton {
  const DeleteButton({super.key, required super.onPressed});

  @override
  Color get buttonColor => ColorPalette.aliceBlue;

  @override
  IconData get icon => Icons.delete_outline_outlined;

  @override
  Color get iconColor => Colors.red;
}

/// The [InfoButton] class defines an helper button, placed near a label, that is used to get more information about the content of the page in which the user is.
/// When you try to build an [InfoButton] widget you need to specify parameters:
/// - [size], the size of the button;
/// - [onPressed], the onPressed method.
class InfoButton extends StatelessWidget {
  const InfoButton({
    super.key,
    required this.size,
    required this.onPressed,
  });

  final double size;
  final void Function() onPressed;

  final Color buttonColor = ColorPalette.aliceBlue;
  final IconData icon = Icons.question_mark_outlined;
  final Color iconColor = ColorPalette.oxfordBlue;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, color: iconColor, size: size - 5),
      style: IconButton.styleFrom(
        padding: EdgeInsets.zero,
        shape: CircleBorder(
          side: BorderSide(
            color: iconColor,
            width: 2.w,
          ),
        ),
        minimumSize: Size(size.w, size.h),
      ),
    );
  }
}

/// The [AddRemoveButton] class defines a button used to manage the quantity of a specific item in the app (for instance, the number of beds in a facility).
/// When you try to build an [AddRemoveButton] widget you need to specify some parameters:
/// - [isAddButton], used to istantiate an add button (= true) or a remove button (= false);
/// - [size], the size of the button;
/// - [onPressed], the onPressed method.
class AddRemoveButton extends StatelessWidget {
  const AddRemoveButton({
    super.key,
    required this.isAddButton,
    required this.size,
    required this.onPressed,
  });

  final bool isAddButton;
  final double size;
  final void Function()? onPressed;

  final Color disabledIconColor = Colors.grey;
  final Color enableIconColor = ColorPalette.oxfordBlue;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(
          isAddButton ? Icons.add_circle_outline : Icons.remove_circle_outline),
      style: ButtonStyle(
        iconSize: WidgetStateProperty.all<double>(size.w),
        minimumSize: WidgetStateProperty.all<Size>(Size(size.w, size.h)),
        iconColor: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return disabledIconColor;
          }
          return enableIconColor;
        }),
      ),
    );
  }
}

/// The [LogoutButton] class defines a button used to logout from the app.
/// When you try to build an [LogoutButton] widget you need to specify the [onPressed] parameter corresponding to the onPressed method.
class LogoutButton extends StatelessWidget {
  const LogoutButton({
    super.key,
    required this.onPressed,
  });

  final void Function() onPressed;

  final Color buttonColor = Colors.white;
  final IconData icon = Icons.logout_outlined;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          spreadRadius: 4.r,
          blurRadius: 60.r,
        )
      ]),
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
            // minimumSize: Size(127.w, 42.h),
            // maximumSize: Size(127.w, 42.h),
          ),
          onPressed: onPressed,
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('Logout',
                style: Theme.of(context).textTheme.displaySmall!.copyWith(
                    fontSize: 16.sp,
                    color: Theme.of(context).colorScheme.error)),
            SizedBox(width: 8.w),
            Icon(icon, color: Theme.of(context).colorScheme.error),
          ])),
    );
  }
}

/// The class [BookmarkButton] defines a button that allows to save ads in the app. The button is a Stateful widget, charactherized by the state "isSaved" to understand if the rental proposal has been saved by the user or not.
/// To correctly invoke this widget you have to define these parameters:
/// - [size] of the button;
/// - [isSaved], inital state value of the button depending whether is saved or not.
class BookmarkButton extends StatefulWidget {
  final double size;
  final void Function()? onPressed;
  // widget state
  final bool isSaved;

  const BookmarkButton({super.key, required this.size, required this.isSaved, required this.onPressed});

  @override
  State<BookmarkButton> createState() => _BookmarkButtonState();
}

class _BookmarkButtonState extends State<BookmarkButton> {
  Color buttonColor = ColorPalette.aliceBlue;
  IconData icon = Icons.bookmark_border_outlined;
  Color iconColor = ColorPalette.oxfordBlue;

  @override
  void initState() {
    super.initState();
    icon = widget.isSaved ? Icons.bookmark : Icons.bookmark_border_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          spreadRadius: 4.r,
          blurRadius: 60.r,
        )
      ]),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          shape: const CircleBorder(),
          minimumSize: Size(widget.size.w, widget.size.h),
        ),
        onPressed: widget.onPressed,
        child: Icon(
            widget.isSaved ? Icons.bookmark : Icons.bookmark_border_outlined,
            color: iconColor,
            size: widget.size - 20.w),
      ),
    );
  }
}
