import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fantasy_bricks/game/components/ball.dart';
import 'package:fantasy_bricks/game/systems/item_system.dart';

void main() {
  group('ItemSystem', () {
    test('초기 상태는 none이고 remainingHits는 0이다', () {
      final system = ItemSystem();
      expect(system.current, ActiveItem.none);
      expect(system.remainingHits, 0);
    });

    test('split_ball 활성화 시 current가 splitBall이 된다', () {
      final system = ItemSystem();
      final ball = BallComponent(position: Vector2(100, 100))..launch();
      system.activate('split_ball', [ball]);
      expect(system.current, ActiveItem.splitBall);
      expect(system.remainingHits, ItemSystem.maxHits);
    });

    test('piercing_ball 활성화 시 isPiercing이 true다', () {
      final system = ItemSystem();
      final ball = BallComponent(position: Vector2(100, 100));
      system.activate('piercing_ball', [ball]);
      expect(system.isPiercing, true);
    });

    test('onHit을 maxHits번 호출하면 만료되고 none으로 돌아온다', () {
      final system = ItemSystem();
      final ball = BallComponent(position: Vector2(100, 100));
      system.activate('split_ball', [ball]);
      for (var i = 0; i < ItemSystem.maxHits - 1; i++) {
        expect(system.onHit([ball]), false);
      }
      final expired = system.onHit([ball]);
      expect(expired, true);
      expect(system.current, ActiveItem.none);
    });

    test('새 아이템 활성화 시 기존 아이템이 즉시 교체된다', () {
      final system = ItemSystem();
      final ball = BallComponent(position: Vector2(100, 100));
      system.activate('piercing_ball', [ball]);
      system.activate('split_ball', [ball]);
      expect(system.current, ActiveItem.splitBall);
    });

    test('createSplitBalls는 볼 2개를 반환한다', () {
      final system = ItemSystem();
      final source = BallComponent(position: Vector2(200, 400))
        ..velocity = Vector2(100, -300)
        ..launch();
      final splits = system.createSplitBalls(source);
      expect(splits.length, 2);
      for (final b in splits) {
        expect(b.isLaunched, true);
      }
    });

    test('createSplitBalls 두 볼은 서로 다른 Vector2 인스턴스를 가진다', () {
      final system = ItemSystem();
      final source = BallComponent(position: Vector2(200, 400))
        ..velocity = Vector2(100, -300)
        ..launch();
      final splits = system.createSplitBalls(source);
      expect(identical(splits[0].velocity, splits[1].velocity), false);
    });

    test('maxHits는 10이다', () {
      expect(ItemSystem.maxHits, 10);
    });

    test('reset 후 current는 none이다', () {
      final system = ItemSystem();
      final ball = BallComponent(position: Vector2(100, 100));
      system.activate('cannon', [ball]);
      system.reset([ball]);
      expect(system.current, ActiveItem.none);
      expect(system.remainingHits, 0);
    });
  });
}
