import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:room_finder/style/color_palette.dart';

/// A class that contains the global theme data used in the app.
///
/// This class contains the [lightTheme] and [darkTheme] themes used in the app, as well as the color schemes ([lightColorScheme] and [darkColorScheme]) for each theme.
/// The light and dark themes changes according to the system preference.
class GlobalThemeData {
  static final Color _lightFocusColor =
      const Color.fromARGB(255, 0, 0, 0).withOpacity(0.12);

  static ThemeData lightTheme =
      themeData(lightColorScheme, _lightFocusColor, Brightness.light);

  static ThemeData themeData(
      ColorScheme colorScheme, Color focusColor, Brightness brightness) {
    return ThemeData(
      fontFamily: 'Poppins',
      colorScheme: colorScheme,
      canvasColor: colorScheme.surface,
      scaffoldBackgroundColor: colorScheme.surface,
      highlightColor: Colors.transparent,
      focusColor: focusColor,
      useMaterial3: true,
      brightness: brightness,
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 40.sp,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          fontSize: 30.sp,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(fontSize: 20.sp),
        bodyMedium: TextStyle(fontSize: 16.sp),
        bodySmall: TextStyle(fontSize: 12.sp),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: ColorPalette.darkConflowerBlue,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.all(
          const IconThemeData(color: ColorPalette.aliceBlue),
        ),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(
            color: ColorPalette.aliceBlue,
          ),
        ),
      ),
      cupertinoOverrideTheme: CupertinoThemeData(
        primaryColor: colorScheme.primary,
        primaryContrastingColor: colorScheme.onPrimary,
        scaffoldBackgroundColor: colorScheme.surface,
        applyThemeToAll: true,
        brightness: brightness,
        textTheme: CupertinoTextThemeData(
          textStyle: TextStyle(
            color: colorScheme.primary,
          ),
          actionTextStyle: TextStyle(
            color: colorScheme.primary,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surface,
        selectedColor: colorScheme.primary,
        secondarySelectedColor: colorScheme.primary,
        disabledColor: colorScheme.onSurface.withOpacity(0.38),
        labelPadding: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.all(4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        labelStyle: const TextStyle(
          color: ColorPalette.oxfordBlue,
        ),
        secondaryLabelStyle: const TextStyle(
          color: ColorPalette.aliceBlue,
        ),
        brightness: brightness,
      ),
    );
  }

  static const ColorScheme lightColorScheme = ColorScheme(
    primary: ColorPalette.darkConflowerBlue,
    secondary: ColorPalette.jordyBlue,
    surface: ColorPalette.aliceBlue,
    error: ColorPalette.error,
    onPrimary: ColorPalette.aliceBlue,
    onSecondary: ColorPalette.aliceBlue,
    onSurface: ColorPalette.oxfordBlue,
    onError: ColorPalette.aliceBlue,
    brightness: Brightness.light,
  );
}
