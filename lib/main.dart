import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'data/local_storage.dart';
import 'game/brick_breaker_game.dart';
import 'ui/hud/hud_overlay.dart';
import 'ui/hud/cleared_overlay.dart';
import 'ui/hud/game_over_overlay.dart';
import 'ui/tutorial/tutorial_overlay.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorage.init();
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
        initialActiveOverlays: LocalStorage.isTutorialDone()
            ? const []
            : const [overlayTutorial],
        overlayBuilderMap: {
          overlayTutorial: (context, g) => TutorialOverlay(
                onDone: () {
                  (g as BrickBreakerGame).overlays.remove(overlayTutorial);
                },
              ),
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
