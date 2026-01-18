@echo off
REM hairdress_history 설치 프로그램 생성 스크립트
REM 이 스크립트는 Release 빌드 후 설치 프로그램을 자동으로 생성합니다.

echo ========================================
echo hairdress_history 설치 프로그램 생성
echo ========================================
echo.

REM 1. Release 빌드 확인
if not exist "build\windows\x64\runner\Release\hairdress_history.exe" (
    echo [오류] Release 빌드가 없습니다.
    echo 먼저 'build_release.bat'를 실행하거나 'flutter build windows --release'를 실행하세요.
    pause
    exit /b 1
)

echo [1/3] Release 빌드 확인 완료
echo.

REM 2. 설치 프로그램 도구 선택
echo 설치 프로그램 생성 도구를 선택하세요:
echo   1. NSIS (Nullsoft Scriptable Install System)
echo   2. Inno Setup
echo.
set /p choice="선택 (1 또는 2): "

if "%choice%"=="1" goto :nsis
if "%choice%"=="2" goto :inno
echo 잘못된 선택입니다.
pause
exit /b 1

:nsis
echo.
echo [2/3] NSIS로 설치 프로그램 생성 중...
if not exist "C:\Program Files (x86)\NSIS\makensis.exe" (
    if not exist "C:\Program Files\NSIS\makensis.exe" (
        echo [오류] NSIS가 설치되어 있지 않습니다.
        echo NSIS를 설치하세요: https://nsis.sourceforge.io/Download
        pause
        exit /b 1
    ) else (
        set NSIS_PATH=C:\Program Files\NSIS\makensis.exe
    )
) else (
    set NSIS_PATH=C:\Program Files (x86)\NSIS\makensis.exe
)

if not exist "installer.nsi" (
    echo [오류] installer.nsi 파일이 없습니다.
    pause
    exit /b 1
)

"%NSIS_PATH%" installer.nsi

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo [오류] NSIS 컴파일 실패!
    pause
    exit /b 1
)

    echo.
    echo [3/3] 설치 프로그램 생성 완료!
    echo 생성된 파일: hairdress_history_Setup.exe
    goto :end

:inno
echo.
echo [2/3] Inno Setup으로 설치 프로그램 생성 중...
if not exist "C:\Program Files (x86)\Inno Setup 6\ISCC.exe" (
    if not exist "C:\Program Files\Inno Setup 6\ISCC.exe" (
        echo [오류] Inno Setup이 설치되어 있지 않습니다.
        echo Inno Setup을 설치하세요: https://jrsoftware.org/isdl.php
        pause
        exit /b 1
    ) else (
        set INNO_PATH=C:\Program Files\Inno Setup 6\ISCC.exe
    )
) else (
    set INNO_PATH=C:\Program Files (x86)\Inno Setup 6\ISCC.exe
)

if not exist "installer.iss" (
    echo [오류] installer.iss 파일이 없습니다.
    pause
    exit /b 1
)

"%INNO_PATH%" installer.iss

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo [오류] Inno Setup 컴파일 실패!
    pause
    exit /b 1
)

echo.
echo [3/3] 설치 프로그램 생성 완료!
echo 생성된 파일: hairdress_history_Setup.exe
goto :end

:end
echo.
echo ========================================
echo 설치 프로그램 생성 완료!
echo ========================================
echo.
echo 다음 단계:
echo   1. hairdress_history_Setup.exe 파일을 테스트하세요
echo   2. 다른 컴퓨터에서도 테스트하세요
echo   3. 배포 준비가 완료되었습니다!
echo.
pause
