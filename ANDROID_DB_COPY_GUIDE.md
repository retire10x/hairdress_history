# Android Tab A9+ DB 파일 복사 가이드 (Android Studio 없이)

## 방법 1: 파일 관리자 사용 (가장 간단)

### 준비사항
1. Tab A9+가 USB로 연결되어 있음
2. USB 연결 모드가 "파일 전송" 또는 "MTP"로 설정됨

### 단계

1. **앱을 한 번 실행**
   - Tab A9+에서 hairdress_history 앱 실행
   - 앱을 종료 (이렇게 하면 필요한 폴더가 생성됨)

2. **PC에서 파일 탐색기 열기**
   - Tab A9+가 "내 PC"에 표시됨
   - 경로: `내 PC > Miyoung의 Tab A9+`

3. **다음 경로로 이동:**
   ```
   내장 저장공간 > Android > data > com.example.hairdress_history > databases
   ```

4. **DB 파일 복사**
   - PC의 `scripts\hairdress_history.db` 파일을 복사
   - 위의 `databases` 폴더에 붙여넣기

**주의**: `databases` 폴더가 보이지 않으면:
- 앱을 한 번 더 실행
- 숨김 파일 표시 설정 확인

## 방법 2: ADB 사용 (더 확실한 방법)

### ADB 설치

1. **Android SDK Platform Tools 다운로드**
   - https://developer.android.com/studio/releases/platform-tools
   - "Download SDK Platform-Tools for Windows" 클릭

2. **압축 해제**
   - 다운로드한 zip 파일 압축 해제
   - 예: `C:\platform-tools\` 폴더에 압축 해제

3. **PATH에 추가 (선택사항)**
   - 시스템 환경 변수 PATH에 `C:\platform-tools` 추가
   - 또는 배치 파일과 같은 폴더에 `platform-tools` 폴더 복사

### USB 디버깅 활성화

1. **Tab A9+에서 개발자 옵션 활성화**
   - 설정 > 디바이스 정보 > 소프트웨어 정보
   - "빌드 번호"를 7번 연속 탭

2. **USB 디버깅 활성화**
   - 설정 > 개발자 옵션
   - "USB 디버깅" 활성화

3. **PC 연결 시 허용**
   - USB로 연결하면 "USB 디버깅 허용" 팝업 표시
   - "항상 이 컴퓨터에서 허용" 체크 후 허용

### DB 파일 복사

1. **프로젝트 폴더에서 배치 파일 실행:**
   ```
   copy_db_to_android.bat
   ```

2. **또는 수동으로 명령어 실행:**
   ```cmd
   cd C:\platform-tools
   adb devices
   adb push D:\develop\hairdress_history\scripts\hairdress_history.db /data/data/com.example.hairdress_history/databases/hairdress_history.db
   adb shell "run-as com.example.hairdress_history chmod 666 databases/hairdress_history.db"
   ```

## 방법 3: 앱 내부에서 확인

앱을 실행하면 콘솔에 DB 경로가 출력됩니다. 그 경로에 파일을 배치하세요.

## 문제 해결

### "databases 폴더가 보이지 않음"
- 앱을 한 번 실행하면 자동으로 생성됩니다
- 숨김 파일 표시 설정 확인

### "파일을 복사할 수 없음"
- 파일 관리자에서 권한 문제일 수 있음
- ADB 방법 사용 권장

### "USB 디버깅이 작동하지 않음"
- USB 연결 모드를 "파일 전송"으로 변경
- USB 케이블이 데이터 전송을 지원하는지 확인
- 다른 USB 포트 시도
