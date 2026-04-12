import 'package:flutter/material.dart';
import '../../game/brick_breaker_game.dart';
import '../../game/systems/item_system.dart';

class HudOverlay extends StatelessWidget {
  final BrickBreakerGame game;

  const HudOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLivesBar(),
          ValueListenableBuilder<ActiveItem>(
            valueListenable: game.itemSystem.activeItemNotifier,
            builder: (context, activeItem, _) {
              if (activeItem == ActiveItem.none) return const SizedBox.shrink();
              return ValueListenableBuilder<int>(
                valueListenable: game.itemSystem.remainingHitsNotifier,
                builder: (context, remaining, _) {
                  return _ItemHud(item: activeItem, remaining: remaining);
                },
              );
            },
          ),
          ValueListenableBuilder<String?>(
            valueListenable: game.toastNotifier,
            builder: (context, toast, _) {
              if (toast == null) return const SizedBox.shrink();
              return _ToastBanner(message: toast);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLivesBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xCC0D0620),
        border: Border.all(color: const Color(0x88B39DDB), width: 1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: ValueListenableBuilder<int>(
        valueListenable: game.livesNotifier,
        builder: (context, lives, _) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '생명력  ',
                style: TextStyle(
                  color: Color(0xFFB39DDB),
                  fontSize: 12,
                  letterSpacing: 1.5,
                ),
              ),
              ...List.generate(3, (i) {
                final filled = i < lives;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Icon(
                    filled ? Icons.favorite : Icons.favorite_border,
                    color: filled
                        ? const Color(0xFFFF4D6D)
                        : const Color(0x664D3060),
                    size: 22,
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}

class _ItemHud extends StatelessWidget {
  final ActiveItem item;
  final int remaining;

  const _ItemHud({required this.item, required this.remaining});

  static const _itemData = {
    ActiveItem.piercingBall: (symbol: '◈', name: '마법 관통석', color: Color(0xFF4FC3F7)),
    ActiveItem.splitBall:    (symbol: '✦', name: '마법 분열구', color: Color(0xFFFFD54F)),
    ActiveItem.cannon:       (symbol: '⚡', name: '마법 화염포', color: Color(0xFFEF5350)),
    ActiveItem.none:         (symbol: '',  name: '',           color: Colors.white),
  };

  @override
  Widget build(BuildContext context) {
    final data = _itemData[item]!;
    final ratio = remaining / ItemSystem.maxHits;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xCC0D0620),
        border: Border.all(
          color: data.color.withValues(alpha: 0.6),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            data.symbol,
            style: TextStyle(color: data.color, fontSize: 14),
          ),
          const SizedBox(width: 6),
          Text(
            data.name,
            style: TextStyle(
              color: data.color,
              fontSize: 12,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 72,
            height: 6,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: ratio,
                backgroundColor: Colors.white12,
                valueColor: AlwaysStoppedAnimation<Color>(data.color),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '×$remaining',
            style: const TextStyle(color: Color(0xFFB39DDB), fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _ToastBanner extends StatelessWidget {
  final String message;

  const _ToastBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8, left: 32, right: 32),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xEE1A0A3D),
        border: Border.all(color: const Color(0x99FFD700), width: 1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: Color(0xFFE0D0FF),
          fontSize: 13,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
