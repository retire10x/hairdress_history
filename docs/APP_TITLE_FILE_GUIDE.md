# AppBar 제목 외부 파일 설정 가이드

AppBar 제목을 외부 txt 파일에서 읽어오도록 설정했습니다. 이제 코드를 수정하지 않고도 제목을 변경할 수 있습니다.

## 📁 파일 위치

### Windows
```
C:\Users\[사용자명]\Documents\hairdress_history\app_title.txt
```

### Linux/MacOS
```
~/hairdress_history/app_title.txt
```

### Android
```
/storage/emulated/0/hairdress_history/app_title.txt
```

**참고**: 모든 플랫폼에서 `hairdress_history` 폴더를 사용합니다. 자세한 내용은 [HAIRDRESS_HISTORY_FOLDER_GUIDE.md](HAIRDRESS_HISTORY_FOLDER_GUIDE.md)를 참고하세요.

## 📝 파일 형식

`app_title.txt` 파일은 UTF-8 인코딩으로 저장해야 합니다.

**파일 내용 예시:**
```
고객 관리
```

또는

```
반하다헤어
```

## 🔧 사용 방법

### 1. 파일 생성

1. **Windows**: `C:\Users\[사용자명]\Documents\hairdress_history\` 폴더에 `app_title.txt` 파일을 생성합니다.
2. **Linux/MacOS**: `~/hairdress_history/` 폴더에 `app_title.txt` 파일을 생성합니다.
3. **Android**: `/storage/emulated/0/hairdress_history/` 폴더에 `app_title.txt` 파일을 생성합니다.
4. 파일에 원하는 제목을 입력합니다 (한 줄만).
5. 파일을 **UTF-8 인코딩**으로 저장합니다.

### 2. 파일이 없는 경우

- `app_title.txt` 파일이 없으면 기본값(`hairdress_history`)이 사용됩니다.
- 파일을 생성하면 다음 앱 실행 시 자동으로 적용됩니다.

### 3. 파일 수정 후

- 파일을 수정한 후 앱을 **재시작**하면 새로운 제목이 적용됩니다.
- 앱 실행 중에는 캐시된 값을 사용하므로 재시작이 필요합니다.

## 📋 파일 생성 예시

### Windows 메모장 사용

1. 메모장 열기
2. 제목 입력 (예: `고객 관리`)
3. **파일 > 다른 이름으로 저장**
4. 파일 이름: `app_title.txt`
5. 인코딩: **UTF-8** 선택
6. 실행 파일과 같은 폴더에 저장

### PowerShell 사용

```powershell
# 실행 파일 경로로 이동
cd "C:\Program Files\hairdress_history"

# UTF-8로 파일 생성
"고객 관리" | Out-File -Encoding UTF8 app_title.txt
```

## ⚠️ 주의사항

1. **인코딩**: 반드시 **UTF-8**로 저장해야 한글이 깨지지 않습니다.
2. **파일 위치**: 실행 파일과 **같은 폴더**에 있어야 합니다.
3. **파일 이름**: 정확히 `app_title.txt`여야 합니다 (대소문자 구분).
4. **줄바꿈**: 첫 번째 줄만 읽습니다. 여러 줄이 있어도 첫 줄만 사용됩니다.
5. **공백**: 앞뒤 공백은 자동으로 제거됩니다.

## 🔍 동작 방식

1. 앱 시작 시 `app_title.txt` 파일을 읽습니다.
2. 파일이 있으면 내용을 AppBar 제목으로 사용합니다.
3. 파일이 없거나 읽을 수 없으면 기본값(`hairdress_history`)을 사용합니다.
4. 읽은 값은 캐시되어 앱 실행 중에는 재읽기하지 않습니다.

## 📂 배포 시 포함

설치 프로그램을 만들 때 `app_title.txt` 파일을 포함할 수도 있습니다:

### NSIS 예시
```nsis
File "app_title.txt"  ; 선택사항: 기본 제목 파일 포함
```

### Inno Setup 예시
```iss
Source: "app_title.txt"; DestDir: "{app}"; Flags: ignoreversion  ; 선택사항
```

**참고**: 파일을 포함하지 않아도 됩니다. 사용자가 나중에 직접 생성할 수 있습니다.

## 🧪 테스트

1. 앱을 빌드하고 실행합니다.
2. 실행 파일과 같은 폴더에 `app_title.txt` 파일을 생성합니다.
3. 파일에 원하는 제목을 입력합니다 (예: `고객 관리`).
4. 앱을 재시작합니다.
5. AppBar 제목이 변경되었는지 확인합니다.

## 💡 팁

- 여러 사용자가 다른 제목을 사용하려면 각각의 설치 폴더에 `app_title.txt`를 생성하면 됩니다.
- 파일을 삭제하면 기본값으로 돌아갑니다.
- 파일 내용을 비워두면 기본값이 사용됩니다.
