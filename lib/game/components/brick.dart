import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';

const _hpColors = {
  5: Color(0xFF2D1B69),
  4: Color(0xFF4A0E8F),
  3: Color(0xFF7B2FBE),
  2: Color(0xFF9B59B6),
  1: Color(0xFFC8A8E9),
};

class BrickComponent extends RectangleComponent with CollisionCallbacks {
  int hp;
  final String? itemDrop;

  BrickComponent({
    required Vector2 position,
    required Vector2 size,
    required this.hp,
    this.itemDrop,
  }) : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox());
    _updateColor();
  }

  void hit() {
    hp--;
    if (hp <= 0) {
      removeFromParent();
    } else {
      _updateColor();
    }
  }

  bool get isDead => hp <= 0;

  void _updateColor() {
    paint = Paint()..color = _hpColors[hp] ?? const Color(0xFFC8A8E9);
  }
}
