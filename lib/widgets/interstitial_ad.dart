import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class InterstitialAdWidget extends StatefulWidget {
  const InterstitialAdWidget({super.key});

  @override
  State<InterstitialAdWidget> createState() => _InterstitialAdWidgetState();
}

class _InterstitialAdWidgetState extends State<InterstitialAdWidget> {
  InterstitialAd? _interstitialAd;

  @override
  void initState() {
    super.initState();
    _createInterstitialAd();
  }

  void _createInterstitialAd() {
    InterstitialAd.load(
      adUnitId:
          // ca-app-pub-3940256099942544/1033173712 // Test Ad Unit ID
          'ca-app-pub-3168501848559608/6255530230',
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            // Called when the ad failed to show full screen content.
            onAdFailedToShowFullScreenContent: (ad, err) {
              // Dispose the ad here to free resources.
              ad.dispose();
            },
            // Called when the ad dismissed full screen content.
            onAdDismissedFullScreenContent: (ad) {
              // Dispose the ad here to free resources.
              ad.dispose();
            },
          );
          debugPrint(
              '$ad loaded: ${ad.responseInfo?.mediationAdapterClassName}');
          _interstitialAd = ad;
          _interstitialAd?.show();
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('InterstitialAd failed to load: ${error.message}');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    super.dispose();
  }
}
