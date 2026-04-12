import 'package:flutter/material.dart';

void main() {
  runApp(const FantasyBricksApp());
}

class FantasyBricksApp extends StatelessWidget {
  const FantasyBricksApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Fantasy Bricks',
      home: Scaffold(
        body: Center(
          child: Text('Fantasy Bricks — Phase 0'),
        ),
      ),
    );
  }
}
