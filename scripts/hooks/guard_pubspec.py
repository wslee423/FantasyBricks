"""
PreToolUse 훅 — pubspec.yaml 변경 차단

pubspec.yaml 수정 시도를 감지해 에이전트를 차단한다.
외부 패키지 신규 추가는 사람 승인 없이 불가 (CLAUDE.md 참고).
"""
import sys
import json

try:
    data = json.load(sys.stdin)
    file_path = data.get("tool_input", {}).get("file_path", "")

    if "pubspec.yaml" in file_path:
        print("⛔ pubspec.yaml 변경 차단")
        print("외부 패키지 신규 추가는 사람 승인이 필요합니다.")
        print("→ 사용자에게 추가할 패키지와 이유를 먼저 설명하고 승인을 받으세요.")
        sys.exit(2)  # exit 2 = Claude Code가 도구 실행을 차단

except Exception:
    pass  # 파싱 실패 시 차단하지 않음

sys.exit(0)
