import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../components/ball.dart';

enum ActiveItem { none, piercingBall, splitBall, cannon }

class ItemSystem {
  static const int maxHits = 10;
  static const double cannonInterval = 0.5;

  ActiveItem current = ActiveItem.none;
  int remainingHits = 0;
  double _cannonTimer = 0;
  Color _skinColor = const Color(0xFFFFFFFF);

  final ValueNotifier<ActiveItem> activeItemNotifier =
      ValueNotifier(ActiveItem.none);
  final ValueNotifier<int> remainingHitsNotifier = ValueNotifier(0);

  static final math.Random _random = math.Random();

  /// [skinColor]: 아이템 만료 시 복원할 볼 스킨 색.
  void activate(String itemId, List<BallComponent> balls, {Color skinColor = const Color(0xFFFFFFFF)}) {
    _skinColor = skinColor;
    _deactivate(balls);

    switch (itemId) {
      case 'piercing_ball':
        current = ActiveItem.piercingBall;
        for (final b in balls) {
          b.paint = Paint()..color = const Color(0xFF4FC3F7);
        }
      case 'split_ball':
        current = ActiveItem.splitBall;
        for (final b in balls) {
          b.paint = Paint()..color = const Color(0xFFFFD54F);
        }
      case 'cannon':
        current = ActiveItem.cannon;
        for (final b in balls) {
          b.paint = Paint()..color = const Color(0xFFEF5350);
        }
        _cannonTimer = 0;
      default:
        return;
    }

    remainingHits = maxHits;
    activeItemNotifier.value = current;
    remainingHitsNotifier.value = remainingHits;
  }

  /// cannon 활성화 중 매 프레임 호출. 발사 여부 반환.
  bool updateCannon(double dt, List<BallComponent> balls) {
    if (current != ActiveItem.cannon) return false;
    _cannonTimer += dt;
    if (_cannonTimer >= cannonInterval) {
      _cannonTimer -= cannonInterval;
      return true;
    }
    return false;
  }

  /// cannon 발사 1회 = 타격 1회
  void onCannonFired(List<BallComponent> balls) => onHit(balls);

  /// 볼/레이저 충돌 1회 시 호출. 만료 여부 반환.
  bool onHit(List<BallComponent> balls) {
    if (current == ActiveItem.none) return false;
    remainingHits--;
    remainingHitsNotifier.value = remainingHits;
    if (remainingHits <= 0) {
      _deactivate(balls);
      return true;
    }
    return false;
  }

  bool get isPiercing => current == ActiveItem.piercingBall;
  bool get isCannon => current == ActiveItem.cannon;

  /// 마법 분열구: 현재 볼 기준 ±30° 랜덤으로 2개 추가 생성.
  List<BallComponent> createSplitBalls(BallComponent source) {
    final result = <BallComponent>[];
    for (final offsetDeg in [-30.0, 30.0]) {
      final randomDeg = offsetDeg + (_random.nextDouble() * 10 - 5);
      final radians = randomDeg * (math.pi / 180);
      final cos = math.cos(radians);
      final sin = math.sin(radians);
      final vx = source.velocity.x * cos - source.velocity.y * sin;
      final vy = source.velocity.x * sin + source.velocity.y * cos;
      final ball = BallComponent(position: source.position.clone())
        ..velocity.setValues(vx, vy)
        ..paint = (Paint()..color = const Color(0xFFFFD54F))
        ..isLaunched = true;
      result.add(ball);
    }
    return result;
  }

  void _deactivate(List<BallComponent> balls) {
    current = ActiveItem.none;
    remainingHits = 0;
    _cannonTimer = 0;
    activeItemNotifier.value = ActiveItem.none;
    remainingHitsNotifier.value = 0;
    for (final b in balls) {
      b.paint = Paint()..color = _skinColor;
    }
  }

  void reset(List<BallComponent> balls) => _deactivate(balls);
}
