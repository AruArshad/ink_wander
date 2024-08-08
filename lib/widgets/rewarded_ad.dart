import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class RewardedAdWidget {
  RewardedAd? _rewardedAd;
  bool _isRewardedAdLoaded = false;

  void initRewardedAd() {
    _loadRewardedAd();
  }

  void disposeRewardedAd() {
    _rewardedAd?.dispose();
  }

  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/5224354917', // Test ad unit ID
      // adUnitId: 'YOUR_AD_UNIT_ID', // Replace with your production ad unit ID
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          debugPrint('$ad loaded.');
          _rewardedAd = ad;
          _isRewardedAdLoaded = true;
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('RewardedAd failed to load: $error');
          _isRewardedAdLoaded = false;
          if (_rewardedAd != null) {
            _rewardedAd!.dispose();
          }
        },
      ),
    );
  }

  void showRewardedAd() {
    if (_isRewardedAdLoaded) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (RewardedAd ad) =>
            debugPrint('Ad showed full screen content.'),
        onAdDismissedFullScreenContent: (RewardedAd ad) {
          debugPrint('$ad dismissed full screen content.');
          ad.dispose();
          _isRewardedAdLoaded = false;
          _loadRewardedAd();
        },
        onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
          debugPrint('$ad failed to show full screen content: $error');
          ad.dispose();
          _isRewardedAdLoaded = false;
          _loadRewardedAd();
        },
      );
      _rewardedAd!.setImmersiveMode(true);
      _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          debugPrint('User earned reward: ${reward.amount} ${reward.type}');
          // Reward the user here
        },
      );
    } else {
      debugPrint('Rewarded ad is not loaded.');
    }
  }
}