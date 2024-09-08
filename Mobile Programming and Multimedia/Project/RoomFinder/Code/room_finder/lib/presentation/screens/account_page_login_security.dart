import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:room_finder/model/user_model.dart';
import 'package:room_finder/presentation/components/alert_dialogs.dart';
import 'package:room_finder/presentation/components/buttons/circle_buttons.dart';
import 'package:room_finder/presentation/components/buttons/rectangle_buttons.dart';
import 'package:room_finder/presentation/components/input_text_fields.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:room_finder/presentation/components/snackbar.dart';
import 'package:room_finder/presentation/screens/login_page.dart';
import 'package:room_finder/provider/authentication_provider.dart';
import 'package:room_finder/util/network_handler.dart';

class LoginSecurityPage extends ConsumerStatefulWidget {
  final UserData user;

  const LoginSecurityPage({super.key, required this.user});

  @override
  ConsumerState<LoginSecurityPage> createState() => _LoginSecurityPageState();
}

class _LoginSecurityPageState extends ConsumerState<LoginSecurityPage> {
  late TextEditingController _pswdController;
  late TextEditingController _confirmPswdController;

  bool _isPasswordValid = false;

  @override
  void initState() {
    super.initState();
    _pswdController = TextEditingController();
    _confirmPswdController = TextEditingController();
  }

  @override
  void dispose() {
    _pswdController.dispose();
    _confirmPswdController.dispose();
    super.dispose();
  }

  void _onPasswordValidityChanged(bool isValid) {
    setState(() {
      _isPasswordValid = isValid;
    });
  }

  void _handleChangePassword() {
    if (_isPasswordValid) {
      final networkStatus = ref.read(networkAwareProvider);

      if (networkStatus == NetworkStatus.off) {
        showErrorSnackBar(
            context, AppLocalizations.of(context)!.lblConnectionErrorDesc);
      } else {
        // Proceed with changing password logic
        ref
            .read(authNotifierProvider.notifier)
            .updatePassword(newPassword: _pswdController.text);
      }
    }
  }

  bool get _hasUnsavedChanges =>
      _pswdController.text.isNotEmpty ||
      _confirmPswdController.text.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    ref.listen(authNotifierProvider, (previous, next) {
      next.maybeWhen(
        orElse: () => null,
        passwordNotUpdated: () => showErrorSnackBar(
            context, AppLocalizations.of(context)!.lblFailedPasswordUpdate),
        passwordUpdated: () {
          showSuccessSnackBar(context,
              AppLocalizations.of(context)!.lblSuccessfulPasswordUpdate);

          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const LoginPage()));
        },
      );
    });

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
        body: SafeArea(
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
                          onPressed: (_pswdController.text.isNotEmpty ||
                                  _confirmPswdController.text.isNotEmpty)
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
                            SizedBox(height: 20.h),
                            Center(
                              child: Image(
                                image: const AssetImage(
                                    'assets/images/Change-password.png'),
                                width: 200.w,
                                height: 200.h,
                              ),
                            ),
                            SizedBox(height: 20.h),
                            Text(AppLocalizations.of(context)!.btnLoginSecurity,
                                style: Theme.of(context).textTheme.displayMedium),
                            SizedBox(height: 20.h),
                            Text(AppLocalizations.of(context)!.lblLoginSecurity,
                                style: Theme.of(context).textTheme.bodyLarge),
                            SizedBox(height: 20.h),
                            RegistrationPswdTextField(
                              onPswdValidationChanged: _onPasswordValidityChanged,
                              pswdController: _pswdController,
                              confirmPswdController: _confirmPswdController,
                            ),
                            SizedBox(height: 40.h),
                            Center(
                              child: Stack(
                                children: [
                                  RectangleButton(
                                    label: AppLocalizations.of(context)!.lblChangePswd,
                                    onPressed: _handleChangePassword,
                                  ),
                                  if (!_isPasswordValid)
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
