import 'package:flutter/material.dart';

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static void navigateToLogin() {
    Future.microtask(() {
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        '/loginscreen',
        (route) => false,
      );
    });
  }
}
