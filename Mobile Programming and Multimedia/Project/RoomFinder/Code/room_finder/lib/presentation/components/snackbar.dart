import 'package:flutter/material.dart';
import 'package:room_finder/style/color_palette.dart';

/// Shows a success snackbar with the given [snackText], with green background.
void showSuccessSnackBar(BuildContext context, String snackText) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: ColorPalette.success,
      content: Text(
        snackText,
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: Colors.white,
            ),
      ),
    ),
  );
}

/// Shows an error snackbar with the given [snackText], with red background.
void showErrorSnackBar(BuildContext context, String snackText) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: ColorPalette.error,
      content: Text(
        snackText,
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: Colors.white,
            ),
      ),
    ),
  );
}
