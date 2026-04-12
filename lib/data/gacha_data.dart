import 'package:flutter/material.dart';

enum SkinGrade { common, rare, legendary }

class BallSkin {
  final String id;
  final String name;
  final SkinGrade grade;
  final Color color;

  const BallSkin({
    required this.id,
    required this.name,
    required this.grade,
    required this.color,
  });
}

class GachaData {
  static const List<BallSkin> skins = [
    // 일반 (70%)
    BallSkin(id: 'fire_red',      name: '불꽃 빨강', grade: SkinGrade.common,    color: Color(0xFFFF4444)),
    BallSkin(id: 'ice_blue',      name: '얼음 파랑', grade: SkinGrade.common,    color: Color(0xFF4488FF)),
    BallSkin(id: 'forest_green',  name: '숲 초록',   grade: SkinGrade.common,    color: Color(0xFF44BB44)),
    BallSkin(id: 'sunset_orange', name: '노을 주황', grade: SkinGrade.common,    color: Color(0xFFFF8844)),
    BallSkin(id: 'storm_purple',  name: '폭풍 보라', grade: SkinGrade.common,    color: Color(0xFF9944CC)),
    BallSkin(id: 'sand_yellow',   name: '모래 노랑', grade: SkinGrade.common,    color: Color(0xFFEECC44)),
    BallSkin(id: 'ash_white',     name: '재 흰색',   grade: SkinGrade.common,    color: Color(0xFFCCCCCC)),
    // 희귀 (25%)
    BallSkin(id: 'flame_ball',    name: '불꽃 볼',   grade: SkinGrade.rare,      color: Color(0xFFFF6600)),
    BallSkin(id: 'ice_ball',      name: '얼음 볼',   grade: SkinGrade.rare,      color: Color(0xFF00CCFF)),
    BallSkin(id: 'thunder_ball',  name: '번개 볼',   grade: SkinGrade.rare,      color: Color(0xFFFFFF00)),
    BallSkin(id: 'void_ball',     name: '허공 볼',   grade: SkinGrade.rare,      color: Color(0xFF7733AA)),
    BallSkin(id: 'crystal_ball',  name: '수정 볼',   grade: SkinGrade.rare,      color: Color(0xFFAAFFFF)),
    // 전설 (5%)
    BallSkin(id: 'demon_eye',     name: '마왕의 눈', grade: SkinGrade.legendary, color: Color(0xFFFF0044)),
    BallSkin(id: 'shooting_star', name: '별똥별',    grade: SkinGrade.legendary, color: Color(0xFFFFFFAA)),
    BallSkin(id: 'magic_circle',  name: '마법진 볼', grade: SkinGrade.legendary, color: Color(0xFF8800FF)),
  ];

  static const double commonWeight    = 0.70;
  static const double rareWeight      = 0.25;
  static const double legendaryWeight = 0.05;

  static const String defaultSkinId = 'fire_red';

  static const Map<SkinGrade, String> gradeNames = {
    SkinGrade.common:    '일반',
    SkinGrade.rare:      '희귀',
    SkinGrade.legendary: '전설',
  };

  static const Map<SkinGrade, Color> gradeColors = {
    SkinGrade.common:    Color(0xFFAAAAAA),
    SkinGrade.rare:      Color(0xFF4488FF),
    SkinGrade.legendary: Color(0xFFFFD700),
  };

  static BallSkin? findById(String id) {
    try {
      return skins.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }
}
