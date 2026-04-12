import 'package:flutter/material.dart';
import '../../game/brick_breaker_game.dart';

class GameOverOverlay extends StatelessWidget {
  final BrickBreakerGame game;

  const GameOverOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '게임 오버',
              style: TextStyle(
                color: Color(0xFFFF4D6D),
                fontSize: 36,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '마법이 다 소진되었습니다...',
              style: TextStyle(
                color: Color(0xFFB39DDB),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: game.restart,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7B2FBE),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('다시 하기'),
            ),
          ],
        ),
      ),
    );
  }
}
