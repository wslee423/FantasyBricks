# Open Decisions — 미결 의사결정 중앙 집계

각 문서에 흩어진 미결 항목을 한곳에서 관리한다.
결정이 완료되면 상태를 업데이트하고 원본 문서 체크박스도 함께 처리한다.
이 문서는 `/sync-docs` 실행 시 자동으로 업데이트된다.

---

## 우선순위 기준

| 레벨 | 기준 |
|------|------|
| 🔴 Blocker | 이 결정 없이 다음 Phase로 진행 불가 |
| 🟠 High | 현재 Phase 내 결정 필요 |
| 🟡 Medium | 다음 Phase 전까지 결정하면 됨 |
| 🟢 Low | 여유 있을 때 결정 |

---

## 미결 항목 목록

### Phase 0 Blocker 🔴

| ID | 항목 | 출처 | 비고 |
|----|------|------|------|
| OD-001 | 게임 타이틀/앱 이름 결정 | PLANS.md, DESIGN.md | 스토어 등록 전 필수 |
| OD-002 | Google Play 개발자 계정 등록 여부 확인 | PLANS.md | $25 1회 결제 |

---

### 게임 시스템 🟠

| ID | 항목 | 출처 | 비고 |
|----|------|------|------|
| OD-003 | 스테이지 간 라이프 유지 vs 매 스테이지 3개 리셋 | stage-system.md | 난이도 전체에 영향 |
| OD-004 | 아이템 드롭 벽돌 출현 비율 확정 | brick-system.md | stage-system.md 기준 참고 |
| OD-005 | 마법 분열구 분열 각도 (고정 vs 랜덤) | item-system.md | |
| OD-006 | 마법 화염포 자동발사 간격 (0.5초 고정 vs 패들 이동속도 연동) | item-system.md | |
| OD-007 | 20회 타격 수치 밸런싱 | item-system.md | 스테이지 테스트 후 조정 |
| OD-008 | 아이템 낙하 속도 정의 | brick-system.md, item-system.md | |

---

### UI/UX 🟠

| ID | 항목 | 출처 | 비고 |
|----|------|------|------|
| OD-009 | 스테이지 선택 UI — 그리드 vs 가로 스크롤 맵 형식 | FRONTEND.md, stage-system.md | |
| OD-010 | 마법 화염포 튜토리얼 — Step 2 포함 vs 첫 획득 시 팝업 | new-user-onboarding.md | |
| OD-011 | 튜토리얼 캐릭터/마스코트 존재 여부 | new-user-onboarding.md, DESIGN.md | |

---

### 기술/인프라 🟡

| ID | 항목 | 출처 | 비고 |
|----|------|------|------|
| OD-012 | Firebase Crashlytics 도입 여부 | QUALITY_SCORE.md, RELIABILITY.md, SECURITY.md | 도입 시 개인정보처리방침 업데이트 필요 |
| OD-013 | 체크섬 알고리즘 (SHA-256 vs CRC32) | SECURITY.md | |
| OD-014 | 스테이지 JSON 에셋 번들 방식 — assets 폴더 vs 코드 내 하드코딩 | ARCHITECTURE.md | |
| OD-015 | Flame 버전 고정 (1.x 최신 마이너 버전 확인) | ARCHITECTURE.md | |
| OD-016 | 광고 SDK 선택 — AdMob vs Unity Ads | ARCHITECTURE.md | |

---

### 디자인/콘텐츠 🟢

| ID | 항목 | 출처 | 비고 |
|----|------|------|------|
| OD-017 | 배경 디테일 — 단순 그라데이션 vs 파티클 배경 애니메이션 | DESIGN.md | |
| OD-018 | 스테이지 클리어 연출 수준 — 간단한 팝업 vs 풀스크린 연출 | DESIGN.md | |
| OD-019 | 가챠 연출 스타일 — 카드 플립 vs 마법진 소환 풀 애니메이션 | FRONTEND.md, gacha-system.md | |
| OD-020 | 10스테이지 클리어 후 무한모드 추가 여부 | product-specs/index.md, stage-system.md | |
| OD-021 | 전설 등급 천장 시스템 추가 여부 | gacha-system.md | |
| OD-022 | HP5 벽돌 등장 스테이지 제한 여부 | brick-system.md | |
| OD-023 | 볼 끼임 감지 프레임 수 (현재 5프레임) | RELIABILITY.md | |

---

## 완료 항목

| ID | 항목 | 결정 내용 | 완료 시점 |
|----|------|----------|----------|
| - | - | - | - |
