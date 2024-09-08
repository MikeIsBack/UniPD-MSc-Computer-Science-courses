import 'package:shared_preferences/shared_preferences.dart';

/// Singleton class to handle the shared preferences for the on boarding screen
///
/// This class is used to store the information about whether the user has seen the on boarding screen or not.
///
/// * [getWasShown] returns a boolean value indicating whether the user has seen the on boarding screen or not.
///
/// * [setWasShown] sets the boolean value indicating whether the user has seen the on boarding screen or not.
class OnBoardingScreenPreferences {
  /// Returns a boolean value indicating whether the user has seen the on boarding screen or not.
  static Future<bool> getWasShown() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return (prefs.getBool('WAS_SHOWN') ?? false);
  }

  /// Sets the boolean value indicating whether the user has seen the on boarding screen or not.
  static Future<void> setWasShown() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('WAS_SHOWN', true);
  }
}
