import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'game/brick_breaker_game.dart';
import 'ui/hud/hud_overlay.dart';
import 'ui/hud/cleared_overlay.dart';
import 'ui/hud/game_over_overlay.dart';

void main() {
  runApp(const FantasyBricksApp());
}

class FantasyBricksApp extends StatelessWidget {
  const FantasyBricksApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fantasy Bricks',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = BrickBreakerGame();
    return Scaffold(
      body: GameWidget(
        game: game,
        overlayBuilderMap: {
          overlayHud: (context, g) =>
              HudOverlay(game: g as BrickBreakerGame),
          overlayCleared: (context, g) =>
              ClearedOverlay(game: g as BrickBreakerGame),
          overlayGameOver: (context, g) =>
              GameOverOverlay(game: g as BrickBreakerGame),
        },
      ),
    );
  }
}
