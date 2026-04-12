# RELIABILITY.md — 안정성 기준

## 개요
게임이 크래시 없이 안정적으로 작동하기 위한
기준과 대응 방법을 정의합니다.

---

## 1. 안정성 목표

| 항목 | 목표 |
|------|------|
| 크래시율 | 0.1% 이하 (세션 기준) |
| ANR 발생률 | 0.01% 이하 |
| 스테이지 로드 실패율 | 0% |
| 로컬 저장소 손실 | 0% |

---

## 2. 예외 처리 기준

### 필수 try-catch 적용 대상
```dart
// 로컬 저장소 읽기/쓰기
try {
  final progress = await localStore.loadProgress();
} catch (e) {
  // 저장 데이터 손상 시 초기값으로 복구
  await localStore.resetToDefault();
}

// 스테이지 JSON 로드
try {
  final stage = await stageLoader.load(stageId);
} catch (e) {
  // 로드 실패 시 로비로 이동 + 에러 로그
  router.go('/lobby');
  logger.error('Stage load failed: $stageId');
}

// 광고 로드
try {
  await adManager.loadRewardedAd();
} catch (e) {
  // 광고 실패 시 조용히 무시 (게임 진행에 영향 없음)
  logger.warn('Ad load failed');
}
```

### 에러 등급 정의
| 등급 | 설명 | 대응 |
|------|------|------|
| Critical | 앱 크래시, 저장 데이터 손실 | 즉시 수정 |
| High | 스테이지 로드 실패, 아이템 미작동 | 다음 빌드 내 수정 |
| Medium | 광고 미노출, 애니메이션 끊김 | 1주 내 수정 |
| Low | UI 정렬 틀어짐, 텍스트 잘림 | 여유 있을 때 수정 |

---

## 3. 데이터 안정성

### 로컬 저장소 보호
- 저장 전 유효성 검증 후 쓰기
- 저장 실패 시 이전 데이터 유지 (덮어쓰기 방지)
- 앱 업데이트 시 기존 저장 데이터 마이그레이션 필수

### 저장 데이터 복구 시나리오
| 상황 | 대응 |
|------|------|
| 저장 파일 손상 | 초기값으로 리셋 + 사용자 알림 |
| 앱 강제 종료 중 저장 | 다음 실행 시 마지막 정상 저장 상태로 복구 |
| 스테이지 진행 중 종료 | 해당 스테이지 처음부터 재시작 |

---

## 4. 게임 루프 안정성

### Flame 게임 루프 보호
```dart
// 볼 속도 이상값 방지
const double MAX_BALL_SPEED = 800.0;
const double MIN_BALL_SPEED = 200.0;

void clampBallSpeed() {
  velocity = velocity.clampLength(MIN_BALL_SPEED, MAX_BALL_SPEED);
}
```

### 엣지 케이스 대응
| 케이스 | 대응 |
|--------|------|
| 볼이 벽에 끼는 현상 | 5프레임 이상 같은 위치 감지 시 볼 리셋 |
| 볼 속도 무한 증가 | MAX_BALL_SPEED 클램프 적용 |
| 마법 분열구 중 볼 0개 | 즉시 라이프 -1, 볼 1개 패들 위 재생성 |
| 스테이지 벽돌 0개 감지 | 클리어 판정 즉시 트리거 |
| 아이템 낙하 중 스테이지 클리어 | 낙하 아이템 즉시 소멸 처리 |
| 볼 재생성 후 즉시 이탈 | 최소 1초 후부터 이탈 판정 적용 |

---

## 5. 모니터링

| 도구 | 용도 | 도입 시점 |
|------|------|----------|
| Flutter DevTools | 개발 중 성능/메모리 모니터링 | Phase 1부터 |
| Firebase Crashlytics | 출시 후 크래시 리포트 | Phase 4 (미결 — QUALITY_SCORE.md 참고) |
| 수동 QA 로그 | 스테이지별 클리어율 기록 | Phase 2부터 |

---

## 미결 의사결정

- [ ] 저장 데이터 리셋 시 사용자 알림 방식 (팝업 vs 토스트)
- [ ] 볼 끼임 감지 프레임 수 조정 (5프레임 적절한지 테스트 필요)
- [ ] Firebase Crashlytics 도입 여부 → QUALITY_SCORE.md에서 통합 관리
