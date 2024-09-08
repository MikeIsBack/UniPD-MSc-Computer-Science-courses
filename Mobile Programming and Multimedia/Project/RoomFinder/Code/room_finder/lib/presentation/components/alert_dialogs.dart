import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:room_finder/style/color_palette.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// A class that represents an Android dialog with a title and content.
///
/// [title] is the title of the dialog.
/// [content] is the content of the dialog.
class InfoAndroidDialog extends StatelessWidget {
  final String title;
  final Widget content;

  const InfoAndroidDialog(
      {super.key, required this.title, required this.content});

  List<Widget>? get actions => null;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title,
          style: Theme.of(context)
              .textTheme
              .displaySmall!
              .copyWith(fontWeight: FontWeight.w600)),
      content: content,
      //Text(content),
      actions: actions,
    );
  }
}

/// A class that represents an Android dialog with a title, content, and actions.
///
/// [title] is the title of the dialog.
/// [content] is the content of the dialog.
/// [onOk] is the function to be called when the OK button is pressed.
/// [onCancel] is the function to be called when the Cancel button is pressed.
class ActionsAndroidDialog extends InfoAndroidDialog {
  final void Function()? onOk;
  final void Function()? onCancel;
  final BuildContext context;

  const ActionsAndroidDialog(
      {super.key,
      required super.title,
      required super.content,
      required this.context,
      this.onOk,
      this.onCancel});

  @override
  List<Widget> get actions {
    final List<Widget> actions = [];
    if (onOk != null) {
      actions.add(TextButton(
        onPressed: onOk,
        child: const Text('OK'),
      ));
    }
    if (onCancel != null) {
      actions.add(TextButton(
        onPressed: onCancel,
        child: Text(AppLocalizations.of(context)!.btnCancel),
      ));
    }
    return actions;
  }
}

/// A class that represents an iOS dialog with a title and content.
///
/// [title] is the title of the dialog.
/// [content] is the content of the dialog.
class InfoIosDialog extends StatelessWidget {
  final String title;
  final Widget content;

  const InfoIosDialog({super.key, required this.title, required this.content});

  List<Widget> get actions => [];

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text(title,
          style: const TextStyle(
            color: ColorPalette.darkConflowerBlue,
          )),
      content: content,
      // Text(content,
      //     style: const TextStyle(
      //       color: ColorPalette.darkConflowerBlue,
      //     )),
      actions: actions,
    );
  }
}

/// A class that represents an iOS dialog with a title, content, and actions.
///
/// [title] is the title of the dialog.
/// [content] is the content of the dialog.
/// [onOk] is the function to be called when the OK button is pressed.
/// [onCancel] is the function to be called when the Cancel button is pressed.
class ActionsIosDialog extends InfoIosDialog {
  final void Function()? onOk;
  final void Function()? onCancel;
  final BuildContext context;

  const ActionsIosDialog(
      {super.key,
      required super.title,
      required super.content,
      required this.context,
      this.onOk,
      this.onCancel});

  @override
  List<Widget> get actions {
    final List<Widget> actions = [];
    if (onOk != null) {
      actions.add(CupertinoDialogAction(
        onPressed: onOk,
        child: const Text('OK'),
      ));
    }
    if (onCancel != null) {
      actions.add(CupertinoDialogAction(
        onPressed: onCancel,
        child: Text(AppLocalizations.of(context)!.btnCancel),
      ));
    }
    return actions;
  }
}

/// A function that shows an Android dialog
void _showIosDialog(
    {required BuildContext context, required InfoIosDialog dialog}) {
  showCupertinoDialog(
    barrierDismissible: true,
    context: context,
    builder: (BuildContext context) {
      return dialog;
    },
  );
}

/// A function that shows an iOS dialog
void _showAndroidDialog(
    {required BuildContext context, required InfoAndroidDialog dialog}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return dialog;
    },
  );
}

/// A function that shows a dialog based on the platform.
///
/// It is required to pass an [InfoAndroidDialog] and an [InfoIosDialog] to show the dialog for both platforms.
void showOptionsDialog(
    {required BuildContext context,
    required InfoAndroidDialog androidDialog,
    required InfoIosDialog iosDialog}) {
  if (Theme.of(context).platform == TargetPlatform.android) {
    _showAndroidDialog(
      context: context,
      dialog: androidDialog,
    );
  } else {
    _showIosDialog(
      context: context,
      dialog: iosDialog,
    );
  }
}
