"""
PostToolUse 훅 — flutter analyze 리마인드

.dart 파일이 수정될 때마다 flutter analyze 실행을 상기시킨다.
Flutter 프로젝트가 없는 Phase 0에서는 자동으로 건너뜀.
"""
import sys
import json
import os

try:
    data = json.load(sys.stdin)
    file_path = data.get("tool_input", {}).get("file_path", "")

    # .dart 파일이 아니면 무시
    if not file_path.endswith(".dart"):
        sys.exit(0)

    # Flutter 프로젝트(pubspec.yaml)가 없으면 무시
    if not os.path.exists("pubspec.yaml"):
        sys.exit(0)

    print(f"💡 {os.path.basename(file_path)} 수정됨 → flutter analyze 실행 필요")
    print("   작업이 모두 끝난 후 /run-qa 를 실행하세요.")

except Exception:
    pass

sys.exit(0)
