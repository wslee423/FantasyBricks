import 'dart:async';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'local_storage.dart';

/// 테스트 ID — 출시 전 실제 ID로 교체 필요
class _AdIds {
  static const String banner   = 'ca-app-pub-3940256099942544/6300978111';
  static const String rewarded = 'ca-app-pub-3940256099942544/5224354917';
}

class AdService {
  static const int rewardCoins = 5;

  static BannerAd? _banner;

  static Future<void> init() async {
    try {
      await MobileAds.instance.initialize();
    } catch (_) {
      // 광고 초기화 실패 시에도 앱은 정상 동작
    }
  }

  // ── 배너 ──────────────────────────────────────────────

  static Future<BannerAd?> loadBanner() async {
    final completer = Completer<bool>();
    final ad = BannerAd(
      adUnitId: _AdIds.banner,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => completer.complete(true),
        onAdFailedToLoad: (_, __) => completer.complete(false),
      ),
    )..load();

    final loaded = await completer.future;
    if (loaded) {
      _banner = ad;
      return ad;
    }
    ad.dispose();
    return null;
  }

  static void disposeBanner() {
    _banner?.dispose();
    _banner = null;
  }

  // ── 리워드 ────────────────────────────────────────────

  /// 리워드 광고 시청 후 5코인 지급. 일 5회 초과 또는 실패 시 false 반환.
  static Future<bool> showRewarded() async {
    if (!LocalStorage.canWatchAd()) return false;

    final loadCompleter = Completer<RewardedAd?>();

    RewardedAd.load(
      adUnitId: _AdIds.rewarded,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => loadCompleter.complete(ad),
        onAdFailedToLoad: (_) => loadCompleter.complete(null),
      ),
    );

    final ad = await loadCompleter.future;
    if (ad == null) return false;

    final showCompleter = Completer<bool>();
    bool rewarded = false;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (_) {
        ad.dispose();
        showCompleter.complete(rewarded);
      },
      onAdFailedToShowFullScreenContent: (_, __) {
        ad.dispose();
        showCompleter.complete(false);
      },
    );

    ad.show(onUserEarnedReward: (_, __) => rewarded = true);

    final result = await showCompleter.future;
    if (result) {
      await LocalStorage.recordAdWatched();
      await LocalStorage.addCoins(rewardCoins);
    }
    return result;
  }
}
