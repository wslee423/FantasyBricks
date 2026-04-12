import 'dart:math' as math;
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import '../components/ball.dart';
import '../components/brick.dart';
import '../components/paddle.dart';

class CollisionSystem {
  static void handleBallBrick(BallComponent ball, BrickComponent brick) {
    final ballCenter = ball.position;
    final brickRect = brick.toRect();

    final overlapX = (brickRect.right - brickRect.left) / 2 -
        (ballCenter.x - brickRect.center.dx).abs();
    final overlapY = (brickRect.bottom - brickRect.top) / 2 -
        (ballCenter.y - brickRect.center.dy).abs();

    if (overlapX < overlapY) {
      ball.reflectX();
    } else {
      ball.reflectY();
    }

    brick.hit();
  }

  static void handleBallPaddle(BallComponent ball, PaddleComponent paddle) {
    final hitX = ball.position.x - paddle.position.x;
    final normalized = hitX / (paddle.size.x / 2);
    final angle = normalized * 60;

    final speed = ball.velocity.length;
    final radians = angle * (math.pi / 180);
    ball.velocity
      ..x = speed * math.sin(radians)
      ..y = -speed * math.cos(radians);

    ball.position.y = paddle.position.y - paddle.size.y / 2 - BallComponent.ballRadius;
  }
}

mixin BallCollisionMixin on CircleComponent, CollisionCallbacks {
  void onBrickHit(BrickComponent brick);
  void onPaddleHit(PaddleComponent paddle);

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is BrickComponent) onBrickHit(other);
    if (other is PaddleComponent) onPaddleHit(other);
  }
}
