import 'dart:io';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:room_finder/style/color_palette.dart';

/// The class [AddPhotoButton] is a widget that represents a button to add a photo.
class AddPhotoButton extends StatelessWidget {
  final void Function()? onPressed;

  const AddPhotoButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150.w,
      height: 150.h,
      child: AspectRatio(
        aspectRatio: 1,
        child: OutlinedButton(
          onPressed: onPressed,
          style: ButtonStyle(
            foregroundColor: WidgetStateProperty.all<Color>(
              ColorPalette.blueberry.withOpacity(0.5),
            ),
            side: WidgetStateProperty.all<BorderSide>(
              BorderSide(
                color: ColorPalette.jordyBlue.withOpacity(0.5),
                width: 2.w,
              ),
            ),
            minimumSize: WidgetStateProperty.all<Size>(
              Size(80.w, 80.h),
            ),
            maximumSize: WidgetStateProperty.all<Size>(
              Size(150.w, 150.h),
            ),
            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            backgroundColor: WidgetStateProperty.all<Color>(
              ColorPalette.lavenderBlue.withOpacity(0.5),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_a_photo),
              Text(AppLocalizations.of(context)!.lblAddPhoto),
            ],
          ),
        ),
      ),
    );
  }
}

class ImageCard extends StatelessWidget {
  const ImageCard({
    super.key,
    required this.image,
    required this.photoNumber,
    this.onRemovePressed,
  });

  final File image;
  final int photoNumber;
  final void Function()? onRemovePressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150.0.w,
      height: 150.0.h,
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: Image.file(
                image,
                fit: BoxFit.cover,
                width: 150.0.w,
                height: 150.0.h,
              ),
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: IconButton(
              onPressed: onRemovePressed,
              icon: Icon(
                Icons.remove_circle,
                color: Theme.of(context).colorScheme.error,
                size: 30.0.w,
                shadows: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 5.0.r,
                    spreadRadius: 10.0.w,
                    offset: Offset(2.0.w, 2.0.w),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Card(
              color: Theme.of(context).colorScheme.surface.withOpacity(0.85),
              child: Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: 6.0.w, vertical: 2.0.h),
                child: Text(
                  "$photoNumber",
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
