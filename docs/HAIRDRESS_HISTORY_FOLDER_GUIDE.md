# hairdress_history 폴더 가이드

백업 파일과 `app_title.txt` 파일이 모두 `hairdress_history` 폴더에 저장됩니다.

## 📁 폴더 위치

### Windows
```
C:\Users\[사용자명]\Documents\hairdress_history\
```

**구조:**
```
Documents/
└── hairdress_history/
    ├── app_title.txt          # AppBar 제목 파일
    └── backups/                # 백업 파일 폴더
        └── hairdress_backup_YYYYMMDD_HHMMSS.csv
```

### Linux/MacOS
```
~/hairdress_history/
```

**구조:**
```
~/
└── hairdress_history/
    ├── app_title.txt          # AppBar 제목 파일
    └── backups/                # 백업 파일 폴더
        └── hairdress_backup_YYYYMMDD_HHMMSS.csv
```

### Android
```
/내부 저장소/Download/hairdress_history/
```

**구조:**
```
내부 저장소/
└── Download/
    └── hairdress_history/
        ├── app_title.txt          # AppBar 제목 파일
        └── backups/                # 백업 파일 폴더
            └── hairdress_backup_YYYYMMDD_HHMMSS.csv
```

**참고**: 
- Android 10 이상에서는 Scoped Storage로 인해 `/Android/data/` 폴더는 파일 관리자에서 접근할 수 없습니다.
- 다운로드 폴더를 사용하면 파일 관리자에서 직접 접근할 수 있습니다.
- 자세한 내용: [ANDROID_FILE_ACCESS_GUIDE.md](ANDROID_FILE_ACCESS_GUIDE.md)

## 📝 app_title.txt 파일

### 위치
- **Windows**: `C:\Users\[사용자명]\Documents\hairdress_history\app_title.txt`
- **Linux/MacOS**: `~/hairdress_history/app_title.txt`
- **Android**: `/storage/emulated/0/hairdress_history/app_title.txt`

### 생성 방법

#### Windows
1. 파일 탐색기에서 `C:\Users\[사용자명]\Documents\hairdress_history\` 폴더로 이동
2. 새 텍스트 파일 생성: `app_title.txt`
3. 내용 입력 (예: `고객 관리`)
4. UTF-8 인코딩으로 저장

#### Android
1. 파일 관리자 앱 열기
2. 내부 저장소 루트로 이동
3. `hairdress_history` 폴더 생성 (없는 경우)
4. `app_title.txt` 파일 생성
5. 내용 입력 (예: `고객 관리`)
6. UTF-8 인코딩으로 저장

### 파일 형식
- **파일 이름**: `app_title.txt` (대소문자 구분)
- **인코딩**: UTF-8
- **내용**: 한 줄만 입력 (첫 줄만 읽음)
- **예시**:
  ```
  고객 관리
  ```

## 💾 백업 파일

### 위치
- **Windows**: `C:\Users\[사용자명]\Documents\hairdress_history\backups\`
- **Linux/MacOS**: `~/hairdress_history/backups/`
- **Android**: `/storage/emulated/0/hairdress_history/backups/`

### 파일 이름 형식
```
hairdress_backup_YYYYMMDD_HHMMSS.csv
```

예시:
```
hairdress_backup_20240123_143022.csv
```

### 자동 생성
- 백업 기능을 사용하면 `backups` 폴더가 자동으로 생성됩니다.
- 폴더가 없으면 앱이 자동으로 생성합니다.

## 🔍 폴더 확인 방법

### Windows
1. 파일 탐색기 열기
2. 주소창에 다음 입력:
   ```
   %USERPROFILE%\Documents\hairdress_history
   ```
3. Enter 키 누르기

### Android
1. 파일 관리자 앱 열기
2. **내부 저장소 > Download > hairdress_history** 폴더로 이동
3. `app_title.txt` 및 `backups` 폴더 확인

### ADB 사용 (개발자용)
```bash
# Android에서 폴더 확인
adb shell ls /storage/emulated/0/hairdress_history/

# app_title.txt 확인
adb shell cat /storage/emulated/0/hairdress_history/app_title.txt

# 백업 파일 목록 확인
adb shell ls /storage/emulated/0/hairdress_history/backups/
```

## ⚠️ 주의사항

1. **폴더 자동 생성**: 앱이 처음 실행되거나 백업을 생성할 때 폴더가 자동으로 생성됩니다.
2. **권한**: Android에서는 외부 저장소 접근 권한이 필요할 수 있습니다.
3. **파일 인코딩**: `app_title.txt`는 반드시 **UTF-8** 인코딩으로 저장해야 합니다.
4. **앱 재시작**: `app_title.txt`를 생성하거나 수정한 후 앱을 재시작해야 적용됩니다.

## 💡 팁

- **백업 관리**: 백업 파일은 `backups` 폴더에 저장되므로 정기적으로 정리할 수 있습니다.
- **제목 변경**: `app_title.txt` 파일을 수정하면 앱 재시작 후 새로운 제목이 적용됩니다.
- **폴더 공유**: Windows에서 `hairdress_history` 폴더를 다른 컴퓨터와 공유하여 백업 파일을 쉽게 관리할 수 있습니다.
