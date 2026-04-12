import 'package:flutter/material.dart';
import '../../data/local_storage.dart';

const overlayTutorial = 'tutorial';

class TutorialOverlay extends StatefulWidget {
  final VoidCallback onDone;

  const TutorialOverlay({super.key, required this.onDone});

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay> {
  int _step = 0;

  static const _steps = [
    (
      icon: Icons.swipe,
      title: '패들 조작',
      desc: '화면을 좌우로 드래그해서\n패들을 움직이세요',
    ),
    (
      icon: Icons.touch_app,
      title: '볼 발사',
      desc: '볼이 패들 위에 있을 때\n화면을 탭하면 발사됩니다',
    ),
    (
      icon: Icons.auto_awesome,
      title: '마법 아이템',
      desc: '벽돌 파괴 시 아이템이 떨어집니다\n패들로 받아서 강력한 효과를 발동하세요',
    ),
  ];

  void _next() {
    if (_step < _steps.length - 1) {
      setState(() => _step++);
    } else {
      LocalStorage.setTutorialDone();
      widget.onDone();
    }
  }

  void _skip() {
    LocalStorage.setTutorialDone();
    widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_step];
    return Container(
      color: Colors.black87,
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Icon(step.icon, size: 72, color: const Color(0xFFB39DDB)),
            const SizedBox(height: 24),
            Text(
              step.title,
              style: const TextStyle(
                color: Color(0xFFFFD700),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              step.desc,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFE0D0FF),
                fontSize: 16,
                height: 1.6,
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_steps.length, (i) {
                return Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i == _step
                        ? const Color(0xFFB39DDB)
                        : Colors.white24,
                  ),
                );
              }),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _next,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7B2FBE),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 14),
                textStyle: const TextStyle(fontSize: 16),
              ),
              child: Text(_step < _steps.length - 1 ? '다음' : '시작하기'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _skip,
              child: const Text(
                '건너뛰기',
                style: TextStyle(color: Colors.white38, fontSize: 14),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
