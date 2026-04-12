"""
PostToolUse 훅 — 스테이지 JSON 자동 검증

stage_*.json 파일이 Write될 때마다 구조와 값을 즉시 검증한다.
실패해도 Write 자체는 이미 완료된 상태 (PostToolUse이므로).
에러 출력으로 에이전트가 즉시 수정하도록 유도한다.
"""
import sys
import json
import re

# 구간별 HP 범위 (stage-system.md 기준)
STAGE_HP_RULES = {
    range(1, 4):  (1, 2),   # 입문: 1~3스테이지
    range(4, 8):  (2, 4),   # 중반: 4~7스테이지
    range(8, 11): (3, 5),   # 후반: 8~10스테이지
}

# 구간별 아이템 드롭 비율 기준 (±5% 허용)
STAGE_DROP_RULES = {
    range(1, 4):  0.30,
    range(4, 8):  0.20,
    range(8, 11): 0.10,
}

def get_rule(stage_id, rules):
    for r, val in rules.items():
        if stage_id in r:
            return val
    return None


try:
    data = json.load(sys.stdin)
    file_path = data.get("tool_input", {}).get("file_path", "")

    # stage_*.json 파일만 처리
    if not re.search(r"stage_\d+\.json$", file_path):
        sys.exit(0)

    content = data.get("tool_input", {}).get("content", "")
    stage = json.loads(content)
    errors = []

    # 1. 필수 필드 확인
    for field in ["stage_id", "theme", "grid_cols", "grid_rows", "bricks"]:
        if field not in stage:
            errors.append(f"필수 필드 누락: '{field}'")

    # 2. 그리드 고정값 확인
    if stage.get("grid_cols") != 7:
        errors.append(f"grid_cols는 7이어야 함 (현재: {stage.get('grid_cols')})")
    if stage.get("grid_rows") != 10:
        errors.append(f"grid_rows는 10이어야 함 (현재: {stage.get('grid_rows')})")

    bricks = stage.get("bricks", [])
    brick_count = len(bricks)
    stage_id = stage.get("stage_id", 0)

    # 3. 벽돌 수 범위
    if brick_count < 20:
        errors.append(f"벽돌 수 부족: {brick_count}개 (최소 20개)")
    elif brick_count > 70:
        errors.append(f"벽돌 수 초과: {brick_count}개 (최대 70개)")

    # 4. HP 범위 확인
    hp_rule = get_rule(stage_id, STAGE_HP_RULES)
    if hp_rule:
        hp_min, hp_max = hp_rule
        for b in bricks:
            hp = b.get("hp", 0)
            if not (hp_min <= hp <= hp_max):
                errors.append(
                    f"HP 범위 오류 (col={b.get('col')}, row={b.get('row')}): "
                    f"hp={hp}, 허용범위={hp_min}~{hp_max}"
                )

    # 5. 아이템 드롭 비율 확인
    drop_rule = get_rule(stage_id, STAGE_DROP_RULES)
    if drop_rule and brick_count > 0:
        drop_count = sum(1 for b in bricks if b.get("item_drop") is not None)
        actual_rate = drop_count / brick_count
        if abs(actual_rate - drop_rule) > 0.05:
            errors.append(
                f"아이템 드롭 비율 오류: {actual_rate:.0%} "
                f"(기준: {drop_rule:.0%} ±5%)"
            )

    # 결과 출력
    if errors:
        print(f"\n❌ {file_path} 검증 실패 ({len(errors)}개 오류):")
        for e in errors:
            print(f"   - {e}")
        print("→ 위 항목을 수정한 후 다시 저장하세요.\n")
        sys.exit(1)
    else:
        print(f"✅ {file_path} 검증 통과 (stage {stage_id}, 벽돌 {brick_count}개)")

except json.JSONDecodeError as e:
    print(f"❌ JSON 파싱 오류: {e}")
    sys.exit(1)
except Exception:
    pass  # 예상치 못한 오류는 무시하고 진행

sys.exit(0)
