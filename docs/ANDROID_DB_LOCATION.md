# Android DB 파일 위치 안내

## DB 파일 저장 위치

Android에서 `sqflite.getDatabasesPath()`를 사용하면 다음 경로에 DB 파일이 저장됩니다:

### 실제 경로
```
/data/data/com.example.hairdress_history/databases/hairdress_history.db
```

### PC에서 접근 가능한 경로 (Android 10+)
```
내장 저장공간/Android/data/com.example.hairdress_history/databases/hairdress_history.db
```

## DB 파일 배치 방법

### 방법 1: ADB를 사용한 복사 (권장)

1. PC에 Android SDK Platform Tools 설치
2. USB 디버깅 활성화
3. 다음 명령어 실행:

```bash
adb push scripts/hairdress_history.db /data/data/com.example.hairdress_history/databases/hairdress_history.db
```

또는 PC에서 접근 가능한 경로로 복사:

```bash
adb push scripts/hairdress_history.db /storage/emulated/0/Android/data/com.example.hairdress_history/databases/hairdress_history.db
```

### 방법 2: 파일 관리자 사용 (Android 10+)

1. 파일 관리자 앱에서 다음 경로로 이동:
   ```
   내장 저장공간/Android/data/com.example.hairdress_history/databases/
   ```

2. `hairdress_history.db` 파일을 이 폴더에 복사

**주의**: `databases` 폴더가 없으면 앱을 한 번 실행한 후 생성됩니다.

### 방법 3: 앱 내부에서 복사

앱을 실행하면 자동으로 `databases` 폴더가 생성됩니다. 그 후 위의 방법으로 DB 파일을 복사하세요.

## 경로 확인

앱을 실행하면 콘솔에 다음과 같은 로그가 출력됩니다:
```
DB 경로: /data/data/com.example.hairdress_history/databases/hairdress_history.db
```

또는 Android 10+에서는:
```
DB 경로: /storage/emulated/0/Android/data/com.example.hairdress_history/databases/hairdress_history.db
```

## 주의사항

- `files` 폴더가 아닌 **`databases`** 폴더에 DB 파일을 배치해야 합니다
- `databases` 폴더는 앱을 최소 한 번 실행해야 생성됩니다
- Android 10 이상에서는 Scoped Storage로 인해 직접 접근이 제한될 수 있습니다
