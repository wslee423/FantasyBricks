import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../data/local_storage.dart';
import '../../data/ad_service.dart';
import '../gacha/gacha_screen.dart';
import '../collection/collection_screen.dart';
import '../game_screen.dart';

class LobbyScreen extends StatefulWidget {
  const LobbyScreen({super.key});

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  static const int totalStages = 10;

  int _coins = 0;
  int _unlockedStage = 1;
  int _todayAdCount = 0;
  BannerAd? _bannerAd;
  bool _adLoading = false;

  @override
  void initState() {
    super.initState();
    _refresh();
    _loadBanner();
  }

  @override
  void dispose() {
    AdService.disposeBanner();
    super.dispose();
  }

  void _refresh() {
    setState(() {
      _coins = LocalStorage.getCoins();
      _unlockedStage = LocalStorage.getCurrentStage();
      _todayAdCount = LocalStorage.getTodayAdCount();
    });
  }

  Future<void> _loadBanner() async {
    final ad = await AdService.loadBanner();
    if (mounted) setState(() => _bannerAd = ad);
  }

  void _onStageTap(int stageId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => GameScreenWrapper(stageId: stageId)),
    ).then((_) => _refresh());
  }

  void _onGachaTap() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const GachaScreen()),
    ).then((_) => _refresh());
  }

  void _onCollectionTap() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CollectionScreen()),
    ).then((_) => _refresh());
  }

  Future<void> _onAdTap() async {
    if (_adLoading || !LocalStorage.canWatchAd()) return;
    setState(() => _adLoading = true);

    final success = await AdService.showRewarded();
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('마법 코인 +5 획득!'),
            backgroundColor: Color(0xFF2A6020),
            duration: Duration(seconds: 2),
          ),
        );
      }
      _refresh();
      setState(() => _adLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A0A3D),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSectionLabel('── 모험 지도 ──'),
            Expanded(child: _buildStageGrid()),
            _buildAdButton(),
            _buildBottomBar(),
            if (_bannerAd != null) _buildBannerAd(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      decoration: const BoxDecoration(
        color: Color(0xFF0D0620),
        border: Border(bottom: BorderSide(color: Color(0x44B39DDB))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Fantasy Bricks',
                style: TextStyle(
                  color: Color(0xFFFFD700),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              Text(
                '마법사의 탑을 무너뜨려라',
                style: TextStyle(
                  color: Color(0xFF8870AA),
                  fontSize: 11,
                  letterSpacing: 1,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          _CoinBadge(coins: _coins),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0x88B39DDB),
          fontSize: 11,
          letterSpacing: 3,
        ),
      ),
    );
  }

  Widget _buildStageGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 0.9,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: totalStages,
        itemBuilder: (context, index) {
          final stageId = index + 1;
          final isUnlocked = stageId <= _unlockedStage;
          final stars = LocalStorage.getStageStars(stageId);
          return _StageTile(
            stageId: stageId,
            isUnlocked: isUnlocked,
            stars: stars,
            onTap: isUnlocked ? () => _onStageTap(stageId) : null,
          );
        },
      ),
    );
  }

  Widget _buildAdButton() {
    final remaining = LocalStorage.maxDailyAds - _todayAdCount;
    final canWatch = remaining > 0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 0),
      child: GestureDetector(
        onTap: canWatch ? _onAdTap : null,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: const Color(0xFF0A1A0A),
            border: Border.all(
              color: canWatch
                  ? const Color(0xFF2A6030)
                  : const Color(0xFF1A2A1A),
            ),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_adLoading)
                const SizedBox(
                  width: 14, height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF44BB44)),
                )
              else
                Icon(
                  Icons.play_circle_outline,
                  color: canWatch ? const Color(0xFF44BB44) : const Color(0xFF223322),
                  size: 16,
                ),
              const SizedBox(width: 7),
              Text(
                canWatch
                    ? '마법 수정 획득 +${AdService.rewardCoins}코인  (오늘 $remaining회 남음)'
                    : '오늘의 마법 수련 완료',
                style: TextStyle(
                  color: canWatch ? const Color(0xFF66CC66) : const Color(0xFF334433),
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
      child: Row(
        children: [
          Expanded(
            child: _LobbyButton(
              symbol: '✦',
              label: '마법 소환',
              subtitle: '30코인 / 1회',
              color: const Color(0xFF5A1A8A),
              borderColor: const Color(0xFF9060CC),
              onTap: _onGachaTap,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _LobbyButton(
              symbol: '◈',
              label: '보물 창고',
              subtitle: '볼 스킨 컬렉션',
              color: const Color(0xFF0E2A40),
              borderColor: const Color(0xFF2A5080),
              onTap: _onCollectionTap,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerAd() {
    return SizedBox(
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}

// ── 공유 위젯 ────────────────────────────────────────────────

class _CoinBadge extends StatelessWidget {
  final int coins;
  const _CoinBadge({required this.coins});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0620),
        border: Border.all(color: const Color(0x88FFD700)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Text('✦', style: TextStyle(color: Color(0xFFFFD700), fontSize: 12)),
          const SizedBox(width: 5),
          Text(
            '$coins',
            style: const TextStyle(
              color: Color(0xFFFFD700),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _StageTile extends StatelessWidget {
  final int stageId;
  final bool isUnlocked;
  final int stars;
  final VoidCallback? onTap;

  const _StageTile({
    required this.stageId,
    required this.isUnlocked,
    required this.stars,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isUnlocked ? const Color(0xFF1E0C40) : const Color(0xFF080412),
          border: Border.all(
            color: isUnlocked ? const Color(0xFF5E2A90) : const Color(0xFF1A0A30),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Stack(
          children: [
            // 상단 하이라이트 (석재 느낌)
            Positioned(
              top: 0, left: 0, right: 0,
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? const Color(0x228870CC)
                      : const Color(0x11443366),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!isUnlocked)
                    const Icon(Icons.lock, color: Color(0xFF221144), size: 20)
                  else ...[
                    Text(
                      '$stageId',
                      style: const TextStyle(
                        color: Color(0xFFE0D0FF),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (i) => Icon(
                        i < stars ? Icons.star : Icons.star_border,
                        color: i < stars
                            ? const Color(0xFFFFD700)
                            : const Color(0x33B39DDB),
                        size: 11,
                      )),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LobbyButton extends StatelessWidget {
  final String symbol;
  final String label;
  final String subtitle;
  final Color color;
  final Color borderColor;
  final VoidCallback onTap;

  const _LobbyButton({
    required this.symbol,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: borderColor, width: 1),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Column(
          children: [
            Text(symbol,
                style: const TextStyle(color: Color(0xFFE0D0FF), fontSize: 22)),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(
                    color: Color(0xFFE0D0FF),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1)),
            Text(subtitle,
                style: const TextStyle(color: Color(0xFF8870AA), fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
