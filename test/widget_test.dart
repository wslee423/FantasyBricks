import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fantasy_bricks/main.dart';

void main() {
  testWidgets('앱이 정상적으로 실행된다', (WidgetTester tester) async {
    await tester.pumpWidget(const FantasyBricksApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
