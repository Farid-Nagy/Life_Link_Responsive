import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

/// Centralized connectivity helper.
///
/// On Flutter Web we rely on the browser/network state instead of making a
/// request to an external website (which can fail because of CORS). On
/// mobile/desktop we use InternetConnectionChecker for a real reachability
/// check. Firebase remains the source of truth for authentication requests.
abstract final class InternetService {
  static Future<bool> hasInternet() async {
    try {
      if (kIsWeb) {
        final connectivity = await Connectivity().checkConnectivity();
        return connectivity.any((result) => result != ConnectivityResult.none);
      }

      return await InternetConnectionChecker().hasConnection;
    } catch (_) {
      return true;
    }
  }
}
