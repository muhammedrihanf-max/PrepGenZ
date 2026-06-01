import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';

class AdManager {
  static final AdManager instance = AdManager._internal();
  AdManager._internal();

  static const String interstitialAdId = "ca-app-pub-8174751864694478/8014571012";
  static const String restartRewardedAdId = "ca-app-pub-8174751864694478/6502178795";
  static const String watchAdRewardedAdId = "ca-app-pub-8174751864694478/6586243191";

  InterstitialAd? _interstitialAd;
  RewardedAd? _restartRewardedAd;
  RewardedAd? _watchAdRewardedAd;

  bool _isInterstitialAdLoading = false;
  bool _isRestartRewardedAdLoading = false;
  bool _isWatchAdRewardedAdLoading = false;

  void initialize() {
    MobileAds.instance.initialize();
    loadInterstitialAd();
    loadRestartRewardedAd();
    loadWatchAdRewardedAd();
  }

  // Interstitial Ad (Keep Going)
  void loadInterstitialAd() {
    if (_isInterstitialAdLoading || _interstitialAd != null) return;
    _isInterstitialAdLoading = true;
    InterstitialAd.load(
      adUnitId: interstitialAdId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdLoading = false;
          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitialAd = null;
              loadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _interstitialAd = null;
              loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _isInterstitialAdLoading = false;
          _interstitialAd = null;
          debugPrint('InterstitialAd failed to load: $error');
        },
      ),
    );
  }

  void showInterstitialAd({VoidCallback? onComplete}) {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _interstitialAd = null;
          loadInterstitialAd();
          if (onComplete != null) onComplete();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _interstitialAd = null;
          loadInterstitialAd();
          if (onComplete != null) onComplete();
        },
      );
      _interstitialAd!.show();
    } else {
      loadInterstitialAd();
      if (onComplete != null) onComplete();
    }
  }

  // Rewarded Ad (Restart)
  void loadRestartRewardedAd() {
    if (_isRestartRewardedAdLoading || _restartRewardedAd != null) return;
    _isRestartRewardedAdLoading = true;
    RewardedAd.load(
      adUnitId: restartRewardedAdId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _restartRewardedAd = ad;
          _isRestartRewardedAdLoading = false;
        },
        onAdFailedToLoad: (error) {
          _isRestartRewardedAdLoading = false;
          _restartRewardedAd = null;
          debugPrint('Restart RewardedAd failed to load: $error');
        },
      ),
    );
  }

  void showRestartRewardedAd({required VoidCallback onRewardEarned, VoidCallback? onClosed}) {
    if (_restartRewardedAd != null) {
      bool earned = false;
      _restartRewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _restartRewardedAd = null;
          loadRestartRewardedAd();
          if (earned) {
            onRewardEarned();
          } else {
            if (onClosed != null) onClosed();
          }
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _restartRewardedAd = null;
          loadRestartRewardedAd();
          if (onClosed != null) onClosed();
        },
      );
      _restartRewardedAd!.show(onUserEarnedReward: (ad, reward) {
        earned = true;
      });
    } else {
      loadRestartRewardedAd();
      if (onClosed != null) onClosed();
    }
  }

  // Rewarded Ad (Watch Ad Button near Home)
  void loadWatchAdRewardedAd() {
    if (_isWatchAdRewardedAdLoading || _watchAdRewardedAd != null) return;
    _isWatchAdRewardedAdLoading = true;
    RewardedAd.load(
      adUnitId: watchAdRewardedAdId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _watchAdRewardedAd = ad;
          _isWatchAdRewardedAdLoading = false;
        },
        onAdFailedToLoad: (error) {
          _isWatchAdRewardedAdLoading = false;
          _watchAdRewardedAd = null;
          debugPrint('WatchAd RewardedAd failed to load: $error');
        },
      ),
    );
  }

  void showWatchAdRewardedAd({required VoidCallback onRewardEarned, VoidCallback? onClosed}) {
    if (_watchAdRewardedAd != null) {
      bool earned = false;
      _watchAdRewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _watchAdRewardedAd = null;
          loadWatchAdRewardedAd();
          if (earned) {
            onRewardEarned();
          } else {
            if (onClosed != null) onClosed();
          }
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _watchAdRewardedAd = null;
          loadWatchAdRewardedAd();
          if (onClosed != null) onClosed();
        },
      );
      _watchAdRewardedAd!.show(onUserEarnedReward: (ad, reward) {
        earned = true;
      });
    } else {
      loadWatchAdRewardedAd();
      if (onClosed != null) onClosed();
    }
  }
}
