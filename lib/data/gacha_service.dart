import 'dart:math' as math;
import 'gacha_data.dart';
import 'local_storage.dart';

class GachaResult {
  final BallSkin skin;
  final bool isNew;
  final int fragmentsAdded;

  const GachaResult({
    required this.skin,
    required this.isNew,
    this.fragmentsAdded = 0,
  });
}

class GachaService {
  static const int drawCost = 30;
  static const int fragmentsPerDuplicate = 3;
  static const int fragmentsForExchange = 30;

  static BallSkin _rollSkin() {
    final rand = math.Random();
    final roll = rand.nextDouble();

    final SkinGrade grade;
    if (roll < GachaData.legendaryWeight) {
      grade = SkinGrade.legendary;
    } else if (roll < GachaData.legendaryWeight + GachaData.rareWeight) {
      grade = SkinGrade.rare;
    } else {
      grade = SkinGrade.common;
    }

    final pool = GachaData.skins.where((s) => s.grade == grade).toList();
    return pool[rand.nextInt(pool.length)];
  }

  /// 뽑기 실행. 코인 부족 시 null 반환.
  static Future<GachaResult?> draw() async {
    if (LocalStorage.getCoins() < drawCost) return null;

    await LocalStorage.spendCoins(drawCost);
    final skin = _rollSkin();
    final owned = LocalStorage.getOwnedSkins();

    if (owned.contains(skin.id)) {
      await LocalStorage.addFragments(fragmentsPerDuplicate);
      return GachaResult(skin: skin, isNew: false, fragmentsAdded: fragmentsPerDuplicate);
    } else {
      await LocalStorage.addOwnedSkin(skin.id);
      return GachaResult(skin: skin, isNew: true);
    }
  }

  /// 파편 교환. 파편 부족하거나 이미 보유 시 false 반환.
  static Future<bool> exchange(String skinId) async {
    if (LocalStorage.getFragments() < fragmentsForExchange) return false;
    if (LocalStorage.getOwnedSkins().contains(skinId)) return false;

    await LocalStorage.spendFragments(fragmentsForExchange);
    await LocalStorage.addOwnedSkin(skinId);
    return true;
  }
}
