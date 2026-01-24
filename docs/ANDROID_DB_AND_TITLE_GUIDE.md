# Android Tab A9+ DB 파일 및 app_title.txt 설정 가이드

## 중요: 두 가지 다른 경로

Android에서는 **내부 저장소**와 **외부 저장소**가 다릅니다:

### 1. 내부 저장소 (파일 관리자로 접근 불가)
```
/data/data/com.example.hairdress_history/databases/
```
- **DB 파일 위치**: 여기에 `hairdress_history.db` 저장
- **접근 방법**: ADB만 가능 (파일 관리자로는 접근 불가)
- **이유**: 보안상 앱의 내부 데이터는 다른 앱에서 접근 불가

### 2. 외부 저장소 (파일 관리자로 접근 가능)
```
/storage/emulated/0/Android/data/com.example.hairdress_history/
```
- **app_title.txt 위치**: 여기에 `app_title.txt` 저장
- **접근 방법**: 파일 관리자로 직접 접근 가능
- **PC에서 보이는 경로**: `내 PC > Miyoung의 Tab A9+ > 내장 저장공간 > Android > data > com.example.hairdress_history`

## app_title.txt 설정

### 올바른 위치
```
내장 저장공간/Android/data/com.example.hairdress_history/app_title.txt
```

### 설정 방법
1. **PC에서 파일 탐색기 열기**
   - Tab A9+가 "내 PC"에 표시됨
   - 경로: `내 PC > Miyoung의 Tab A9+ > 내장 저장공간 > Android > data > com.example.hairdress_history`

2. **app_title.txt 파일 생성**
   - 위 경로에 `app_title.txt` 파일 생성
   - 파일 내용에 원하는 제목 입력 (예: "미용실 고객 관리")

3. **앱 재시작**
   - 앱을 완전히 종료 후 다시 실행
   - 또는 Hot restart (`R` 키)

## DB 파일 설정

### 문제: databases 폴더가 보이지 않음

**이유**: `databases` 폴더는 **내부 저장소**에 생성되므로 파일 관리자로는 보이지 않습니다.

### 해결 방법: ADB 사용

#### 1. ADB 설치 (아직 안 했다면)
- https://developer.android.com/studio/releases/platform-tools
- "Download SDK Platform-Tools for Windows" 다운로드
- 압축 해제 (예: `C:\platform-tools\`)

#### 2. USB 디버깅 활성화
- Tab A9+ 설정 > 개발자 옵션 > USB 디버깅 활성화
- USB 연결 시 "USB 디버깅 허용" 팝업에서 허용

#### 3. DB 파일 복사

**방법 A: 배치 파일 사용**
```cmd
copy_db_to_android.bat
```

**방법 B: 수동 명령어**
```cmd
cd C:\platform-tools
adb push D:\develop\hairdress_history\scripts\hairdress_history.db /data/data/com.example.hairdress_history/databases/hairdress_history.db
adb shell "run-as com.example.hairdress_history chmod 666 databases/hairdress_history.db"
```

#### 4. 확인
```cmd
adb shell "run-as com.example.hairdress_history ls -la databases/"
```

## 요약

| 항목 | 경로 | 접근 방법 |
|------|------|-----------|
| **app_title.txt** | `/storage/emulated/0/Android/data/com.example.hairdress_history/app_title.txt` | 파일 관리자로 직접 접근 가능 |
| **DB 파일** | `/data/data/com.example.hairdress_history/databases/hairdress_history.db` | ADB만 가능 (파일 관리자로는 접근 불가) |

## 체크리스트

- [ ] `app_title.txt`를 `/storage/emulated/0/Android/data/com.example.hairdress_history/` 경로에 생성
- [ ] 앱 재시작하여 제목 변경 확인
- [ ] ADB 설치 및 USB 디버깅 활성화
- [ ] `copy_db_to_android.bat` 실행하여 DB 파일 복사
- [ ] 앱 실행하여 DB 파일 읽기 확인
