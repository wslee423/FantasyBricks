import 'package:flutter/material.dart';
import '../../data/gacha_data.dart';
import '../../data/gacha_service.dart';
import '../../data/local_storage.dart';

class GachaScreen extends StatefulWidget {
  const GachaScreen({super.key});

  @override
  State<GachaScreen> createState() => _GachaScreenState();
}

class _GachaScreenState extends State<GachaScreen>
    with SingleTickerProviderStateMixin {
  int _coins = 0;
  int _fragments = 0;
  GachaResult? _lastResult;
  bool _drawing = false;

  late final AnimationController _animCtrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _refresh();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.elasticOut);
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _refresh() {
    setState(() {
      _coins = LocalStorage.getCoins();
      _fragments = LocalStorage.getFragments();
    });
  }

  Future<void> _draw() async {
    if (_drawing) return;
    setState(() => _drawing = true);

    final result = await GachaService.draw();
    if (result == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('마법 코인이 부족합니다 (30코인 필요)'),
            backgroundColor: Color(0xFF4A1080),
          ),
        );
      }
    } else {
      _animCtrl.reset();
      setState(() => _lastResult = result);
      _animCtrl.forward();
    }

    _refresh();
    setState(() => _drawing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A0A3D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0620),
        foregroundColor: Colors.white,
        title: const Text('마법 뽑기'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                const Icon(Icons.toll, color: Color(0xFFFFD700), size: 18),
                const SizedBox(width: 4),
                Text(
                  '$_coins',
                  style: const TextStyle(
                    color: Color(0xFFFFD700),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            _buildResultArea(),
            const Spacer(),
            _buildFragmentBar(),
            const SizedBox(height: 16),
            _buildDrawButton(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildResultArea() {
    if (_lastResult == null) {
      return const Center(
        child: Text(
          '뽑기를 눌러 마법 볼을 획득하세요',
          style: TextStyle(color: Colors.white38, fontSize: 14),
        ),
      );
    }

    final result = _lastResult!;
    final skin = result.skin;
    final gradeColor = GachaData.gradeColors[skin.grade]!;
    final gradeName = GachaData.gradeNames[skin.grade]!;

    return ScaleTransition(
      scale: _scaleAnim,
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: skin.color,
              boxShadow: [
                BoxShadow(
                  color: skin.color.withValues(alpha: 0.6),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: gradeColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: gradeColor, width: 1),
            ),
            child: Text(
              gradeName,
              style: TextStyle(
                color: gradeColor,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            skin.name,
            style: const TextStyle(
              color: Color(0xFFE0D0FF),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (result.isNew)
            const Text(
              '새로운 볼 스킨 획득!',
              style: TextStyle(color: Color(0xFF44FF88), fontSize: 14),
            )
          else
            Text(
              '이미 보유 중 → 파편 +${result.fragmentsAdded}',
              style: const TextStyle(color: Colors.white54, fontSize: 14),
            ),
        ],
      ),
    );
  }

  Widget _buildFragmentBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.broken_image, color: Color(0xFFB39DDB), size: 18),
          const SizedBox(width: 6),
          Text(
            '파편 $_fragments / ${GachaService.fragmentsForExchange}',
            style: const TextStyle(color: Color(0xFFB39DDB), fontSize: 14),
          ),
          const SizedBox(width: 8),
          const Text(
            '(30개 모으면 원하는 스킨 교환)',
            style: TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawButton() {
    final canDraw = _coins >= GachaService.drawCost;
    return ElevatedButton.icon(
      onPressed: (_drawing || !canDraw) ? null : _draw,
      icon: _drawing
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Icon(Icons.auto_awesome),
      label: const Text('뽑기 (30코인)'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF7B2FBE),
        foregroundColor: Colors.white,
        disabledBackgroundColor: const Color(0xFF3A1060),
        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
