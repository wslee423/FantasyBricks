# SECURITY.md — 보안 기준

## 개요
로컬 저장 기반의 캐주얼 게임이므로
보안 위협 범위는 제한적입니다.
주요 보안 목표는 저장 데이터 변조 방지와
광고 어뷰징 방지입니다.

---

## 1. 위협 모델

| 위협 | 가능성 | 영향도 | 대응 우선순위 |
|------|--------|--------|-------------|
| 로컬 저장 데이터 변조 (코인, 진행도) | 중간 | 낮음 | 낮음 |
| 광고 어뷰징 (일 제한 초과) | 중간 | 중간 | 중간 |
| APK 역공학 | 낮음 | 낮음 | 낮음 |
| 네트워크 공격 | 없음 (로컬 전용) | 없음 | 해당 없음 |

> 백엔드 서버가 없으므로 네트워크 기반 공격 위협은 없습니다.

---

## 2. 로컬 저장 데이터 보호

### 기본 원칙
- 저장 데이터 변조는 **자기 자신의 게임 경험만 영향**
- 리더보드/멀티플레이 없으므로 타인에게 피해 없음
- 과도한 암호화보다 **최소한의 무결성 검증**으로 충분

### 무결성 체크 (간단한 해시)
```dart
// 저장 시 체크섬 함께 저장
String generateChecksum(Map<String, dynamic> data) {
  final content = jsonEncode(data);
  return sha256.convert(utf8.encode(content)).toString();
}

// 로드 시 체크섬 검증
bool validateChecksum(Map<String, dynamic> data, String checksum) {
  return generateChecksum(data) == checksum;
}
// 검증 실패 시 → 데이터 초기화 (RELIABILITY.md 참고)
```

### 보호 대상 데이터
| 데이터 | 보호 수준 | 이유 |
|--------|----------|------|
| 마법 코인 | 체크섬 검증 | 광고 어뷰징 연계 가능 |
| 스테이지 진행도 | 체크섬 검증 | 게임 경험 무결성 |
| 보유 스킨 목록 | 체크섬 검증 | 가챠 시스템 무결성 |
| 튜토리얼 완료 여부 | 검증 불필요 | 영향도 낮음 |

---

## 3. 광고 어뷰징 방지

### 일일 광고 제한 (확정: 5회/일)
```dart
// 광고 시청 횟수 로컬 저장 + 날짜 검증
class AdLimitManager {
  static const int DAILY_LIMIT = 5; // 확정값

  Future<bool> canWatchAd() async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final savedDate = prefs.getString('ad_date');
    final count = prefs.getInt('ad_count') ?? 0;

    // 날짜 바뀌면 카운트 리셋
    if (savedDate != today) {
      await prefs.setString('ad_date', today);
      await prefs.setInt('ad_count', 0);
      return true;
    }
    return count < DAILY_LIMIT;
  }
}
```

### 광고 보상 지급 원칙
- 광고 **완료 콜백** 확인 후에만 보상 지급
- 광고 스킵/실패 시 보상 없음
- 보상 지급 전 `canWatchAd()` 재검증

---

## 4. APK 보안

### 코드 난독화
```
# android/app/proguard-rules.pro 에 추가
-keep class com.google.android.gms.** { *; }
-keep class io.flutter.** { *; }
```
- Flutter 릴리즈 빌드 기본 난독화 활성화 (`--obfuscate` 플래그)
- 스테이지 데이터(JSON)는 평문 저장 허용 (변조해도 자기 게임만 영향)

### 빌드 보안
| 항목 | 기준 |
|------|------|
| 서명 키스토어 | 로컬 보관 + GitHub Secrets에 암호화 저장 |
| 릴리즈 빌드 | `--obfuscate --split-debug-info` 적용 |
| 디버그 로그 | 릴리즈 빌드에서 전체 제거 |

---

## 5. 개인정보 보호

### 수집 데이터
| 데이터 | 수집 여부 | 이유 |
|--------|----------|------|
| 기기 식별자 | 미수집 | 로컬 전용 게임 |
| 위치 정보 | 미수집 | 불필요 |
| 광고 ID | AdMob 자동 수집 | 개인정보처리방침 명시 필요 |
| 크래시 로그 | Firebase 수집 선택 | QUALITY_SCORE.md 미결 항목 |

### 개인정보처리방침 필수 명시 항목
- AdMob 광고 ID 수집 및 사용 목적
- 제3자 제공 여부 (Google AdMob)
- 데이터 보관 기간
- 사용자 권리 (삭제 요청 등)

> Google Play 광고 SDK 사용 시 개인정보처리방침 페이지 필수

---

## 미결 의사결정

- [ ] 체크섬 알고리즘 선택 (SHA-256 vs 간단한 CRC32)
- [ ] Firebase Crashlytics 도입 여부 → QUALITY_SCORE.md에서 통합 관리
  - 도입 시 개인정보처리방침 업데이트 필요
