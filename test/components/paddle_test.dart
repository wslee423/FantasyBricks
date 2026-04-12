import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fantasy_bricks/game/components/paddle.dart';

void main() {
  group('PaddleComponent', () {
    test('기본 크기는 100x16이다', () {
      final paddle = PaddleComponent(
        screenWidth: 400,
        position: Vector2(200, 700),
      );
      expect(paddle.size.x, 100);
      expect(paddle.size.y, 16);
    });

    test('anchor가 center다', () {
      final paddle = PaddleComponent(
        screenWidth: 400,
        position: Vector2(200, 700),
      );
      expect(paddle.anchor, Anchor.center);
    });
  });
}
