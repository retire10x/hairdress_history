# Android에서 app_title.txt 파일 위치 가이드

Android에서 AppBar 제목을 변경하려면 `app_title.txt` 파일을 생성해야 합니다.

## 📁 파일 위치 (우선순위 순)

앱은 다음 순서로 `app_title.txt` 파일을 찾습니다:

### 1순위: 다운로드 폴더 (권장)
```
/storage/emulated/0/Download/app_title.txt
```
또는
```
/내부 저장소/Download/app_title.txt
```

**장점**: 사용자가 가장 쉽게 접근할 수 있는 위치입니다.

### 2순위: 앱의 외부 저장소 디렉토리
```
/storage/emulated/0/Android/data/com.example.hairdress_history/files/app_title.txt
```

### 3순위: 앱의 내부 문서 디렉토리
```
/data/data/com.example.hairdress_history/app_flutter/app_title.txt
```

**참고**: 이 위치는 루팅 없이는 접근할 수 없습니다.

## 📝 파일 생성 방법

### 방법 1: 파일 관리자 사용 (가장 쉬움)

1. **파일 관리자 앱** 열기 (예: 삼성 파일, Google 파일)
2. **다운로드(Download)** 폴더로 이동
3. 새 텍스트 파일 생성: `app_title.txt`
4. 파일 내용 입력 (예: `고객 관리` 또는 `반하다헤어`)
5. **UTF-8 인코딩**으로 저장

### 방법 2: 메모장 앱 사용

1. **메모장 앱** 설치 (예: Jota+, QuickEdit)
2. 새 파일 생성
3. 제목 입력 (예: `고객 관리`)
4. **다운로드 폴더**에 `app_title.txt`로 저장
5. 인코딩: **UTF-8** 선택

### 방법 3: PC에서 생성 후 전송

1. PC에서 메모장 열기
2. 제목 입력 (예: `고객 관리`)
3. **파일 > 다른 이름으로 저장**
4. 파일 이름: `app_title.txt`
5. 인코딩: **UTF-8** 선택
6. 저장 후 Android 기기의 **다운로드 폴더**로 복사

## 📋 파일 형식

- **파일 이름**: 정확히 `app_title.txt` (대소문자 구분)
- **인코딩**: **UTF-8** (한글 깨짐 방지)
- **내용**: 한 줄만 입력 (첫 줄만 읽음)
- **예시**:
  ```
  고객 관리
  ```
  또는
  ```
  반하다헤어
  ```

## 🔍 파일 위치 확인 방법

### ADB 사용 (개발자용)

```bash
# 다운로드 폴더 확인
adb shell ls /storage/emulated/0/Download/app_title.txt

# 앱의 외부 저장소 확인
adb shell ls /storage/emulated/0/Android/data/com.example.hairdress_history/files/app_title.txt
```

### 파일 관리자에서 확인

1. 파일 관리자 앱 열기
2. **내부 저장소 > Download** 폴더로 이동
3. `app_title.txt` 파일이 있는지 확인

## ⚠️ 주의사항

1. **인코딩**: 반드시 **UTF-8**로 저장해야 한글이 깨지지 않습니다.
2. **파일 이름**: 정확히 `app_title.txt`여야 합니다 (대소문자 구분).
3. **줄바꿈**: 첫 번째 줄만 읽습니다. 여러 줄이 있어도 첫 줄만 사용됩니다.
4. **공백**: 앞뒤 공백은 자동으로 제거됩니다.
5. **앱 재시작**: 파일을 생성하거나 수정한 후 앱을 **재시작**해야 적용됩니다.

## 🧪 테스트

1. 다운로드 폴더에 `app_title.txt` 파일 생성
2. 파일 내용: `고객 관리` (UTF-8 인코딩)
3. 앱 완전 종료 후 재시작
4. AppBar 제목이 "고객 관리"로 변경되었는지 확인

## 💡 팁

- **가장 쉬운 방법**: 다운로드 폴더에 파일을 생성하는 것입니다.
- 파일이 여러 위치에 있으면 **1순위(다운로드 폴더)**의 파일이 우선 사용됩니다.
- 파일을 삭제하면 기본값(`hairdress_history`)으로 돌아갑니다.
