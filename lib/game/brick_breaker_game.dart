import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'components/ball.dart';
import 'components/paddle.dart';
import 'components/brick.dart';
import 'components/item_drop.dart';
import 'systems/collision_system.dart';
import 'systems/item_system.dart';
import 'systems/stage_loader.dart';

enum GameState { waiting, playing, cleared, gameOver }

const overlayHud = 'hud';
const overlayCleared = 'cleared';
const overlayGameOver = 'gameOver';

class BrickBreakerGame extends FlameGame
    with TapCallbacks, HasCollisionDetection {
  late PaddleComponent _paddle;
  final List<BallComponent> _balls = [];
  final List<BrickComponent> _bricks = [];
  final List<ItemDropComponent> _items = [];
  final ItemSystem itemSystem = ItemSystem();

  final ValueNotifier<int> livesNotifier = ValueNotifier(3);
  int get lives => livesNotifier.value;
  set lives(int v) => livesNotifier.value = v;

  GameState state = GameState.waiting;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    overlays.add(overlayHud);
    await _loadStage(1);
  }

  Future<void> _loadStage(int stageId) async {
    final stageData = await StageLoader.load(stageId);

    final double areaTop = size.y * 0.15;
    final double areaHeight = size.y * 0.55;
    final double brickW = size.x / stageData.gridCols;
    final double brickH = areaHeight / stageData.gridRows;

    for (final b in stageData.bricks) {
      final brick = BrickComponent(
        position: Vector2(b.col * brickW + 1, areaTop + b.row * brickH + 1),
        size: Vector2(brickW - 2, brickH - 2),
        hp: b.hp,
        itemDrop: b.itemDrop,
      );
      _bricks.add(brick);
      add(brick);
    }

    _paddle = PaddleComponent(
      screenWidth: size.x,
      position: Vector2(size.x / 2, size.y * 0.88),
    );
    add(_paddle);

    _spawnBall();
  }

  void _spawnBall() {
    final ball = _BallWithCollision(
      position: Vector2(_paddle.position.x, _paddle.position.y - 20),
      game: this,
    );
    _balls.add(ball);
    add(ball);
    state = GameState.waiting;
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (state == GameState.waiting) {
      for (final ball in _balls) {
        ball.launch();
      }
      state = GameState.playing;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (state != GameState.playing) return;

    for (final ball in [..._balls]) {
      ball.clampToBounds(size.x, size.y);
      if (ball.isOutOfBottom(size.y)) {
        _onBallLost(ball);
      }
    }

    for (final item in [..._items]) {
      if (item.isOutOfBottom(size.y)) {
        item.removeFromParent();
        _items.remove(item);
      }
    }

    if (_bricks.isEmpty && state == GameState.playing) {
      _onCleared();
    }
  }

  void _onCleared() {
    state = GameState.cleared;
    overlays.add(overlayCleared);
  }

  void _onBallLost(BallComponent ball) {
    ball.removeFromParent();
    _balls.remove(ball);

    if (_balls.isEmpty) {
      itemSystem.reset(_balls);
      lives--;
      if (lives <= 0) {
        state = GameState.gameOver;
        overlays.add(overlayGameOver);
      } else {
        _spawnBall();
      }
    }
  }

  void removeBrick(BrickComponent brick) {
    _bricks.remove(brick);
    if (brick.itemDrop != null) {
      _spawnItem(brick.itemDrop!, brick.position + brick.size / 2);
    }
  }

  void _spawnItem(String itemId, Vector2 position) {
    late ItemDropComponent item;
    item = ItemDropComponent(
      position: position.clone(),
      itemId: itemId,
      onCollected: (id) => _onItemCollected(id, item),
    );
    _items.add(item);
    add(item);
  }

  void _onItemCollected(String itemId, ItemDropComponent source) {
    // Bug fix 3: 특정 인스턴스만 제거
    _items.remove(source);

    itemSystem.activate(itemId, _balls);

    if (itemId == 'split_ball' && _balls.isNotEmpty) {
      // Bug fix 1: wasNone 조건 제거 — 항상 분열 실행
      // 이미 분열 중이면 볼 1개로 정규화 후 3개로 다시 분열
      while (_balls.length > 1) {
        final extra = _balls.removeLast();
        extra.removeFromParent();
      }
      final origin = _balls.first;
      final splitBalls = itemSystem.createSplitBalls(origin);
      for (final b in splitBalls) {
        final ballWithCollision = _BallWithCollision(
          position: b.position.clone(),
          game: this,
        )
          // Bug fix 2: clone()으로 Vector2 공유 참조 방지
          ..velocity = b.velocity.clone()
          ..paint = b.paint
          ..isLaunched = true;
        _balls.add(ballWithCollision);
        add(ballWithCollision);
      }
    }
  }

  void onBallHitBrick() {
    itemSystem.onHit(_balls);
  }

  void restart() {
    overlays.remove(overlayCleared);
    overlays.remove(overlayGameOver);

    for (final ball in [..._balls]) { ball.removeFromParent(); }
    _balls.clear();
    for (final brick in [..._bricks]) { brick.removeFromParent(); }
    _bricks.clear();
    for (final item in [..._items]) { item.removeFromParent(); }
    _items.clear();
    _paddle.removeFromParent();

    itemSystem.reset([]);
    lives = 3;
    state = GameState.waiting;

    _loadStage(1);
  }

  @override
  Color backgroundColor() => const Color(0xFF1A0A3D);
}

class _BallWithCollision extends BallComponent {
  final BrickBreakerGame game;

  _BallWithCollision({required super.position, required this.game});

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is BrickComponent) {
      if (!game.itemSystem.isPiercing) {
        CollisionSystem.handleBallBrick(this, other);
      } else {
        other.hit();
      }
      game.onBallHitBrick();
      if (other.isDead) game.removeBrick(other);
    } else if (other is PaddleComponent) {
      CollisionSystem.handleBallPaddle(this, other);
    }
  }
}
