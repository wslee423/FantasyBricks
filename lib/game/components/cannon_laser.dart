import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'brick.dart';

class CannonLaserComponent extends RectangleComponent with CollisionCallbacks {
  static const double _speed = 600;
  static const double _width = 6;

  final void Function(BrickComponent brick) onBrickHit;

  CannonLaserComponent({
    required Vector2 position,
    required this.onBrickHit,
  }) : super(
          size: Vector2(_width, 20),
          anchor: Anchor.bottomCenter,
          position: position,
          paint: Paint()..color = const Color(0xFFFF6B6B),
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.y -= _speed * dt;
  }

  bool isOutOfTop() => position.y < 0;

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is BrickComponent) {
      onBrickHit(other);
      removeFromParent();
    }
  }
}
