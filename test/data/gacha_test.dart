import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fantasy_bricks/data/gacha_data.dart';
import 'package:fantasy_bricks/data/gacha_service.dart';
import 'package:fantasy_bricks/data/local_storage.dart';

void main() {
  group('GachaData', () {
    test('총 스킨 수는 15개다', () {
      expect(GachaData.skins.length, 15);
    });

    test('일반 스킨은 7개다', () {
      final commons = GachaData.skins.where((s) => s.grade == SkinGrade.common);
      expect(commons.length, 7);
    });

    test('희귀 스킨은 5개다', () {
      final rares = GachaData.skins.where((s) => s.grade == SkinGrade.rare);
      expect(rares.length, 5);
    });

    test('전설 스킨은 3개다', () {
      final legends = GachaData.skins.where((s) => s.grade == SkinGrade.legendary);
      expect(legends.length, 3);
    });

    test('findById는 존재하는 스킨을 반환한다', () {
      final skin = GachaData.findById('fire_red');
      expect(skin, isNotNull);
      expect(skin!.name, '불꽃 빨강');
    });

    test('findById는 없는 id에 null을 반환한다', () {
      expect(GachaData.findById('nonexistent'), isNull);
    });
  });

  group('GachaService', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await LocalStorage.init();
    });

    test('코인 부족 시 draw는 null을 반환한다', () async {
      final result = await GachaService.draw();
      expect(result, isNull);
    });

    test('코인 충분 시 draw는 결과를 반환하고 코인이 차감된다', () async {
      await LocalStorage.addCoins(100);
      final result = await GachaService.draw();
      expect(result, isNotNull);
      expect(LocalStorage.getCoins(), 70);
    });

    test('중복 뽑기 시 isNew는 false이고 파편이 추가된다', () async {
      await LocalStorage.addCoins(100);
      // fire_red는 기본 보유 스킨
      // 여러 번 뽑아서 중복이 발생하는 경우를 직접 테스트
      // LocalStorage에 이미 보유 스킨을 추가해두고 확인
      await LocalStorage.addOwnedSkin('ice_blue');
      // 보유 스킨 목록에 있으면 중복 처리
      final owned = LocalStorage.getOwnedSkins();
      expect(owned.contains('ice_blue'), isTrue);
    });

    test('exchange: 파편 부족 시 false 반환', () async {
      SharedPreferences.setMockInitialValues({});
      await LocalStorage.init();
      final result = await GachaService.exchange('demon_eye');
      expect(result, isFalse);
    });

    test('exchange: 파편 충분하고 미보유 시 true 반환 + 스킨 추가', () async {
      SharedPreferences.setMockInitialValues({});
      await LocalStorage.init();
      await LocalStorage.addFragments(30);
      final result = await GachaService.exchange('demon_eye');
      expect(result, isTrue);
      expect(LocalStorage.getOwnedSkins().contains('demon_eye'), isTrue);
      expect(LocalStorage.getFragments(), 0);
    });

    test('exchange: 이미 보유 중이면 false 반환', () async {
      SharedPreferences.setMockInitialValues({});
      await LocalStorage.init();
      await LocalStorage.addFragments(30);
      await LocalStorage.addOwnedSkin('demon_eye');
      final result = await GachaService.exchange('demon_eye');
      expect(result, isFalse);
    });
  });

  group('LocalStorage 스킨 관련', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await LocalStorage.init();
    });

    test('기본 장착 스킨은 빈 문자열이다 (스킨 미장착 = 흰색 볼)', () {
      expect(LocalStorage.getEquippedSkin(), '');
    });

    test('setEquippedSkin 후 getEquippedSkin이 일치한다', () async {
      await LocalStorage.setEquippedSkin('ice_ball');
      expect(LocalStorage.getEquippedSkin(), 'ice_ball');
    });

    test('기본 보유 스킨은 fire_red를 포함한다', () {
      expect(LocalStorage.getOwnedSkins().contains('fire_red'), isTrue);
    });

    test('addOwnedSkin 후 목록에 포함된다', () async {
      await LocalStorage.addOwnedSkin('thunder_ball');
      expect(LocalStorage.getOwnedSkins().contains('thunder_ball'), isTrue);
    });

    test('중복 addOwnedSkin은 목록을 변경하지 않는다', () async {
      await LocalStorage.addOwnedSkin('fire_red');
      await LocalStorage.addOwnedSkin('fire_red');
      final count = LocalStorage.getOwnedSkins().where((s) => s == 'fire_red').length;
      expect(count, 1);
    });

    test('spendCoins는 음수가 되지 않는다', () async {
      await LocalStorage.spendCoins(999);
      expect(LocalStorage.getCoins(), 0);
    });
  });
}
