# Phase Gates — 단계 전환 조건

각 Phase를 완료하고 다음 Phase로 넘어가기 위한 기준을 정의한다.
모든 gate 항목이 충족돼야 다음 Phase를 시작할 수 있다.

현재 Phase 업데이트는 `/sync-docs` 실행 시 자동으로 반영된다.

---

## 현재 Phase

**Phase 0 — 진행 중**

---

## Phase 0 → Phase 1 Gate (프로젝트 셋업 완료)

다음이 모두 충족돼야 Phase 1을 시작할 수 있다.

```
- [ ] flutter create 완료, 앱이 에뮬레이터에서 실행됨
- [ ] pubspec.yaml에 필수 패키지 추가 완료
      (flame, hive, shared_preferences, riverpod, flame_audio)
- [ ] ARCHITECTURE.md의 폴더 구조 생성 완료
- [ ] flutter analyze 경고 0개
- [ ] flutter test 통과 (기본 생성 테스트)
- [ ] GitHub Actions 워크플로 동작 확인 (PR 시 빌드/테스트 자동 실행)
- [ ] OD-015 (Flame 버전) 결정 완료
```

---

## Phase 1 → Phase 2 Gate (MVP 완료)

```
- [ ] APK 빌드 성공 (flutter build apk)
- [ ] 패들 조작 자연스러움 (수동 확인)
- [ ] 볼 반사각 자연스러움 (수동 확인)
- [ ] 볼 이탈 후 패들 위 재생성 + 탭 발사 정상 작동
- [ ] 마법 분열구 효과 체감됨 (수동 확인)
- [ ] 클리어/실패 판정 정상 작동
- [ ] 60fps 유지 — 마법 분열구 활성화 상태에서도
- [ ] flutter analyze 경고 0개
- [ ] flutter test 전체 통과
- [ ] OD-003 (라이프 유지 여부) 결정 완료
- [ ] OD-005 (분열 각도) 결정 완료
```

---

## Phase 2 → Phase 3 Gate (콘텐츠 확장 완료)

```
- [ ] 스테이지 10개 전부 클리어 가능 여부 검증
- [ ] 아이템 3종 정상 작동 (마법 관통석, 마법 분열구, 마법 화염포)
- [ ] 로컬 저장소 읽기/쓰기 정상 작동
- [ ] 튜토리얼 스킵/완료 양방향 정상 작동
- [ ] flutter analyze 경고 0개
- [ ] flutter test 전체 통과
- [ ] OD-006 (화염포 발사 간격) 결정 완료
- [ ] OD-007 (20회 타격 밸런싱) 완료
- [ ] OD-010 (화염포 튜토리얼) 결정 완료
```

---

## Phase 3 → Phase 4 Gate (가챠 + UI 완성)

```
- [ ] 가챠 확률 합계 = 100% 검증
- [ ] 볼 스킨 인게임 반영 확인
- [ ] 광고 테스트 노출 정상 작동
- [ ] 코인 획득/소모 로직 정상 작동
- [ ] flutter analyze 경고 0개
- [ ] flutter test 전체 통과
- [ ] OD-012 (Crashlytics 도입) 결정 완료
- [ ] OD-016 (광고 SDK) 결정 완료
- [ ] OD-019 (가챠 연출) 결정 완료
- [ ] OD-001 (게임 타이틀) 결정 완료
```

---

## Phase 4 출시 Gate

```
- [ ] 앱 크래시율 0% (내부 테스트 기준)
- [ ] 전체 해상도 테스트 통과 (360×640, 1080×2400)
- [ ] 노치/펀치홀 Safe Area 정상 처리
- [ ] 개인정보처리방침 URL 유효
- [ ] 앱 용량 50MB 이하
- [ ] Google Play 내부 테스트 트랙 배포 성공
- [ ] OD-002 (개발자 계정) 완료
```
