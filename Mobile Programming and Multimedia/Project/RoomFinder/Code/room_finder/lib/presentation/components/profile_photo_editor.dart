import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:room_finder/presentation/components/buttons/circle_buttons.dart';
import 'package:room_finder/style/color_palette.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// [ProfilePhotoEditor] is a widget that displays a circular profile photo with an edit button to change the photo.
class ProfilePhotoEditor extends StatefulWidget {
  final String? imageUrl;
  final File? image;
  final ValueChanged<File?>? onPhotoChanged; // Callback for photo changes
  final void Function(File) onPhotoSetted;

  const ProfilePhotoEditor(
      {super.key,
      this.imageUrl,
      this.onPhotoChanged,
      this.image,
      required this.onPhotoSetted});

  @override
  State<ProfilePhotoEditor> createState() => _ProfilePhotoEditorState();
}

class _ProfilePhotoEditorState extends State<ProfilePhotoEditor> {
  final picker = ImagePicker();

  // Getting image from gallery
  Future<void> getImageFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final newImage = File(pickedFile.path);
      setState(() {
        widget.onPhotoSetted(newImage);  // Set the new image in the parent widget
      });
      widget.onPhotoChanged?.call(newImage);  // Notify parent about the change
    }
  }

  // Getting image from camera
  Future<void> getImageFromCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      final newImage = File(pickedFile.path);
      setState(() {
        widget.onPhotoSetted(newImage);  // Set the new image in the parent widget
      });
      widget.onPhotoChanged?.call(newImage);  // Notify parent about the change
    }
  }

  // Show dialog for android
  Future showAndroidModal() {
    return showModalBottomSheet(
      useSafeArea: true,
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 200.h,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLocalizations.of(context)!.lblChooseOption,
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                Divider(
                  color: ColorPalette.ceruleanBlue.withOpacity(0.8),
                  thickness: 1.h,
                ),
                TextButton.icon(
                  onPressed: () {
                    getImageFromGallery();
                    Navigator.of(context).pop();
                  },
                  label: Text(AppLocalizations.of(context)!.btnGallery),
                  icon: const Icon(Icons.photo),
                ),
                Divider(
                  color: ColorPalette.ceruleanBlue.withOpacity(0.5),
                  thickness: 1.h,
                ),
                TextButton.icon(
                  onPressed: () {
                    getImageFromCamera();
                    Navigator.of(context).pop();
                  },
                  label: Text(AppLocalizations.of(context)!.btnCamera),
                  icon: const Icon(Icons.camera_alt),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Show dialog for iOS
  Future showIosModal() async {
    showCupertinoModalPopup(
      barrierDismissible: true,
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text(AppLocalizations.of(context)!.lblChooseOption),
        actions: [
          CupertinoActionSheetAction(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.photo,
                  color: ColorPalette.darkConflowerBlue,
                ),
                Text(AppLocalizations.of(context)!.btnGallery),
              ],
            ),
            onPressed: () {
              // close the options modal
              Navigator.of(context).pop();
              // get image from gallery
              getImageFromGallery();
            },
          ),
          CupertinoActionSheetAction(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.camera_alt,
                  color: ColorPalette.darkConflowerBlue,
                ),
                Text(AppLocalizations.of(context)!.btnCamera),
              ],
            ),
            onPressed: () {
              // close the options modal
              Navigator.of(context).pop();
              // get image from camera
              getImageFromCamera();
            },
          ),
        ],
      ),
    );
  }

  // Show dialog based on platform
  void showOptionsDialog() {
    if (Theme.of(context).platform == TargetPlatform.android) {
      showAndroidModal();
    } else {
      showIosModal();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipOval(
          child: SizedBox(
            width: 200.r,
            height: 200.r,
            child: Image(
              image: widget.image != null
                  ? FileImage(widget.image!)
                  : (widget.imageUrl != null
                          ? NetworkImage(widget.imageUrl!)
                          : const AssetImage(
                              'assets/images/Standard-avatar.png'))
                      as ImageProvider,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          right: -20.w,
          child: EditButton(onPressed: showOptionsDialog),
        ),
      ],
    );
  }
}
