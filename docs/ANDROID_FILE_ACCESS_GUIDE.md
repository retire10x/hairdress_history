# Android 파일 접근 가이드

Android 10 이상에서는 Scoped Storage로 인해 `/Android/data/` 폴더에 직접 접근할 수 없습니다. 이 가이드는 Android에서 파일에 접근하는 방법을 설명합니다.

## 📁 파일 위치 (우선순위 순)

### app_title.txt

앱은 다음 순서로 `app_title.txt` 파일을 찾습니다:

#### 1순위: 다운로드 폴더 (권장) ✅
```
/내부 저장소/Download/hairdress_history/app_title.txt
```

**장점:**
- 파일 관리자에서 직접 접근 가능
- PC에서도 쉽게 접근 가능
- 권한 없이 접근 가능 (Android 10 이상)

**접근 방법:**
1. 파일 관리자 앱 열기
2. **내부 저장소 > Download > hairdress_history** 폴더로 이동
3. `app_title.txt` 파일 확인/수정

#### 2순위: 앱의 외부 저장소 디렉토리
```
/Android/data/com.example.hairdress_history/files/hairdress_history/app_title.txt
```

**주의:**
- 파일 관리자에서 직접 접근 불가 (Android 제한)
- PC에서만 접근 가능
- 앱 삭제 시 함께 삭제됨

#### 3순위: 앱의 내부 문서 디렉토리
```
/data/data/com.example.hairdress_history/app_flutter/hairdress_history/app_title.txt
```

**주의:**
- 루팅 없이는 접근 불가

### 백업 파일

백업 파일은 **FilePicker를 사용하여 사용자가 직접 위치를 선택**합니다.

**자동 백업 경로 (FilePicker 미사용 시):**
```
/내부 저장소/Download/hairdress_history/backups/hairdress_backup_*.csv
```

## 🔧 해결 방법

### 방법 1: 다운로드 폴더 사용 (권장)

가장 간단하고 접근하기 쉬운 방법입니다.

#### app_title.txt 생성

1. **파일 관리자 앱** 열기
2. **내부 저장소 > Download** 폴더로 이동
3. **hairdress_history** 폴더 생성 (없는 경우)
4. `app_title.txt` 파일 생성
5. 내용 입력 (예: `고객 관리`)
6. **UTF-8 인코딩**으로 저장

#### 백업 파일 확인

1. **파일 관리자 앱** 열기
2. **내부 저장소 > Download > hairdress_history > backups** 폴더로 이동
3. 백업 파일 확인

### 방법 2: PC에서 접근

#### app_title.txt 수정

1. Android 기기를 PC에 연결
2. **파일 전송 모드** 선택
3. PC에서 다음 경로로 이동:
   ```
   내부 저장소\Download\hairdress_history\app_title.txt
   ```
4. 파일 수정 후 저장

#### 백업 파일 복사

1. Android 기기를 PC에 연결
2. PC에서 다음 경로로 이동:
   ```
   내부 저장소\Download\hairdress_history\backups\
   ```
3. 백업 파일 복사/이동

### 방법 3: ADB 사용 (개발자용)

```bash
# 다운로드 폴더 확인
adb shell ls /storage/emulated/0/Download/hairdress_history/

# app_title.txt 확인
adb shell cat /storage/emulated/0/Download/hairdress_history/app_title.txt

# app_title.txt 생성
adb push app_title.txt /storage/emulated/0/Download/hairdress_history/app_title.txt

# 백업 파일 목록 확인
adb shell ls /storage/emulated/0/Download/hairdress_history/backups/
```

## ⚠️ 주의사항

### Android 10 이상 (API 29+)

- **Scoped Storage**: `/Android/data/` 폴더는 파일 관리자에서 접근 불가
- **공개 디렉토리**: 다운로드 폴더, Documents 폴더 등은 접근 가능
- **권한**: 다운로드 폴더는 권한 없이 접근 가능

### 앱 삭제 시

- **다운로드 폴더**: 파일 유지됨 ✅
- **앱의 외부 저장소 디렉토리**: 파일 삭제됨 ❌

### 권한

- **다운로드 폴더**: 권한 불필요 (Android 10 이상)
- **외부 저장소 루트**: 권한 필요 (Android 10 이하만 가능)

## 💡 권장 사항

1. **app_title.txt**: 다운로드 폴더에 생성 (접근 용이)
2. **백업 파일**: FilePicker로 사용자가 위치 선택 (권장)
3. **자동 백업**: 다운로드 폴더 사용 (접근 용이)

## 📋 폴더 구조

```
내부 저장소/
└── Download/
    └── hairdress_history/
        ├── app_title.txt          # AppBar 제목 파일
        └── backups/                # 백업 파일 폴더
            └── hairdress_backup_YYYYMMDD_HHMMSS.csv
```

## 🔍 문제 해결

### "Android 제한으로 이 폴더의 내용은 PC에서만 확인할 수 있습니다" 메시지

이 메시지는 `/Android/data/` 폴더에 접근하려고 할 때 나타납니다.

**해결 방법:**
- 다운로드 폴더 사용 (권장)
- PC에서 접근
- ADB 사용 (개발자용)

### 파일을 찾을 수 없음

1. 파일이 올바른 위치에 있는지 확인
2. 파일 이름이 정확한지 확인 (`app_title.txt`)
3. 인코딩이 UTF-8인지 확인
4. 앱을 재시작

### 권한 오류

1. AndroidManifest.xml에 권한이 추가되어 있는지 확인
2. 앱 권한 설정에서 저장소 권한이 허용되어 있는지 확인
3. Android 10 이상에서는 다운로드 폴더 사용 (권한 불필요)
