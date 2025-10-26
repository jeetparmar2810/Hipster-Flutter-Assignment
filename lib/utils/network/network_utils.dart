import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hipster_inc_assignment/utils/app_dimens.dart';

class NetworkUtils {
  static Future<bool> hasInternet() async {
    var connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult.contains(ConnectivityResult.none)) {
      return false;
    }
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(Duration(seconds: AppDimens.duration5MS));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}