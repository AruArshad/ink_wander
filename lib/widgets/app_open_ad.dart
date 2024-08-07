import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AppOpenAdManager {
  static AppOpenAd? _appOpenAd;
  static bool _isShowingAd = false;

  static Future<void> loadAd() async {
    const adRequest = AdRequest();
    await AppOpenAd.load(
      adUnitId:
          'ca-app-pub-3940256099942544/9257395921', // Replace with your ad unit ID
      request: adRequest,
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
        },
        onAdFailedToLoad: (error) {
          // Handle ad loading failure
          debugPrint('AppOpenAd failed to load: $error');
        },
      ),
    );
  }

  static void showAdIfAvailable() {
    if (_isShowingAd) return;
    if (_appOpenAd != null && !_isShowingAd) {
      _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
          onAdShowedFullScreenContent: (ad) => _isShowingAd = true,
          onAdDismissedFullScreenContent: (ad) {
            _isShowingAd = false;
            loadAd();
          });
      _appOpenAd!.show();
    }
  }
}
