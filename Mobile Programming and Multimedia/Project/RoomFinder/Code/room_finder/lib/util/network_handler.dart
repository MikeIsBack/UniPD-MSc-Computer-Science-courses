import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Enumeration to represent network status:
/// 
/// - [notDetermined] : network status not determined
/// 
/// - [on] : there is network connection
/// 
/// - [off] : there is no network connection
enum NetworkStatus { notDetermined, on, off }

/// StateNotifier class to manage network status
/// - [NetworkDetectorNotifier] : class to manage network status
class NetworkDetectorNotifier extends StateNotifier<NetworkStatus> {
  late NetworkStatus lastResult;

  /// Constructor to initialize the [NetworkDetectorNotifier] instance
  /// and listen to the network status changes.
  ///
  /// Return [NetworkDetectorNotifier] instance
  NetworkDetectorNotifier() : super(NetworkStatus.notDetermined) {
    lastResult = NetworkStatus.notDetermined;
    Connectivity().onConnectivityChanged.listen((event) {
      NetworkStatus newState;
      if (event.contains(ConnectivityResult.none)) {
        newState = NetworkStatus.off;
      } else if (event.contains(ConnectivityResult.wifi) ||
          event.contains(ConnectivityResult.mobile)) {
        newState = NetworkStatus.on;
      } else {
        newState = NetworkStatus.notDetermined;
      }

      if (newState != lastResult) {
        lastResult = newState;
        state = newState;
      }
    });
  }
}

/// Provide the [NetworkDetectorNotifier] instance to manage network status
final networkAwareProvider = StateNotifierProvider((ref) {
  return NetworkDetectorNotifier();
});
