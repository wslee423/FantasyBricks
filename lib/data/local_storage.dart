import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const _keyCoins = 'coins';
  static const _keyCurrentStage = 'current_stage';
  static const _keyTutorialDone = 'tutorial_done';
  static const _keyStagePrefix = 'stage_stars_';
  static const _keyEquippedSkin = 'equipped_skin';
  static const _keyOwnedSkins = 'owned_skins';
  static const _keyFragments = 'fragments';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences get _p {
    assert(_prefs != null, 'LocalStorage.init()을 먼저 호출하세요');
    return _prefs!;
  }

  // 코인
  static int getCoins() => _p.getInt(_keyCoins) ?? 0;
  static Future<void> addCoins(int amount) =>
      _p.setInt(_keyCoins, getCoins() + amount);
  static Future<void> spendCoins(int amount) =>
      _p.setInt(_keyCoins, (getCoins() - amount).clamp(0, 99999));

  // 현재 스테이지 (잠금 해제된 최대 스테이지)
  static int getCurrentStage() => _p.getInt(_keyCurrentStage) ?? 1;
  static Future<void> unlockStage(int stageId) async {
    if (stageId > getCurrentStage()) {
      await _p.setInt(_keyCurrentStage, stageId);
    }
  }

  // 스테이지 별점 (1~3, 0 = 미클리어)
  static int getStageStars(int stageId) =>
      _p.getInt('$_keyStagePrefix$stageId') ?? 0;
  static Future<void> saveStageResult(int stageId, int stars) async {
    final prev = getStageStars(stageId);
    if (stars > prev) {
      await _p.setInt('$_keyStagePrefix$stageId', stars);
    }
    // 클리어 시 코인 지급: 최초 클리어 +15, 재도전 +10
    final isFirstClear = prev == 0;
    await addCoins(isFirstClear ? 15 : 10);
    await unlockStage(stageId + 1);
  }

  // 튜토리얼 완료 여부
  static bool isTutorialDone() => _p.getBool(_keyTutorialDone) ?? false;
  static Future<void> setTutorialDone() => _p.setBool(_keyTutorialDone, true);

  // 장착 볼 스킨 (기본값 '' = 스킨 없음 → 흰색 볼)
  static String getEquippedSkin() => _p.getString(_keyEquippedSkin) ?? '';
  static Future<void> setEquippedSkin(String skinId) =>
      _p.setString(_keyEquippedSkin, skinId);

  // 보유 스킨 목록 (쉼표 구분 문자열)
  static List<String> getOwnedSkins() {
    final raw = _p.getString(_keyOwnedSkins) ?? 'fire_red';
    return raw.split(',').where((s) => s.isNotEmpty).toList();
  }

  static Future<void> addOwnedSkin(String skinId) async {
    final owned = getOwnedSkins();
    if (!owned.contains(skinId)) {
      owned.add(skinId);
      await _p.setString(_keyOwnedSkins, owned.join(','));
    }
  }

  // 파편
  static int getFragments() => _p.getInt(_keyFragments) ?? 0;
  static Future<void> addFragments(int count) =>
      _p.setInt(_keyFragments, getFragments() + count);
  static Future<void> spendFragments(int count) =>
      _p.setInt(_keyFragments, (getFragments() - count).clamp(0, 99999));
}
