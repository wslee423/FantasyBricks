import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class PaddleComponent extends RectangleComponent
    with DragCallbacks, CollisionCallbacks {
  final double screenWidth;

  PaddleComponent({required this.screenWidth, required Vector2 position})
      : super(
          size: Vector2(100, 16),
          anchor: Anchor.center,
          position: position,
          paint: Paint()..color = const Color(0xFFE0D0FF),
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox());
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    position.x += event.localDelta.x;
    position.x = position.x.clamp(size.x / 2, screenWidth - size.x / 2);
  }
}
