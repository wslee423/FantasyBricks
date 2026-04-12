import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'components/ball.dart';
import 'components/paddle.dart';
import 'components/brick.dart';
import 'components/item_drop.dart';
import 'components/cannon_laser.dart';
import 'systems/collision_system.dart';
import 'systems/item_system.dart';
import 'systems/stage_loader.dart';
import '../data/local_storage.dart';
import '../data/gacha_data.dart';

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
  final List<CannonLaserComponent> _lasers = [];
  final ItemSystem itemSystem = ItemSystem();

  Color get _ballSkinColor {
    final skin = GachaData.findById(LocalStorage.getEquippedSkin());
    return skin?.color ?? const Color(0xFFFFFFFF);
  }

  final ValueNotifier<int> livesNotifier = ValueNotifier(3);
  final ValueNotifier<String?> toastNotifier = ValueNotifier(null);
  int get lives => livesNotifier.value;
  set lives(int v) => livesNotifier.value = v;

  GameState state = GameState.waiting;
  int currentStageId;

  BrickBreakerGame({int startStageId = 1}) : currentStageId = startStageId;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    overlays.add(overlayHud);
    await _loadStage(currentStageId);
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
      skinColor: _ballSkinColor,
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

    for (final laser in [..._lasers]) {
      if (laser.isOutOfTop()) {
        laser.removeFromParent();
        _lasers.remove(laser);
      }
    }

    // 화염포 자동 발사
    if (itemSystem.updateCannon(dt, _balls)) {
      _fireCannon();
    }

    if (_bricks.isEmpty && state == GameState.playing) {
      _onCleared();
    }
  }

  void _fireCannon() {
    final laser = CannonLaserComponent(
      position: Vector2(_paddle.position.x, _paddle.position.y - _paddle.size.y / 2),
      onBrickHit: _onLaserHitBrick,
    );
    _lasers.add(laser);
    add(laser);
    itemSystem.onCannonFired(_balls);
  }

  void _onLaserHitBrick(BrickComponent brick) {
    brick.hit();
    if (brick.isDead) removeBrick(brick);
    _lasers.removeWhere((l) => !l.isMounted);
  }

  void _onCleared() {
    state = GameState.cleared;
    LocalStorage.saveStageResult(currentStageId, lives);
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
    _items.remove(source);
    itemSystem.activate(itemId, _balls, skinColor: _ballSkinColor);

    // 화염포 토스트 안내 (OD-010)
    if (itemId == 'cannon') {
      _showToast('🔴 마법 화염포 — 자동 발사 시작!');
    }

    if (itemId == 'split_ball' && _balls.isNotEmpty) {
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
          skinColor: _ballSkinColor,
        )
          ..velocity = b.velocity.clone()
          ..paint = b.paint  // createSplitBalls가 설정한 노란색 유지
          ..isLaunched = true;
        _balls.add(ballWithCollision);
        add(ballWithCollision);
      }
    }
  }

  void _showToast(String message) {
    toastNotifier.value = message;
    Future.delayed(const Duration(seconds: 2), () {
      toastNotifier.value = null;
    });
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
    for (final laser in [..._lasers]) { laser.removeFromParent(); }
    _lasers.clear();
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

  _BallWithCollision({
    required super.position,
    required this.game,
    super.skinColor = const Color(0xFFFFFFFF),
  });

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
