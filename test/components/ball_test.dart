import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fantasy_bricks/game/components/ball.dart';

void main() {
  group('BallComponent', () {
    test('초기 상태에서 isLaunched는 false다', () {
      final ball = BallComponent(position: Vector2(100, 100));
      expect(ball.isLaunched, false);
    });

    test('launch() 호출 후 isLaunched는 true다', () {
      final ball = BallComponent(position: Vector2(100, 100));
      ball.launch();
      expect(ball.isLaunched, true);
    });

    test('reflectX는 velocity.x 부호를 반전한다', () {
      final ball = BallComponent(position: Vector2(100, 100));
      final originalX = ball.velocity.x;
      ball.reflectX();
      expect(ball.velocity.x, -originalX);
    });

    test('reflectY는 velocity.y 부호를 반전한다', () {
      final ball = BallComponent(position: Vector2(100, 100));
      final originalY = ball.velocity.y;
      ball.reflectY();
      expect(ball.velocity.y, -originalY);
    });

    test('isOutOfBottom은 화면 아래로 벗어났을 때 true다', () {
      final ball = BallComponent(position: Vector2(100, 900));
      expect(ball.isOutOfBottom(800), true);
    });

    test('isOutOfBottom은 화면 안에 있을 때 false다', () {
      final ball = BallComponent(position: Vector2(100, 400));
      expect(ball.isOutOfBottom(800), false);
    });
  });
}
