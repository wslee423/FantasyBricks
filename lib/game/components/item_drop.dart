import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'paddle.dart';

const _itemColors = {
  'piercing_ball': Color(0xFF4FC3F7),
  'split_ball': Color(0xFFFFD54F),
  'cannon': Color(0xFFEF5350),
};

/// 한글 레이블 없음 — 형태·색으로 식별
/// ◈ 관통석(파랑), ✦ 분열구(황금), ⚡ 화염포(빨강)
const _itemSymbols = {
  'piercing_ball': '◈',
  'split_ball': '✦',
  'cannon': '⚡',
};

class ItemDropComponent extends CircleComponent with CollisionCallbacks {
  static const double _radius = 14.0;
  static const double _speed = 200;

  final String itemId;
  final void Function(String itemId) onCollected;

  late final Color _color;

  ItemDropComponent({
    required Vector2 position,
    required this.itemId,
    required this.onCollected,
  })  : _color = _itemColors[itemId] ?? const Color(0xFFFFFFFF),
        super(
          radius: _radius,
          anchor: Anchor.center,
          position: position,
          paint: Paint()
            ..color = (_itemColors[itemId] ?? const Color(0xFFFFFFFF))
                .withValues(alpha: 0.88),
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(CircleHitbox());
    add(
      TextComponent(
        text: _itemSymbols[itemId] ?? '?',
        textRenderer: TextPaint(
          style: const TextStyle(
            fontSize: 13,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        anchor: Anchor.center,
        position: Vector2(_radius, _radius),
      ),
    );
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // 외곽 링 — 마법 gem 효과
    canvas.drawCircle(
      const Offset(_radius, _radius),
      _radius - 1,
      Paint()
        ..color = _color.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
    // 내부 하이라이트
    canvas.drawCircle(
      const Offset(11, 11),
      3.5,
      Paint()..color = Colors.white.withValues(alpha: 0.28),
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
