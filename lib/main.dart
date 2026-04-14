import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'data/local_storage.dart';
import 'data/ad_service.dart';
import 'ui/lobby/lobby_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 세로 고정
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await LocalStorage.init();
  // AdMob 초기화는 앱 시작을 블로킹하지 않음 — native 크래시 격리
  AdService.init();
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
