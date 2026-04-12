import 'dart:convert';
import 'package:flutter/services.dart';

class BrickData {
  final int col;
  final int row;
  final int hp;
  final String? itemDrop;

  const BrickData({
    required this.col,
    required this.row,
    required this.hp,
    this.itemDrop,
  });

  factory BrickData.fromJson(Map<String, dynamic> json) {
    return BrickData(
      col: json['col'] as int,
      row: json['row'] as int,
      hp: json['hp'] as int,
      itemDrop: json['item_drop'] as String?,
    );
  }
}

class StageData {
  final int stageId;
  final String theme;
  final int gridCols;
  final int gridRows;
  final List<BrickData> bricks;

  const StageData({
    required this.stageId,
    required this.theme,
    required this.gridCols,
    required this.gridRows,
    required this.bricks,
  });

  factory StageData.fromJson(Map<String, dynamic> json) {
    return StageData(
      stageId: json['stage_id'] as int,
      theme: json['theme'] as String,
      gridCols: json['grid_cols'] as int,
      gridRows: json['grid_rows'] as int,
      bricks: (json['bricks'] as List)
          .map((b) => BrickData.fromJson(b as Map<String, dynamic>))
          .toList(),
    );
  }
}

class StageLoader {
  static Future<StageData> load(int stageId) async {
    final id = stageId.toString().padLeft(3, '0');
    final path = 'lib/game/data/stages/stage_$id.json';
    final raw = await rootBundle.loadString(path);
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return StageData.fromJson(json);
  }
}
