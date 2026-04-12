import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fantasy_bricks/game/components/ball.dart';
import 'package:fantasy_bricks/game/components/brick.dart';
import 'package:fantasy_bricks/game/components/paddle.dart';
import 'package:fantasy_bricks/game/systems/collision_system.dart';

void main() {
  group('CollisionSystem', () {
    test('handleBallBrick: 볼 velocity.y가 반전된다 (수직 충돌)', () {
      final ball = BallComponent(position: Vector2(50, 99));
      ball.velocity = Vector2(0, 300);
      final brick = BrickComponent(
        position: Vector2(0, 100),
        size: Vector2(60, 20),
        hp: 1,
      );
      final originalY = ball.velocity.y;
      CollisionSystem.handleBallBrick(ball, brick);
      expect(ball.velocity.y, -originalY);
    });

    test('handleBallBrick: 벽돌 hp가 1 감소한다', () {
      final ball = BallComponent(position: Vector2(50, 99));
      ball.velocity = Vector2(0, 300);
      final brick = BrickComponent(
        position: Vector2(0, 100),
        size: Vector2(60, 20),
        hp: 2,
      );
      CollisionSystem.handleBallBrick(ball, brick);
      expect(brick.hp, 1);
    });

    test('handleBallPaddle: 볼 velocity.y가 음수(위쪽)가 된다', () {
      final ball = BallComponent(position: Vector2(200, 680));
      ball.velocity = Vector2(100, 300);
      final paddle = PaddleComponent(
        screenWidth: 400,
        position: Vector2(200, 700),
      );
      CollisionSystem.handleBallPaddle(ball, paddle);
      expect(ball.velocity.y, isNegative);
    });
  });
}
