# /run-qa — QA 체크 실행

QA Agent로서 아래 순서대로 프로젝트 품질을 검증한다.
모든 단계를 순서대로 실행하고, 결과를 마지막에 요약 보고한다.

---

## 실행 순서

### 1. 정적 분석
```bash
flutter analyze
```
- 경고 0개 기준. 경고 발생 시 즉시 수정 후 재실행.

### 2. 테스트 실행
```bash
flutter test
```
- 전체 통과 기준. 실패한 테스트는 원인을 파악하고 수정한다.

### 3. 스테이지 JSON 검증
`lib/game/data/stages/` 아래 모든 `stage_*.json` 파일에 대해 아래 항목을 확인한다.

| 항목 | 기준 |
|------|------|
| `grid_cols` | 7 고정 |
| `grid_rows` | 10 고정 |
| 전체 벽돌 수 | 20개 이상 70개 이하 |
| HP 범위 | 구간별 기준 (`docs/product-specs/stage-system.md` 참고) |
| 아이템 드롭 비율 | 구간별 기준 ±5% 이내 |
| JSON 스키마 유효성 | `stage_id`, `theme`, `grid_cols`, `grid_rows`, `bricks` 필드 존재 |

### 4. 발견된 문제 처리
- 즉시 수정 가능한 것: 수정 후 해당 단계 재실행
- 지금 수정 불가한 것: `docs/exec-plans/tech-debt-tracker.md`에 항목 추가

---

## 완료 보고 형식

```
## QA 결과 요약

### flutter analyze
- 상태: ✅ 통과 / ❌ 실패
- 발견된 경고: N개

### flutter test
- 상태: ✅ 통과 / ❌ 실패
- 실패 테스트: (있을 경우 목록)

### 스테이지 JSON 검증
- 검증한 파일: N개
- 상태: ✅ 전체 통과 / ❌ N개 실패
- 실패 항목: (있을 경우 파일명 + 사유)

### 신규 tech debt 등록
- (있을 경우 목록, 없으면 "없음")
```
