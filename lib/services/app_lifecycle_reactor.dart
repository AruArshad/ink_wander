import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:ink_wander/widgets/app_open_ad.dart';

/// Listens for app foreground events and shows app open ads.
class AppLifecycleReactor {
  final AppOpenAdManager appOpenAdManager;

  AppLifecycleReactor({required this.appOpenAdManager});

  void listenToAppStateChanges() {
    debugPrint("Starting to listen to app state changes");
    AppStateEventNotifier.startListening();
    AppStateEventNotifier.appStateStream
        .forEach((state) => _onAppStateChanged(state));
  }

  void _onAppStateChanged(AppState appState) {
    try {
      debugPrint("App state changed: $appState");
      if (appState == AppState.foreground) {
        debugPrint("App state changed to foreground");
        appOpenAdManager.showAdIfAvailable();
      }
    } catch (e) {
      debugPrint("Error in _onAppStateChanged: $e");
    }
  }
}
