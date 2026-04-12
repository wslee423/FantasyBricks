# CLAUDE.md — Claude Code 에이전트 가이드

## 이 프로젝트
Flutter + Flame 기반 Android 캐주얼 게임 (벽돌깨기 + 아이템 + 가챠).
백엔드 없음. 로컬 저장소만 사용.

---

## 작업 전 반드시 읽는 문서

| 문서 | 언제 읽나 |
|------|----------|
| `CONSTITUTION.md` | **항상** — 최상위 원칙, 모든 문서보다 우선 |
| `docs/design-docs/core-beliefs.md` | **항상** — 모든 의사결정의 기준 |
| `ARCHITECTURE.md` | 코드 생성 / 구조 변경 전 |
| `docs/product-specs/index.md` | 기능 구현 전 |
| `AGENTS.md` | 역할 및 협업 흐름 확인 시 |

---

## 절대 하지 않는 것 (사람 승인 없이)

불변 원칙은 `CONSTITUTION.md` 5조를 따른다. 운영 수준의 금지 항목:

- `pubspec.yaml` 변경 — 외부 패키지 신규 추가 금지
- 스테이지 클리어가 불가능한 JSON 생성

---

## 작업 완료 기준

전체 기준은 `docs/QUALITY_SCORE.md`를 따른다. 작업 후 최소 실행:

```bash
flutter analyze        # 경고 0개
flutter test           # 전체 통과
```

스테이지 JSON은 `/run-qa` 명령어로 자동 검증한다.

---

## 현재 개발 단계

**Phase 0 — 프로젝트 셋업 전**
Flutter 프로젝트 미생성. `PLANS.md` 참고.

단계별 진입 전 해당 Phase 목표와 체크리스트를 먼저 확인한다.

---

## 코드 규칙 (핵심만)

| 대상 | 규칙 |
|------|------|
| 클래스 | `PascalCase` |
| 변수/함수 | `camelCase` |
| 파일 | `snake_case.dart` |
| 단일 파일 | 300줄 이하 |
| 단일 함수 | 50줄 이하 |
| 인게임 텍스트 | 한국어만, 판타지 용어 사용 |

전체 기준 → `docs/QUALITY_SCORE.md`

---

## 문서 업데이트 규칙

| 트리거 | 업데이트 대상 |
|--------|-------------|
| 새 기능 구현 완료 | 관련 `docs/product-specs/*.md` |
| 버그 수정 완료 | `docs/exec-plans/tech-debt-tracker.md` |
| 미결 항목 결정됨 | 해당 문서 체크박스 처리 |
