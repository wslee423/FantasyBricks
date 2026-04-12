import 'package:flutter/material.dart';
import '../../game/brick_breaker_game.dart';

class GameOverOverlay extends StatelessWidget {
  final BrickBreakerGame game;
  final VoidCallback? onLobby;

  const GameOverOverlay({super.key, required this.game, this.onLobby});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xDD0D0620),
      child: Center(
        child: _FantasyPanel(
          borderColor: const Color(0x88FF4D6D),
          glowColor: const Color(0x66FF4D6D),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '⚔  패배  ⚔',
                style: TextStyle(
                  color: Color(0xFFFF4D6D),
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 6,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '마법이 다 소진되었습니다...',
                style: TextStyle(
                  color: Color(0xFF8870AA),
                  fontSize: 13,
                  letterSpacing: 1,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 28),
              _FantasyButton(
                label: '재도전',
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
                      color: Color(0xFF664466),
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

class _FantasyPanel extends StatelessWidget {
  final Widget child;
  final Color borderColor;
  final Color glowColor;

  const _FantasyPanel({
    required this.child,
    this.borderColor = const Color(0xFFB39DDB),
    this.glowColor = const Color(0x88B39DDB),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
      decoration: BoxDecoration(
        color: const Color(0xFF1A0A3D),
        border: Border.all(color: borderColor, width: 1),
        borderRadius: BorderRadius.circular(2),
        boxShadow: [
          BoxShadow(color: glowColor, blurRadius: 24, spreadRadius: 2),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _dividerRow(borderColor),
          const SizedBox(height: 16),
          child,
          const SizedBox(height: 16),
          _dividerRow(borderColor),
        ],
      ),
    );
  }

  Widget _dividerRow(Color color) {
    final dim = color.withValues(alpha: 0.5);
    return Row(
      children: [
        Expanded(child: Divider(color: dim, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text('✦', style: TextStyle(color: dim, fontSize: 10)),
        ),
        Expanded(child: Divider(color: dim, thickness: 1)),
      ],
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
