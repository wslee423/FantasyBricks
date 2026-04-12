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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ValueListenableBuilder<int>(
                  valueListenable: game.livesNotifier,
                  builder: (context, lives, _) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(3, (i) {
                        final filled = i < lives;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(
                            filled ? Icons.favorite : Icons.favorite_border,
                            color: filled
                                ? const Color(0xFFFF4D6D)
                                : const Color(0xFF8B7FA8),
                            size: 28,
                          ),
                        );
                      }),
                    );
                  },
                ),
              ],
            ),
          ),
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
        ],
      ),
    );
  }
}

class _ItemHud extends StatelessWidget {
  final ActiveItem item;
  final int remaining;

  const _ItemHud({required this.item, required this.remaining});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (item) {
      ActiveItem.piercingBall => ('🔵 마법 관통석', const Color(0xFF4FC3F7)),
      ActiveItem.splitBall => ('🟡 마법 분열구', const Color(0xFFFFD54F)),
      ActiveItem.cannon => ('🔴 마법 화염포', const Color(0xFFEF5350)),
      ActiveItem.none => ('', Colors.white),
    };

    final ratio = remaining / ItemSystem.maxHits;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(color: color, fontSize: 13),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            height: 8,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: ratio,
                backgroundColor: Colors.white24,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '$remaining회',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
