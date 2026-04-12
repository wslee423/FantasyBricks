import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fantasy_bricks/game/brick_breaker_game.dart';
import 'package:fantasy_bricks/ui/hud/hud_overlay.dart';

void main() {
  group('HudOverlay 상태 반응성', () {
    testWidgets('초기 상태에서 채워진 하트 3개가 표시된다', (tester) async {
      final game = BrickBreakerGame();
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: HudOverlay(game: game))),
      );
      expect(find.byIcon(Icons.favorite), findsNWidgets(3));
      expect(find.byIcon(Icons.favorite_border), findsNothing);
    });

    testWidgets('lives가 2로 줄면 채워진 하트 2개 + 빈 하트 1개가 표시된다',
        (tester) async {
      final game = BrickBreakerGame();
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: HudOverlay(game: game))),
      );

      game.livesNotifier.value = 2;
      await tester.pump();

      expect(find.byIcon(Icons.favorite), findsNWidgets(2));
      expect(find.byIcon(Icons.favorite_border), findsNWidgets(1));
    });

    testWidgets('lives가 1로 줄면 채워진 하트 1개 + 빈 하트 2개가 표시된다',
        (tester) async {
      final game = BrickBreakerGame();
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: HudOverlay(game: game))),
      );

      game.livesNotifier.value = 1;
      await tester.pump();

      expect(find.byIcon(Icons.favorite), findsNWidgets(1));
      expect(find.byIcon(Icons.favorite_border), findsNWidgets(2));
    });
  });
}
