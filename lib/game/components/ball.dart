import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';

class BallComponent extends CircleComponent with CollisionCallbacks {
  static const double ballRadius = 8;
  static const double defaultSpeed = 400;

  Vector2 velocity;
  bool isLaunched = false;

  BallComponent({required Vector2 position, Color skinColor = const Color(0xFFFFFFFF)})
      : velocity = Vector2(200, -defaultSpeed),
        super(
          radius: ballRadius,
          anchor: Anchor.center,
          position: position,
          paint: Paint()..color = skinColor,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!isLaunched) return;
    position.addScaled(velocity, dt);
  }

  void launch() {
    isLaunched = true;
  }

  void reflectX() => velocity.x = -velocity.x;
  void reflectY() => velocity.y = -velocity.y;

  void clampToBounds(double width, double height) {
    if (position.x - ballRadius <= 0) {
      position.x = ballRadius;
      reflectX();
    } else if (position.x + ballRadius >= width) {
      position.x = width - ballRadius;
      reflectX();
    }
    if (position.y - ballRadius <= 0) {
      position.y = ballRadius;
      reflectY();
    }
  }

  bool isOutOfBottom(double height) => position.y - ballRadius > height;
}
