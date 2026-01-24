# Android DB 파일 설정 가이드

## 문제 해결

Android Tab A9+에서 DB 파일을 읽지 못하는 경우, 다음 단계를 따라주세요.

## 1. 실제 DB 경로 확인

앱을 실행하면 콘솔(Logcat)에 다음과 같은 로그가 출력됩니다:

```
Android/iOS databases 경로: /data/data/com.example.hairdress_history/databases
Android/iOS DB 경로: /data/data/com.example.hairdress_history/databases/hairdress_history.db
DB 파일 존재 여부: false
```

**이 경로가 실제 DB 파일이 저장되는 위치입니다.**

## 2. DB 파일 배치 방법

### 방법 1: ADB를 사용한 복사 (가장 확실한 방법)

1. **USB 디버깅 활성화**
   - 설정 > 개발자 옵션 > USB 디버깅 활성화

2. **PC에서 다음 명령어 실행:**
   ```bash
   adb devices
   ```
   기기가 연결되었는지 확인

3. **DB 파일 복사:**
   ```bash
   adb push scripts/hairdress_history.db /data/data/com.example.hairdress_history/databases/hairdress_history.db
   ```

4. **파일 권한 설정:**
   ```bash
   adb shell chmod 666 /data/data/com.example.hairdress_history/databases/hairdress_history.db
   ```

### 방법 2: 앱을 먼저 실행 후 복사

1. **앱을 한 번 실행**하여 `databases` 폴더 생성
2. **ADB로 복사:**
   ```bash
   adb push scripts/hairdress_history.db /data/data/com.example.hairdress_history/databases/hairdress_history.db
   adb shell chmod 666 /data/data/com.example.hairdress_history/databases/hairdress_history.db
   ```

### 방법 3: 파일 관리자 사용 (Android 10+)

**주의**: Android 10 이상에서는 `/data/data/` 경로에 직접 접근할 수 없습니다.

대신 다음 경로를 사용할 수 있습니다:
```
/storage/emulated/0/Android/data/com.example.hairdress_history/databases/
```

하지만 이 경로는 `sqflite.getDatabasesPath()`가 반환하는 경로와 다를 수 있습니다.

## 3. 경로 확인 방법

### Logcat에서 확인

Android Studio에서 Logcat을 열고 다음 필터를 사용:
```
tag: flutter
```

앱 실행 시 다음 로그를 확인:
- `Android/iOS databases 경로: ...`
- `Android/iOS DB 경로: ...`
- `DB 파일 존재 여부: ...`

### ADB로 확인

```bash
adb shell run-as com.example.hairdress_history ls -la databases/
```

또는:

```bash
adb shell "run-as com.example.hairdress_history cat databases/hairdress_history.db" > test.db
```

## 4. 문제 해결 체크리스트

- [ ] 앱을 최소 한 번 실행하여 `databases` 폴더 생성 확인
- [ ] Logcat에서 실제 DB 경로 확인
- [ ] ADB로 DB 파일이 올바른 위치에 있는지 확인
- [ ] 파일 권한이 올바른지 확인 (chmod 666)
- [ ] 앱을 완전히 종료 후 다시 실행

## 5. 자주 발생하는 문제

### 문제: "DB 파일 존재 여부: false"

**원인**: DB 파일이 올바른 위치에 없음

**해결**: 
1. Logcat에서 실제 경로 확인
2. 해당 경로에 DB 파일 복사
3. 파일 권한 확인

### 문제: "Permission denied"

**원인**: 파일 권한 문제

**해결**:
```bash
adb shell chmod 666 /data/data/com.example.hairdress_history/databases/hairdress_history.db
```

### 문제: "databases 폴더가 없음"

**원인**: 앱을 실행하지 않아서 폴더가 생성되지 않음

**해결**: 앱을 한 번 실행하면 자동으로 생성됩니다.
