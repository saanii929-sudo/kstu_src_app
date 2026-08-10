import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityHelper {
  Future<ConnectivityResult> checkConnectivity() async {
    return await Connectivity().checkConnectivity();
  }
}