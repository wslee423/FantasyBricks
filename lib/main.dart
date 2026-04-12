import 'package:flutter/material.dart';
import 'data/local_storage.dart';
import 'ui/lobby/lobby_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorage.init();
  runApp(const FantasyBricksApp());
}

class FantasyBricksApp extends StatelessWidget {
  const FantasyBricksApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fantasy Bricks',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const LobbyScreen(),
    );
  }
}
