# docs/references/README.md

## 개요
에이전트가 작업 시 참조하는 외부 레퍼런스 문서 모음입니다.
llms.txt 형식으로 저장하며, 에이전트가 컨텍스트로 로드해 사용합니다.

## 파일별 역할

| 파일 | 내용 | 채우는 시점 |
|------|------|------------|
| `flame-llms.txt` | Flame 1.x 핵심 API (Component, CollisionDetection, SpriteAnimation 등) | Phase 0 셋업 시 |
| `flutter-llms.txt` | riverpod, hive, shared_preferences 핵심 사용법 | Phase 0 셋업 시 |
| `admob-llms.txt` | google_mobile_ads 연동 코드 패턴 | Phase 3 광고 연동 전 |
| `design-system-reference-llms.txt` | DESIGN.md 컬러/타이포/컴포넌트 요약 | Phase 2 UI 작업 전 |

## 채우는 방법
각 파일은 Phase 진입 시 에이전트가 공식 문서를 참고해
핵심 내용만 압축해서 자동 작성합니다.
직접 편집하거나 공식 llms.txt가 있으면 그걸 가져다 써도 됩니다.

## 참고 공식 문서 URL
- Flame: https://docs.flame-engine.org/latest/
- Flutter Riverpod: https://riverpod.dev/docs/introduction/getting_started
- Hive: https://docs.hivedb.dev/
- Google Mobile Ads (AdMob): https://developers.google.com/admob/flutter/quick-start
