import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:room_finder/main.dart';
import 'package:room_finder/model/authentication_model.dart';
import 'package:room_finder/presentation/components/buttons/circle_buttons.dart';
import 'package:room_finder/presentation/components/buttons/rectangle_buttons.dart';
import 'package:room_finder/presentation/components/input_text_fields.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/gestures.dart';
import 'package:room_finder/presentation/components/snackbar.dart';
import 'package:room_finder/presentation/screens/registration_page.dart';
import 'package:room_finder/provider/authentication_provider.dart';
import 'package:room_finder/style/color_palette.dart';
import 'package:room_finder/util/network_handler.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  late TextEditingController _emailController;
  late TextEditingController _pswdController;
  
  bool _isEmailValid = false;
  bool _isPasswordValid = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _pswdController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _pswdController.dispose();
    super.dispose();
  }

  void _onEmailValidityChanged(bool isValid) {
    setState(() {
      _isEmailValid = isValid;
    });
  }

  void _onPasswordValidityChanged(bool isValid) {
    setState(() {
      _isPasswordValid = isValid;
    });
  }

  void _handleLogin() {
    if (_isEmailValid && _isPasswordValid) {
      final networkStatus = ref.read(networkAwareProvider);

      if (networkStatus == NetworkStatus.off) {
        showErrorSnackBar(context, AppLocalizations.of(context)!.lblConnectionErrorDesc);
      } else {
        // Proceed with login logic
        ref.read(authNotifierProvider.notifier).login(
            userCredential: AuthArgs(
                email: _emailController.text, password: _pswdController.text));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authNotifierProvider, (previous, next) {
      next.maybeWhen(
          orElse: () => null,
          authenticated: (user) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        const MyHomePage()));
            showSuccessSnackBar(
                context, AppLocalizations.of(context)!.lblSuccessfulLogin);
          },
          unauthenticated: () => showErrorSnackBar(
              context, AppLocalizations.of(context)!.lblFailedLogin));
    });

    return Scaffold(
      body: Center(
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
                    SafeArea(
                        child: CancelButton(
                            onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const MyHomePage())))),
                    Center(
                      child: Image(
                        image: const AssetImage(
                            'assets/images/RoomFinder-logo.png'),
                        width: 257.5.w,
                        height: 127.h,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 30.w, vertical: 20.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 40.h),
                          Text(AppLocalizations.of(context)!.lblLogin,
                              style: Theme.of(context).textTheme.displayMedium),
                          SizedBox(height: 20.h),
                          Text(AppLocalizations.of(context)!.lblLoginDesc,
                              style: Theme.of(context).textTheme.bodyLarge),
                          SizedBox(height: 20.h),
                          EmailTextField(
                            onEmailValidityChanged: _onEmailValidityChanged,
                            controller: _emailController,
                          ),
                          SizedBox(height: 20.h),
                          LoginPswdTextField(
                            onPasswordValidityChanged:
                                _onPasswordValidityChanged,
                            controller: _pswdController,
                          ),
                          SizedBox(height: 30.h),
                          Center(
                            child: Stack(
                              children: [
                                RectangleButton(
                                  label: "Log in",
                                  onPressed: _handleLogin,
                                ),
                                if (!_isEmailValid || !_isPasswordValid)
                                  Positioned.fill(
                                    child: Container(
                                      color: Colors.white.withOpacity(0.5),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20.h),
                          Center(
                            child: RichText(
                              text: TextSpan(
                                text:
                                    AppLocalizations.of(context)!.lblNoAccount,
                                style: TextStyle(
                                  color: ColorPalette.oxfordBlue,
                                  fontSize: 18.sp,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Sign up',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: ColorPalette.oxfordBlue,
                                        decoration: TextDecoration.underline),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () => Navigator.of(context)
                                          .push(MaterialPageRoute(
                                              builder: (context) =>
                                                  const RegistrationPage())),
                                  ),
                                ],
                              ),
                            ),
                          ),
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
    );
  }
}
