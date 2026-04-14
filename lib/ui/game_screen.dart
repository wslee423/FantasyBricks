import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../game/brick_breaker_game.dart';
import '../data/local_storage.dart';
import 'hud/hud_overlay.dart';
import 'hud/cleared_overlay.dart';
import 'hud/game_over_overlay.dart';
import 'tutorial/tutorial_overlay.dart';

class GameScreenWrapper extends StatefulWidget {
  final int stageId;

  const GameScreenWrapper({super.key, required this.stageId});

  @override
  State<GameScreenWrapper> createState() => _GameScreenWrapperState();
}

class _GameScreenWrapperState extends State<GameScreenWrapper> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = BrickBreakerGame(startStageId: widget.stageId);
    return Scaffold(
      body: GameWidget(
        game: game,
        initialActiveOverlays: LocalStorage.isTutorialDone()
            ? const []
            : const [overlayTutorial],
        overlayBuilderMap: {
          overlayTutorial: (ctx, g) => TutorialOverlay(
                onDone: () {
                  (g as BrickBreakerGame).overlays.remove(overlayTutorial);
                },
              ),
          overlayHud: (ctx, g) => HudOverlay(game: g as BrickBreakerGame),
          overlayCleared: (ctx, g) => ClearedOverlay(
                game: g as BrickBreakerGame,
                onLobby: () => Navigator.pop(ctx),
              ),
          overlayGameOver: (ctx, g) => GameOverOverlay(
                game: g as BrickBreakerGame,
                onLobby: () => Navigator.pop(ctx),
              ),
        },
      ),
    );
  }
}
