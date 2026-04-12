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
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '스테이지 클리어!',
              style: TextStyle(
                color: Color(0xFFFFD700),
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) {
                return Icon(
                  i < stars ? Icons.star : Icons.star_border,
                  color: const Color(0xFFFFD700),
                  size: 40,
                );
              }),
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
            if (onLobby != null) ...[
              const SizedBox(height: 12),
              TextButton(
                onPressed: onLobby,
                child: const Text(
                  '로비로',
                  style: TextStyle(color: Colors.white54, fontSize: 16),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
