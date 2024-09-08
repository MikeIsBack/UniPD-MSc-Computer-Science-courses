import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:room_finder/model/user_model.dart';
import 'package:room_finder/presentation/components/alert_dialogs.dart';
import 'package:room_finder/presentation/components/buttons/circle_buttons.dart';
import 'package:room_finder/presentation/components/buttons/rectangle_buttons.dart';
import 'package:room_finder/presentation/components/error_messages.dart';
import 'package:room_finder/presentation/components/input_text_fields.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:room_finder/presentation/components/profile_photo_editor.dart';
import 'package:room_finder/presentation/components/snackbar.dart';
import 'package:room_finder/provider/authentication_provider.dart';
import 'package:room_finder/util/network_handler.dart';

class PersonalInformationPage extends ConsumerStatefulWidget {
  final UserData user;

  const PersonalInformationPage({super.key, required this.user});

  @override
  ConsumerState<PersonalInformationPage> createState() =>
      _PersonalInformationPageState();
}

class _PersonalInformationPageState
    extends ConsumerState<PersonalInformationPage> {
  late TextEditingController _nameController;

  bool _isNameChanged = false;
  bool _isPhotoChanged = false;

  File? _image;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _image = null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onNameValidityChanged(bool isValid) {
    setState(() {
      _isNameChanged = isValid;
    });
  }

  void _onPhotoChanged(File? photo) {
    setState(() {
      _isPhotoChanged = photo != null;
    });
  }

  void _handleSubmitChanges() async {
    if (_isNameChanged || _isPhotoChanged) {
      var networkStatus = ref.read(networkAwareProvider);

      if (networkStatus == NetworkStatus.off) {
        showErrorSnackBar(
            context, AppLocalizations.of(context)!.lblConnectionErrorDesc);
      } else {
        // Proceed submitting changes
        ref.read(authNotifierProvider.notifier).updatePersonalInformation(
            newUserName: _nameController.text,
            imageName: widget.user.uid,
            imageFile: _image);
      }
    }
  }

  bool get _hasUnsavedChanges => _isNameChanged || _isPhotoChanged;

  @override
  Widget build(BuildContext context) {
    ref.listen(authNotifierProvider, (previous, next) {
      next.maybeWhen(
        orElse: () => null,
        nameNotUpdated: () => showErrorSnackBar(
            context, AppLocalizations.of(context)!.lblFailedUpdateName),
        personalInfoUpdated: (newName, photoURL) {
          showSuccessSnackBar(context,
              AppLocalizations.of(context)!.lblSuccessfulPersInfoUpdate);

          Navigator.pop(context, widget.user);
        },
        photoNotUpdated: () => showErrorSnackBar(
            context, AppLocalizations.of(context)!.lblFailedUpdatePhoto),
      );
    });

    final networkStatus = ref.watch(networkAwareProvider);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) {
          return;
        }
        if (_hasUnsavedChanges) {
          showOptionsDialog(
            context: context,
            androidDialog: ActionsAndroidDialog(
              title: AppLocalizations.of(context)!.lblWarningTitleDialog,
              content: Text(AppLocalizations.of(context)!.lblCancelWizard),
              context: context,
              onOk: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              onCancel: () => Navigator.of(context).pop(),
            ),
            iosDialog: ActionsIosDialog(
              title: AppLocalizations.of(context)!.lblWarningTitleDialog,
              content: Text(AppLocalizations.of(context)!.lblCancelWizard),
              context: context,
              onOk: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              onCancel: () => Navigator.of(context).pop(),
            ),
          );
        } else {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        body: networkStatus == NetworkStatus.off
            ? Center(
                heightFactor: 6.h,
                child: NoInternetErrorMessage(context: context))
            : SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DarkBackButton(
                              onPressed: (_isNameChanged || _isPhotoChanged)
                                  ? () {
                                      showOptionsDialog(
                                          context: context,
                                          androidDialog: ActionsAndroidDialog(
                                              title: AppLocalizations.of(context)!
                                                  .lblWarningTitleDialog,
                                              content: Text(
                                                  AppLocalizations.of(context)!
                                                      .lblCancelWizard),
                                              context: context,
                                              onOk: () {
                                                Navigator.of(context).pop();
                                                Navigator.of(context).pop();
                                              },
                                              onCancel: () {
                                                Navigator.of(context).pop();
                                              }),
                                          iosDialog: ActionsIosDialog(
                                              title: AppLocalizations.of(context)!
                                                  .lblWarningTitleDialog,
                                              content: Text(
                                                  AppLocalizations.of(context)!
                                                      .lblCancelWizard),
                                              context: context,
                                              onOk: () {
                                                Navigator.of(context).pop();
                                                Navigator.of(context).pop();
                                              },
                                              onCancel: () {
                                                Navigator.of(context).pop();
                                              }));
                                    }
                                  : () => Navigator.of(context).pop()),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 30.w, vertical: 20.h),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 40.h),
                                Text(AppLocalizations.of(context)!.btnPersonalInfo,
                                    style:
                                        Theme.of(context).textTheme.displayMedium),
                                SizedBox(height: 20.h),
                                Text(
                                    AppLocalizations.of(context)!
                                        .lblPersonalInformation,
                                    style: Theme.of(context).textTheme.bodyLarge),
                                SizedBox(height: 40.h),
                                Center(
                                  child: Text(
                                    AppLocalizations.of(context)!.lblAccountPhoto,
                                    style: Theme.of(context).textTheme.displaySmall,
                                  ),
                                ),
                                SizedBox(height: 20.h),
                                Center(
                                  child: ProfilePhotoEditor(
                                    imageUrl: widget.user.photoUrl,
                                    onPhotoChanged: _onPhotoChanged,
                                    image: _image,
                                    onPhotoSetted: (newPhoto) {
                                      setState(() {
                                        _image = newPhoto;
                                      });
                                    },
                                  ),
                                ),
                                SizedBox(height: 20.h),
                                StandardTextField(
                                  label: AppLocalizations.of(context)!.lblName,
                                  onValueValidityChanged: _onNameValidityChanged,
                                  controller: _nameController,
                                ),
                                SizedBox(height: 40.h),
                                Center(
                                  child: Stack(
                                    children: [
                                      RectangleButton(
                                        label: AppLocalizations.of(context)!
                                            .lblSubmitChanges,
                                        onPressed: _handleSubmitChanges,
                                      ),
                                      if (!_isNameChanged && !_isPhotoChanged)
                                        Positioned.fill(
                                          child: Container(
                                            color: Colors.white.withOpacity(0.5),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 20.h),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
      ),
    );
  }
}
