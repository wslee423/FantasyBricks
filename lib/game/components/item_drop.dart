import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'paddle.dart';

const _itemColors = {
  'piercing_ball': Color(0xFF4FC3F7),
  'split_ball': Color(0xFFFFD54F),
  'cannon': Color(0xFFEF5350),
};

const _itemLabels = {
  'piercing_ball': '관통',
  'split_ball': '분열',
  'cannon': '화염',
};

class ItemDropComponent extends RectangleComponent with CollisionCallbacks {
  static const double _speed = 200;
  static const double _size = 24;

  final String itemId;
  final void Function(String itemId) onCollected;

  ItemDropComponent({
    required Vector2 position,
    required this.itemId,
    required this.onCollected,
  }) : super(
          size: Vector2.all(_size),
          anchor: Anchor.center,
          position: position,
          paint: Paint()
            ..color = (_itemColors[itemId] ?? const Color(0xFFFFFFFF))
                .withValues(alpha: 0.9),
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox());
    add(
      TextComponent(
        text: _itemLabels[itemId] ?? '?',
        textRenderer: TextPaint(
          style: const TextStyle(
            fontSize: 10,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        anchor: Anchor.center,
        position: Vector2(_size / 2, _size / 2),
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.y += _speed * dt;
  }

  bool isOutOfBottom(double height) => position.y > height;

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is PaddleComponent) {
      onCollected(itemId);
      removeFromParent();
    }
  }
}
