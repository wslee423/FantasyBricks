import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';

/// HP에 따른 마법석 색상: 흑요석 → 남옥 → 자수정 → 보라수정 → 파쇄수정
const _hpColors = {
  5: Color(0xFF120A28),  // 흑요석 — 가장 단단
  4: Color(0xFF2D1265),  // 심연 청금석
  3: Color(0xFF5E1FA0),  // 자수정 돌
  2: Color(0xFF9040CC),  // 보라 수정
  1: Color(0xFFBB88EE),  // 파쇄 수정 — 약해져 빛이 새어나옴
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
    paint = Paint()..color = _hpColors[hp] ?? const Color(0xFFBB88EE);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // ── 3D 석재 효과 ──────────────────────────────────────
    // 상단 + 좌측 하이라이트 (빛이 위에서 닿는 면)
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, 2.5),
      Paint()..color = Colors.white.withValues(alpha: 0.18),
    );
    canvas.drawRect(
      Rect.fromLTWH(0, 0, 2.0, size.y),
      Paint()..color = Colors.white.withValues(alpha: 0.10),
    );

    // 하단 + 우측 그림자 (돌의 깊이감)
    canvas.drawRect(
      Rect.fromLTWH(0, size.y - 2.5, size.x, 2.5),
      Paint()..color = Colors.black.withValues(alpha: 0.45),
    );
    canvas.drawRect(
      Rect.fromLTWH(size.x - 2.0, 0, 2.0, size.y),
      Paint()..color = Colors.black.withValues(alpha: 0.35),
    );

    // ── 마법 룬 금색 테두리 (아이템 드롭 힌트) ────────────
    if (itemDrop != null) {
      canvas.drawRect(
        Rect.fromLTWH(0.5, 0.5, size.x - 1, size.y - 1),
        Paint()
          ..color = const Color(0xFFFFD700).withValues(alpha: 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0,
      );
    }
  }
}
