import 'package:flutter/foundation.dart';

class ConnectivityService {
  ConnectivityService._();
  static final ConnectivityService instance = ConnectivityService._();

  // App-wide online status. true = online, false = offline
  final ValueNotifier<bool> online = ValueNotifier<bool>(true);
}


