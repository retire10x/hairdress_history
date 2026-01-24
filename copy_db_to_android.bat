@echo off
echo ========================================
echo Android DB 파일 복사 스크립트
echo ========================================
echo.

REM ADB가 설치되어 있는지 확인
where adb >nul 2>&1
if %errorlevel% neq 0 (
    echo [오류] ADB를 찾을 수 없습니다.
    echo.
    echo ADB 설치 방법:
    echo 1. Android SDK Platform Tools 다운로드
    echo    https://developer.android.com/studio/releases/platform-tools
    echo 2. 압축 해제 후 adb.exe가 있는 폴더를 PATH에 추가
    echo.
    pause
    exit /b 1
)

echo [1단계] 연결된 기기 확인...
adb devices
echo.

REM 기기 연결 확인
adb devices | findstr "device$" >nul
if %errorlevel% neq 0 (
    echo [오류] Android 기기가 연결되지 않았습니다.
    echo.
    echo 확인 사항:
    echo 1. USB 디버깅이 활성화되어 있는지 확인
    echo 2. USB 연결 모드를 "파일 전송" 또는 "MTP"로 설정
    echo 3. 기기에서 "USB 디버깅 허용" 팝업이 있으면 허용
    echo.
    pause
    exit /b 1
)

echo [2단계] DB 파일 확인...
if not exist "scripts\hairdress_history.db" (
    echo [오류] scripts\hairdress_history.db 파일을 찾을 수 없습니다.
    echo.
    echo 먼저 CSV to DB 변환 스크립트를 실행하세요:
    echo python scripts\csv_to_db.py "scripts\Customer All.csv" "scripts\CustomerService All.csv" "scripts\hairdress_history.db"
    echo.
    pause
    exit /b 1
)

echo [3단계] 앱 패키지명 확인...
set PACKAGE_NAME=com.example.hairdress_history
echo 패키지명: %PACKAGE_NAME%
echo.

echo [4단계] databases 폴더 생성 확인...
adb shell "run-as %PACKAGE_NAME% mkdir -p databases" 2>nul
echo.

echo [5단계] DB 파일 복사 중...
adb push scripts\hairdress_history.db /data/data/%PACKAGE_NAME%/databases/hairdress_history.db
if %errorlevel% neq 0 (
    echo.
    echo [오류] DB 파일 복사 실패
    echo.
    echo 해결 방법:
    echo 1. 앱을 한 번 실행하여 databases 폴더가 생성되었는지 확인
    echo 2. USB 디버깅이 활성화되어 있는지 확인
    echo 3. 기기에서 "USB 디버깅 허용" 팝업이 있으면 허용
    echo.
    pause
    exit /b 1
)

echo.
echo [6단계] 파일 권한 설정...
adb shell "run-as %PACKAGE_NAME% chmod 666 databases/hairdress_history.db"
echo.

echo [7단계] 파일 확인...
adb shell "run-as %PACKAGE_NAME% ls -la databases/hairdress_history.db"
echo.

echo ========================================
echo DB 파일 복사 완료!
echo ========================================
echo.
echo 이제 앱을 실행하면 DB 파일을 읽을 수 있습니다.
echo.
pause
