import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const _keyCoins = 'coins';
  static const _keyCurrentStage = 'current_stage';
  static const _keyTutorialDone = 'tutorial_done';
  static const _keyStagePrefix = 'stage_stars_';

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
}
