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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Fantasy Bricks',
            style: TextStyle(
              color: Color(0xFFFFD700),
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          Row(
            children: [
              const Icon(Icons.toll, color: Color(0xFFFFD700), size: 20),
              const SizedBox(width: 4),
              Text(
                '$_coins',
                style: const TextStyle(
                  color: Color(0xFFFFD700),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStageGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.0,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
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
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: GestureDetector(
        onTap: canWatch ? _onAdTap : null,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: canWatch ? const Color(0xFF1A4020) : const Color(0xFF0D1A0D),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: canWatch ? const Color(0xFF44BB44) : const Color(0xFF1A3020),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_adLoading)
                const SizedBox(
                  width: 16, height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white54),
                )
              else
                Icon(
                  Icons.play_circle_outline,
                  color: canWatch ? const Color(0xFF44BB44) : Colors.white24,
                  size: 20,
                ),
              const SizedBox(width: 8),
              Text(
                canWatch
                    ? '광고 시청 +${AdService.rewardCoins}코인 (오늘 $remaining회 남음)'
                    : '오늘 광고 시청 완료 (내일 다시)',
                style: TextStyle(
                  color: canWatch ? const Color(0xFF88DD88) : Colors.white24,
                  fontSize: 13,
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
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: _LobbyButton(
              icon: Icons.auto_awesome,
              label: '마법 뽑기',
              subtitle: '30코인',
              color: const Color(0xFF7B2FBE),
              onTap: _onGachaTap,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _LobbyButton(
              icon: Icons.collections,
              label: '컬렉션',
              subtitle: '볼 스킨',
              color: const Color(0xFF1E5799),
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
          color: isUnlocked ? const Color(0xFF2A1050) : const Color(0xFF0D0620),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUnlocked ? const Color(0xFF7B2FBE) : const Color(0xFF3A2060),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!isUnlocked)
              const Icon(Icons.lock, color: Color(0xFF3A2060), size: 28)
            else ...[
              Text(
                '$stageId',
                style: const TextStyle(
                  color: Color(0xFFE0D0FF),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) {
                  return Icon(
                    i < stars ? Icons.star : Icons.star_border,
                    color: const Color(0xFFFFD700),
                    size: 14,
                  );
                }),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LobbyButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _LobbyButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold)),
            Text(subtitle,
                style: const TextStyle(color: Colors.white60, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
