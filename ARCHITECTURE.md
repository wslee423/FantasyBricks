# Architecture

## 개요
Flutter + Flame 기반의 Android 우선 2D 캐주얼 게임입니다.
백엔드 서버 없이 로컬 저장소만 사용하며,
GitHub Actions + fastlane으로 빌드 및 배포를 자동화합니다.

---

## 기술 스택

| 영역 | 기술 | 이유 |
|------|------|------|
| 언어 | Dart | Flutter 기본 언어, AI 코드 생성 레퍼런스 풍부 |
| 게임 엔진 | Flame 1.x | Flutter 위의 2D 게임 엔진, 캐주얼 게임 최적화 |
| UI 프레임워크 | Flutter | 게임 UI (HUD, 가챠, 로비) 처리 |
| 로컬 저장소 | shared_preferences + Hive | 스테이지 진행도, 보유 스킨, 코인 저장 |
| 애니메이션 | Flame SpriteAnimation | 벽돌 파괴, 아이템 이펙트 |
| 오디오 | flame_audio | 효과음, BGM |
| 상태 관리 | flutter_riverpod | 전역 상태 (코인, 스킨, 진행도) 관리 |
| 빌드 자동화 | GitHub Actions | PR 시 자동 빌드/테스트 |
| 배포 자동화 | fastlane | Google Play 내부 테스트 → 출시 자동화 |

---

## 프로젝트 구조

```
lib/
├── main.dart
├── game/                  # Flame 게임 핵심 로직
│   ├── brick_breaker_game.dart   # 메인 게임 루프
│   ├── components/
│   │   ├── ball.dart             # 볼 컴포넌트
│   │   ├── paddle.dart           # 패들 컴포넌트
│   │   ├── brick.dart            # 벽돌 컴포넌트
│   │   └── item_drop.dart        # 아이템 낙하 컴포넌트
│   ├── systems/
│   │   ├── item_system.dart      # 아이템 효과 관리
│   │   ├── collision_system.dart # 충돌 처리
│   │   └── stage_loader.dart     # 스테이지 데이터 로드
│   └── data/
│       └── stages/               # 스테이지 JSON 파일들
│           ├── stage_001.json
│           └── ...
├── ui/                    # Flutter UI (게임 외부 화면)
│   ├── lobby/             # 로비 화면
│   ├── gacha/             # 가챠 화면
│   ├── collection/        # 컬렉션 화면
│   └── tutorial/          # 튜토리얼 오버레이
├── data/                  # 로컬 저장소 관리
│   ├── local_storage.dart
│   └── models/
│       ├── player_progress.dart
│       └── skin_collection.dart
└── utils/
    ├── constants.dart
    └── audio_manager.dart
```

---

## 데이터 저장 구조 (로컬)

백엔드 없이 기기 로컬에만 저장합니다.

| 데이터 | 저장소 | 형식 |
|--------|--------|------|
| 스테이지 클리어 현황 | Hive | Map<int, int> (스테이지 → 별점) |
| 보유 스킨 목록 | Hive | List<String> (스킨 ID) |
| 장착 중인 스킨 | shared_preferences | String |
| 보유 마법 코인 | shared_preferences | int |
| 튜토리얼 완료 여부 | shared_preferences | bool |

---

## 스테이지 데이터 형식 (JSON)

스테이지는 JSON으로 정의하여 에이전트가 생성/수정하기 용이하게 합니다.

```json
{
  "stage_id": 1,
  "theme": "forest",
  "grid_cols": 7,
  "grid_rows": 10,
  "bricks": [
    { "col": 0, "row": 0, "hp": 1, "item_drop": null },
    { "col": 1, "row": 0, "hp": 2, "item_drop": "piercing_ball" },
    { "col": 2, "row": 0, "hp": 1, "item_drop": null }
  ]
}
```

---

## CI/CD 파이프라인

### GitHub Actions (빌드/테스트)
- **트리거**: PR 생성 시, main 브랜치 push 시
- **작업**:
  1. Flutter 패키지 설치 (`flutter pub get`)
  2. 정적 분석 (`flutter analyze`)
  3. 단위 테스트 (`flutter test`)
  4. APK 빌드 (`flutter build apk`)

### fastlane (배포)
- **트리거**: main 브랜치 태그 push 시 (`v*`)
- **작업**:
  1. APK 서명
  2. Google Play 내부 테스트 트랙 자동 업로드
  3. 슬랙/이메일 배포 완료 알림

---

## 확장 고려사항

| 항목 | 현재 | 추후 확장 시 |
|------|------|-------------|
| 플랫폼 | Android | iOS 추가 (Flutter 멀티플랫폼) |
| 저장소 | 로컬 | Firebase Firestore (클라우드 동기화) |
| 랭킹 | 없음 | Firebase + 리더보드 추가 |
| 광고 | 미정 | google_mobile_ads 패키지 연동 |

---

## 미결 의사결정

- [ ] Flame 버전 고정 (1.x 최신 마이너 버전 확인 필요)
- [ ] 광고 SDK 선택 — AdMob vs Unity Ads (백엔드 없는 구조에서 AdMob 유력)
- [ ] 스테이지 JSON 에셋 번들 방식 — assets 폴더 내 정적 파일 vs 코드 내 하드코딩
- [ ] 앱 아이콘 / 스플래시 스크린 에셋 준비 시점
