import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:room_finder/style/color_palette.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// This file contains the implementation of all input fields belonging to the app forms.

/// The class [StandardTextField] defines an input field, used to digit a value that cannot be null.
class StandardTextField extends StatefulWidget {
  final String label;
  final Function(bool) onValueValidityChanged;
  final String? initialValue; // Optional parameter to load the initial name from backend
  final TextEditingController controller;

  const StandardTextField({
    super.key,
    required this.label,
    required this.onValueValidityChanged,
    this.initialValue,
    required this.controller
  });

  @override
  State<StandardTextField> createState() => _StandardTextFieldState();
}

class _StandardTextFieldState extends State<StandardTextField> {
  // late TextEditingController _controller;

  // Widget state
  bool _isValueEmpty = false;

  @override
  void initState() {
    super.initState();
    // controller = TextEditingController(text: widget.initialValue ?? '');
    widget.controller.addListener(_validateValue);
  }

  void _validateValue() {
    final name = widget.controller.text;

    final isValid = name.isNotEmpty;
    widget.onValueValidityChanged(isValid);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: Theme.of(context).textTheme.displaySmall,
        ),
        SizedBox(height: 8.h),
        if (_isValueEmpty)
          Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: Text(
              AppLocalizations.of(context)!.lblStandardTextFieldError(widget.label),
              style: TextStyle(
                color: Colors.red,
                fontSize: 14.w,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        Container(
          width: 335.w,
          height: 52.h,
          decoration: const BoxDecoration(
            color: Color.fromRGBO(198, 208, 250, 50),
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
          alignment: Alignment.centerLeft,
          child: TextField(
            controller: widget.controller,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: '',
              contentPadding: EdgeInsets.only(left: 10.w),
            ),
            style: const TextStyle(color: ColorPalette.oxfordBlue),
            onSubmitted: (String value) {
              setState(() {
                _isValueEmpty = value.isEmpty;
              });
              widget.onValueValidityChanged(!_isValueEmpty);
            },
          ),
        ),
      ],
    );
  }
}

/// The class [EmailTextField] defines an input field to digit the email of the user.
class EmailTextField extends StatefulWidget {
  const EmailTextField(
      {super.key,
      required this.onEmailValidityChanged,
      required this.controller});

  // Callback function that will notify the parent widget when the email validity changes
  final ValueChanged<bool> onEmailValidityChanged;
  final TextEditingController controller;

  @override
  State<EmailTextField> createState() => _EmailTextFieldState();
}

class _EmailTextFieldState extends State<EmailTextField> {
  bool _isEmailEmpty = false;
  bool _userInteraction = false;

  final _emailRegExp = RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");

  void _validateEmail() {
    final email = widget.controller.text;
    final isValid = email.isNotEmpty && _emailRegExp.hasMatch(email);
    widget.onEmailValidityChanged(isValid);
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_validateEmail);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context)!.lblEmail,
            style: Theme.of(context).textTheme.displaySmall),
        SizedBox(
          height: 8.h,
        ),
        if (_isEmailEmpty)
          Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: Text(
              AppLocalizations.of(context)!.lblVoidEmailTextFieldError,
              style: TextStyle(
                  color: Colors.red,
                  fontSize: 14.w,
                  fontWeight: FontWeight.w500),
            ),
          ),
        if (_userInteraction &&
            !_isEmailEmpty &&
            !_emailRegExp.hasMatch(widget.controller.text))
          Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: Text(
              AppLocalizations.of(context)!.lblWrongEmailTextFieldError,
              style: TextStyle(
                  color: Colors.red,
                  fontSize: 14.w,
                  fontWeight: FontWeight.w500),
            ),
          ),
        Container(
            width: 335.w,
            height: 52.h,
            decoration: const BoxDecoration(
              color: Color.fromRGBO(198, 208, 250, 50),
              borderRadius: BorderRadius.all(
                Radius.circular(8.0),
              ),
            ),
            alignment: Alignment.centerLeft,
            child: TextField(
              controller: widget.controller,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: '',
                contentPadding: EdgeInsets.only(left: 10.w),
              ),
              style: const TextStyle(color: ColorPalette.oxfordBlue),
              keyboardType: TextInputType.emailAddress,
              onSubmitted: (String value) {
                setState(() {
                  _isEmailEmpty = value.isEmpty;
                  _userInteraction = true;
                });
              },
            )),
      ],
    );
  }
}

/// The class [LoginPswdTextField] defines an input field to digit the password during login process.
class LoginPswdTextField extends StatefulWidget {
  const LoginPswdTextField({
    super.key,
    required this.onPasswordValidityChanged,
    required this.controller,
  });

  // Callback function that will notify the parent widget when the password validity changes
  final ValueChanged<bool> onPasswordValidityChanged;
  final TextEditingController controller;

  @override
  State<LoginPswdTextField> createState() => _LoginPswdTextFieldState();
}

class _LoginPswdTextFieldState extends State<LoginPswdTextField> {
  bool _isPswdEmpty = false;
  bool _userInteraction = false;
  bool _showPswd = true;

  void _validatePassword() {
    final password = widget.controller.text;

    final isValid = password.isNotEmpty && widget.controller.text.length >= 6;
    widget.onPasswordValidityChanged(isValid);
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_validatePassword);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context)!.lblPassword,
            style: Theme.of(context).textTheme.displaySmall),
        SizedBox(
          height: 8.h,
        ),
        if (_isPswdEmpty)
          Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: Text(
              AppLocalizations.of(context)!.lblVoidPswdTextFieldError,
              style: TextStyle(
                  color: Colors.red,
                  fontSize: 14.w,
                  fontWeight: FontWeight.w500),
            ),
          ),
        if (_userInteraction &&
            !_isPswdEmpty &&
            widget.controller.text.length < 6)
          Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: Text(
              AppLocalizations.of(context)!.lblWrongPswdTextFieldError,
              style: TextStyle(
                  color: Colors.red,
                  fontSize: 14.w,
                  fontWeight: FontWeight.w500),
            ),
          ),
        Container(
            width: 335.w,
            height: 52.h,
            decoration: const BoxDecoration(
              color: Color.fromRGBO(198, 208, 250, 50),
              borderRadius: BorderRadius.all(
                Radius.circular(8.0),
              ),
            ),
            alignment: Alignment.centerLeft,
            child: TextField(
              controller: widget.controller,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: '',
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10.w, vertical: 14.h),
                suffixIcon: IconButton(
                  icon: Icon(
                    _showPswd ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () => setState(() => _showPswd = !_showPswd),
                ),
              ),
              style: const TextStyle(color: ColorPalette.oxfordBlue),
              obscureText: _showPswd,
              enableSuggestions: false,
              autocorrect: false,
              onSubmitted: (String value) {
                setState(() {
                  _isPswdEmpty = value.isEmpty;
                  _userInteraction = true;
                });
              },
            )),
      ],
    );
  }
}

/// The class [RegistrationPswdTextField] defines an input field to digit and confirm the password during registration process.
class RegistrationPswdTextField extends StatefulWidget {
  final Function(bool) onPswdValidationChanged;
  final TextEditingController pswdController;
  final TextEditingController confirmPswdController;

  const RegistrationPswdTextField(
      {super.key, required this.onPswdValidationChanged,
      required this.pswdController,
      required this.confirmPswdController});

  @override
  State<RegistrationPswdTextField> createState() =>
      _RegistrationPswdTextFieldState();
}

class _RegistrationPswdTextFieldState extends State<RegistrationPswdTextField> {
  // Widget state
  bool _isChoosePswdEmpty = false;
  bool _userChooseInteraction = false;

  bool _isConfirmPswdEmpty = false;
  bool _userConfirmInteraction = false;

  bool _passwordsMatch = false;

  bool _showChoosePswd = true;
  bool _showConfirmPswd = true;

  void _validateFields() {
    final chosenPassword = widget.pswdController.text;
    final confirmedPassword = widget.confirmPswdController.text;

    final bool isValid = 
        chosenPassword.isNotEmpty &&
        chosenPassword.length >= 6 &&
        confirmedPassword.isNotEmpty &&
        confirmedPassword.length >= 6 &&
        chosenPassword == confirmedPassword;

    widget.onPswdValidationChanged(isValid);
  }

  @override
  void initState() {
    super.initState();
    widget.pswdController.addListener(_validateFields);
    widget.confirmPswdController.addListener(_validateFields);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Choose a password
        Text(AppLocalizations.of(context)!.lblChoosePswd,
            style: Theme.of(context).textTheme.displaySmall),
        SizedBox(
          height: 8.h,
        ),
        if (_isChoosePswdEmpty)
          Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: Text(
              AppLocalizations.of(context)!.lblVoidPswdTextFieldError,
              style: TextStyle(
                  color: Colors.red,
                  fontSize: 14.w,
                  fontWeight: FontWeight.w500),
            ),
          ),
        if (_userChooseInteraction &&
            !_isChoosePswdEmpty &&
            widget.pswdController.text.length < 6)
          Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: Text(
              AppLocalizations.of(context)!.lblWrongPswdTextFieldError,
              style: TextStyle(
                  color: Colors.red,
                  fontSize: 14.w,
                  fontWeight: FontWeight.w500),
            ),
          ),
        Container(
            width: 335.w,
            height: 52.h,
            decoration: const BoxDecoration(
              color: Color.fromRGBO(198, 208, 250, 50),
              borderRadius: BorderRadius.all(
                Radius.circular(8.0),
              ),
            ),
            alignment: Alignment.centerLeft,
            child: TextField(
              controller: widget.pswdController,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: '',
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10.w, vertical: 14.h),
                suffixIcon: IconButton(
                  icon: Icon(
                    _showChoosePswd ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () =>
                      setState(() => _showChoosePswd = !_showChoosePswd),
                ),
              ),
              style: const TextStyle(color: ColorPalette.oxfordBlue),
              obscureText: _showChoosePswd,
              enableSuggestions: false,
              autocorrect: false,
              onSubmitted: (String value) {
                setState(() {
                  _isChoosePswdEmpty = value.isEmpty;
                  _userChooseInteraction = true;
                });
              },
            )),

        SizedBox(
          height: 20.w,
        ),

        // Confirm password
        Text(AppLocalizations.of(context)!.lblConfirmPswd,
            style: Theme.of(context).textTheme.displaySmall),
        SizedBox(
          height: 8.h,
        ),
        if (_isConfirmPswdEmpty)
          Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: Text(
              AppLocalizations.of(context)!.lblVoidPswdTextFieldError,
              style: TextStyle(
                  color: Colors.red,
                  fontSize: 14.w,
                  fontWeight: FontWeight.w500),
            ),
          ),
        if (_userConfirmInteraction &&
            !_isConfirmPswdEmpty &&
            widget.confirmPswdController.text.length < 6)
          Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: Text(
              AppLocalizations.of(context)!.lblWrongPswdTextFieldError,
              style: TextStyle(
                  color: Colors.red,
                  fontSize: 14.w,
                  fontWeight: FontWeight.w500),
            ),
          ),
        if (_userConfirmInteraction && !_isConfirmPswdEmpty && !_passwordsMatch)
          Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: Text(
              AppLocalizations.of(context)!.lblConfirmPswdMatchError,
              style: TextStyle(
                  color: Colors.red,
                  fontSize: 14.w,
                  fontWeight: FontWeight.w500),
            ),
          ),
        Container(
            width: 335.w,
            height: 52.h,
            decoration: const BoxDecoration(
              color: Color.fromRGBO(198, 208, 250, 50),
              borderRadius: BorderRadius.all(
                Radius.circular(8.0),
              ),
            ),
            alignment: Alignment.centerLeft,
            child: TextField(
              controller: widget.confirmPswdController,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: '',
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10.w, vertical: 14.h),
                suffixIcon: IconButton(
                  icon: Icon(
                    _showConfirmPswd ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () =>
                      setState(() => _showConfirmPswd = !_showConfirmPswd),
                ),
              ),
              style: const TextStyle(color: ColorPalette.oxfordBlue),
              obscureText: _showConfirmPswd,
              enableSuggestions: false,
              autocorrect: false,
              onSubmitted: (String value) {
                setState(() {
                  _isConfirmPswdEmpty = value.isEmpty;
                  _passwordsMatch = widget.pswdController.text == value;
                  _userConfirmInteraction = true;
                });
              },
            )),
      ],
    );
  }
}

/// The class [MessageInputField] defines the input text field to digit and send a new message in a chat page.
class MessageInputField extends StatefulWidget {
  final void Function() onTap;

  const MessageInputField({
    super.key,
    required this.onTap,
  });

  @override
  State<MessageInputField> createState() => _MessageInputFieldState();
}

class _MessageInputFieldState extends State<MessageInputField> {
  late TextEditingController _controller;

  // Widget state
  bool _isButtonActive = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();

    _controller.addListener(() {
      setState(() {
        _isButtonActive = _controller.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            minLines: 1,
            maxLines: 6,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.lblWriteMessage,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.r),
                borderSide: BorderSide(
                  color: const Color.fromRGBO(9, 31, 72, 70),
                  width: 3.w,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.r),
                borderSide: BorderSide(
                  color: const Color.fromRGBO(9, 31, 72, 70),
                  width: 3.w,
                ),
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.send),
                color: _isButtonActive
                    ? ColorPalette.oxfordBlue
                    : ColorPalette.lavenderBlue,
                onPressed: _isButtonActive ? widget.onTap : null,
                padding: EdgeInsets.all(8.w),
                iconSize: 20.w,
                splashRadius: 24.w,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
