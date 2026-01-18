@echo off
REM Windows Release 빌드 스크립트

echo ========================================
echo hairdress_history Windows Release 빌드
echo ========================================
echo.

REM Flutter 빌드 실행
echo [1/2] Flutter Windows Release 빌드 중...
flutter build windows --release

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ❌ 빌드 실패!
    pause
    exit /b 1
)

echo.
echo ✅ 빌드 완료!
echo.
echo ========================================
echo 빌드 결과물 위치:
echo ========================================
echo build\windows\x64\runner\Release\
echo.
echo 배포 파일:
echo   - hairdress_history.exe (빌드 후 생성됨)
echo   - flutter_windows.dll
echo   - data\ 폴더 (전체)
echo   - 기타 DLL 파일들
echo.
echo 참고: 실행 파일 이름은 hairdress_history.exe로 생성됩니다.
echo.
echo ========================================
echo 배포 방법:
echo ========================================
echo 1. 포터블 버전: Release 폴더 전체를 ZIP으로 압축
echo 2. 설치 프로그램: DEPLOYMENT_GUIDE.md 참고
echo.
echo Release 폴더를 열까요? (Y/N)
set /p openFolder=

if /i "%openFolder%"=="Y" (
    explorer build\windows\x64\runner\Release
)

pause
