import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:room_finder/main.dart';
import 'package:room_finder/model/user_model.dart';
import 'package:room_finder/presentation/components/account_photo.dart';
import 'package:room_finder/presentation/components/alert_dialogs.dart';
import 'package:room_finder/presentation/components/buttons/circle_buttons.dart';
import 'package:room_finder/presentation/components/buttons/setting_buttons.dart';
import 'package:room_finder/presentation/components/snackbar.dart';
import 'package:room_finder/presentation/screens/account_page_login_security.dart';
import 'package:room_finder/presentation/screens/account_page_personal_information.dart';
import 'package:room_finder/provider/authentication_provider.dart';
import 'package:room_finder/provider/user_provider.dart';
import 'package:room_finder/style/color_palette.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AccountPage extends ConsumerStatefulWidget {
  final UserData user;

  const AccountPage({super.key, required this.user});

  @override
  ConsumerState<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends ConsumerState<AccountPage> {
  late UserData settingUser = UserData(isHost: widget.user.isHost);
  bool isOnLoad = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref
          .read(userNotifierProvider.notifier)
          .getUser(userUid: widget.user.uid!);
    });
  }

  Future<void> _waitForFirebaseUrlUpdate() async {
    PaintingBinding.instance.imageCache.clear();            // Clears the memory cache
    PaintingBinding.instance.imageCache.clearLiveImages();  // Clears live images
    await Future.delayed(const Duration(seconds: 2));
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authNotifierProvider, (previous, next) {
      next.maybeWhen(
          orElse: () => null,
          successfulLogout: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const MyHomePage()));
          },
          failedLogout: () => showErrorSnackBar(
              context, AppLocalizations.of(context)!.lblFailedLogout));
    });

    ref.listen(userNotifierProvider, (previous, next) {
      next.maybeWhen(
        orElse: () => null,
        successfulRead: (userData) {
          setState(() {
            settingUser = UserData(
                uid: userData.uid,
                name: userData.name,
                email: userData.email,
                photoUrl: userData.photoUrl,
                isHost: userData.isHost,
                savedAds: userData.savedAds);
            isOnLoad = false;
          });
        },
        failedRead: () => showErrorSnackBar(context, AppLocalizations.of(context)!.lblFailOperation("loading user")),
      );
    });

    return isOnLoad
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : FutureBuilder<void>(
            future: _waitForFirebaseUrlUpdate(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              return Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        ClipPath(
                          clipper: EllipseClipper(),
                          child: Container(
                            height: 300.h,
                            color: ColorPalette.darkConflowerBlue,
                          ),
                        ),
                        Padding(
                          padding:
                              EdgeInsets.only(top: 55.h, left: 235.w, right: 15.w),
                          child: LogoutButton(
                              onPressed: () => showOptionsDialog(
                                  context: context,
                                  androidDialog: ActionsAndroidDialog(
                                      context: context,
                                      title: AppLocalizations.of(context)!.btnLogout,
                                      content: Text(AppLocalizations.of(context)!
                                          .logoutAlertMessage),
                                      onOk: () => {
                                            ref
                                                .read(authNotifierProvider.notifier)
                                                .logout(),
                                            Navigator.pop(context)
                                          },
                                      onCancel: () => Navigator.pop(context)),
                                  iosDialog: ActionsIosDialog(
                                      context: context,
                                      title: AppLocalizations.of(context)!.btnLogout,
                                      content: Text(AppLocalizations.of(context)!
                                          .logoutAlertMessage),
                                      onOk: () => {
                                            ref
                                                .read(authNotifierProvider.notifier)
                                                .logout(),
                                            Navigator.pop(context)
                                          },
                                      onCancel: () => Navigator.pop(context)))),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 100.h),
                          child: Align(
                            alignment: Alignment.center,
                            child: Column(
                              children: [
                                AccountPhoto(
                                  size: 180.r,
                                  imageUrl: settingUser.photoUrl,
                                ),
                                SizedBox(height: 10.h),
                                Text(settingUser.name ?? '',
                                    style: Theme.of(context).textTheme.displayMedium),
                                SizedBox(height: 10.h),
                                Text(settingUser.email ?? '',
                                    style: Theme.of(context).textTheme.bodyMedium),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 20.h),
                      child: Divider(
                        color: ColorPalette.blueberry,
                        indent: 25.w,
                        endIndent: 25.w,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 25.w, top: 15.h, bottom: 15.h),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          AppLocalizations.of(context)!.lblSettings,
                          style: TextStyle(
                            color: ColorPalette.oxfordBlue,
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                        ),
                        child: ListView(
                          physics: const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          children: [
                            SettingButtons(
                              onPressed: () async {
                                await Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => PersonalInformationPage(
                                          user: settingUser,
                                        )));
                                setState(() {
                                  isOnLoad = true;
                                });
                                await ref
                                    .read(userNotifierProvider.notifier)
                                    .getUser(userUid: widget.user.uid!);
                              },
                              label: AppLocalizations.of(context)!.btnPersonalInfo,
                              icon: Icons.person_outline,
                            ),
                            SettingButtons(
                              onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          LoginSecurityPage(user: settingUser))),
                              label: AppLocalizations.of(context)!.btnLoginSecurity,
                              icon: Icons.login,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
            }
        );
  }
}

class EllipseClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    // Start the path at the left edge, somewhat lower on the container's height
    path.moveTo(0, size.height * 0.6);

    // Create a quadratic bezier curve that defines the ellipse
    // The first point is the control point for the curve
    // The second point is the end point of the curve on the right edge
    path.quadraticBezierTo(
        size.width / 2,
        size.height * 0.8, // This makes the curve flatter
        size.width,
        size.height * 0.6); // End point at the same level as the start point

    // Draw lines to close the shape
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
