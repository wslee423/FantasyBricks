import 'package:flutter/material.dart';
import '../../data/gacha_data.dart';
import '../../data/gacha_service.dart';
import '../../data/local_storage.dart';

class CollectionScreen extends StatefulWidget {
  const CollectionScreen({super.key});

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  List<String> _owned = [];
  String _equipped = '';
  int _fragments = 0;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _owned = LocalStorage.getOwnedSkins();
      _equipped = LocalStorage.getEquippedSkin();
      _fragments = LocalStorage.getFragments();
    });
  }

  Future<void> _equip(String skinId) async {
    await LocalStorage.setEquippedSkin(skinId);
    _refresh();
  }

  Future<void> _exchange(String skinId) async {
    final success = await GachaService.exchange(skinId);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('교환 완료! 새 볼 스킨을 획득했습니다.'),
          backgroundColor: Color(0xFF2A6020),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '파편 ${GachaService.fragmentsForExchange}개 필요 (현재 $_fragments개)',
          ),
          backgroundColor: const Color(0xFF4A1080),
        ),
      );
    }
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A0A3D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0620),
        foregroundColor: Colors.white,
        title: const Text('볼 스킨 컬렉션'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                const Icon(Icons.broken_image, color: Color(0xFFB39DDB), size: 18),
                const SizedBox(width: 4),
                Text(
                  '파편 $_fragments',
                  style: const TextStyle(color: Color(0xFFB39DDB), fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.85,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: GachaData.skins.length,
        itemBuilder: (context, index) {
          final skin = GachaData.skins[index];
          final isOwned = _owned.contains(skin.id);
          final isEquipped = _equipped == skin.id;
          return _SkinTile(
            skin: skin,
            isOwned: isOwned,
            isEquipped: isEquipped,
            fragments: _fragments,
            onEquip: isOwned && !isEquipped ? () => _equip(skin.id) : null,
            onExchange: !isOwned ? () => _exchange(skin.id) : null,
          );
        },
      ),
    );
  }
}

class _SkinTile extends StatelessWidget {
  final BallSkin skin;
  final bool isOwned;
  final bool isEquipped;
  final int fragments;
  final VoidCallback? onEquip;
  final VoidCallback? onExchange;

  const _SkinTile({
    required this.skin,
    required this.isOwned,
    required this.isEquipped,
    required this.fragments,
    this.onEquip,
    this.onExchange,
  });

  @override
  Widget build(BuildContext context) {
    final gradeColor = GachaData.gradeColors[skin.grade]!;
    final canExchange = fragments >= GachaService.fragmentsForExchange;

    return GestureDetector(
      onTap: onEquip ?? (isOwned ? null : (canExchange ? onExchange : null)),
      onLongPress: !isOwned && canExchange ? onExchange : null,
      child: Container(
        decoration: BoxDecoration(
          color: isEquipped
              ? const Color(0xFF3A1070)
              : isOwned
                  ? const Color(0xFF2A1050)
                  : const Color(0xFF0D0620),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isEquipped ? const Color(0xFFFFD700) : gradeColor,
            width: isEquipped ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isOwned)
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: skin.color,
                  boxShadow: [
                    BoxShadow(
                      color: skin.color.withValues(alpha: 0.5),
                      blurRadius: 10,
                    ),
                  ],
                ),
              )
            else
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white12,
                    ),
                  ),
                  const Icon(Icons.help_outline, color: Colors.white24, size: 24),
                ],
              ),
            const SizedBox(height: 6),
            Text(
              isOwned ? skin.name : '???',
              style: TextStyle(
                color: isOwned ? const Color(0xFFE0D0FF) : Colors.white24,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            if (isEquipped)
              const Text(
                '장착 중',
                style: TextStyle(
                  color: Color(0xFFFFD700),
                  fontSize: 10,
                ),
              )
            else if (!isOwned)
              Text(
                canExchange ? '교환 가능' : '파편 30개',
                style: TextStyle(
                  color: canExchange
                      ? const Color(0xFF44FF88)
                      : Colors.white24,
                  fontSize: 10,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
