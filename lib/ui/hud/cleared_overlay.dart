import 'package:flutter/material.dart';
import '../../game/brick_breaker_game.dart';

class ClearedOverlay extends StatelessWidget {
  final BrickBreakerGame game;
  final VoidCallback? onLobby;

  const ClearedOverlay({super.key, required this.game, this.onLobby});

  @override
  Widget build(BuildContext context) {
    final stars = game.lives;
    return Container(
      color: const Color(0xCC0D0620),
      child: Center(
        child: _FantasyPanel(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '✦  승리  ✦',
                style: TextStyle(
                  color: Color(0xFFFFD700),
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 6,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                '마법이 악을 물리쳤습니다',
                style: TextStyle(
                  color: Color(0xFFB39DDB),
                  fontSize: 13,
                  letterSpacing: 1,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      i < stars ? Icons.star : Icons.star_border,
                      color: i < stars
                          ? const Color(0xFFFFD700)
                          : const Color(0x44B39DDB),
                      size: 38,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 28),
              _FantasyButton(
                label: '다시 도전',
                onTap: game.restart,
                color: const Color(0xFF7B2FBE),
              ),
              if (onLobby != null) ...[
                const SizedBox(height: 10),
                TextButton(
                  onPressed: onLobby,
                  child: const Text(
                    '◂ 모험 지도로',
                    style: TextStyle(
                      color: Color(0xFF8870AA),
                      fontSize: 14,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── 공유 위젯 ────────────────────────────────────────────────

class _FantasyPanel extends StatelessWidget {
  final Widget child;

  const _FantasyPanel({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
      decoration: BoxDecoration(
        color: const Color(0xFF1A0A3D),
        border: Border.all(color: const Color(0xFFB39DDB), width: 1),
        borderRadius: BorderRadius.circular(2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x88B39DDB),
            blurRadius: 24,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 상단 장식선
          const Row(
            children: [
              Expanded(child: Divider(color: Color(0x66FFD700), thickness: 1)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('✦', style: TextStyle(color: Color(0xFFFFD700), fontSize: 10)),
              ),
              Expanded(child: Divider(color: Color(0x66FFD700), thickness: 1)),
            ],
          ),
          const SizedBox(height: 16),
          child,
          const SizedBox(height: 16),
          const Row(
            children: [
              Expanded(child: Divider(color: Color(0x66FFD700), thickness: 1)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('✦', style: TextStyle(color: Color(0xFFFFD700), fontSize: 10)),
              ),
              Expanded(child: Divider(color: Color(0x66FFD700), thickness: 1)),
            ],
          ),
        ],
      ),
    );
  }
}

class _FantasyButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _FantasyButton({
    required this.label,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 44, vertical: 13),
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: const Color(0x88E0D0FF), width: 1),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}
