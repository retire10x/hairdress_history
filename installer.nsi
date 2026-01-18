; 반하다헤어 설치 프로그램 스크립트 (NSIS)
; 파일 인코딩: UTF-8 BOM
; 사용법: makensis installer.nsi

; ============================================
; 설치 프로그램 기본 정보
; ============================================
Name "반하다헤어"
OutFile "반하다헤어_Setup.exe"
InstallDir "$PROGRAMFILES\반하다헤어"
RequestExecutionLevel admin
Unicode true  ; 한글 지원

; ============================================
; 설치 페이지 설정
; ============================================
Page directory
Page instfiles

; ============================================
; 제거 페이지 설정
; ============================================
UninstPage uninstConfirm
UninstPage instfiles

; ============================================
; 설치 섹션
; ============================================
Section "MainSection" SEC01
    SetOutPath "$INSTDIR"
    
    ; 빌드된 모든 파일 복사
    File /r "build\windows\x64\runner\Release\*.*"
    
    ; 시작 메뉴 바로가기 생성
    CreateDirectory "$SMPROGRAMS\반하다헤어"
    CreateShortCut "$SMPROGRAMS\반하다헤어\반하다헤어.lnk" "$INSTDIR\반하다헤어.exe"
    CreateShortCut "$SMPROGRAMS\반하다헤어\제거.lnk" "$INSTDIR\Uninstall.exe"
    
    ; 바탕화면 바로가기 생성 (선택사항)
    CreateShortCut "$DESKTOP\반하다헤어.lnk" "$INSTDIR\반하다헤어.exe"
    
    ; 레지스트리 등록 (제어판 > 프로그램 제거에 표시)
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\반하다헤어" "DisplayName" "반하다헤어"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\반하다헤어" "UninstallString" "$INSTDIR\Uninstall.exe"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\반하다헤어" "Publisher" "반하다헤어"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\반하다헤어" "InstallLocation" "$INSTDIR"
    WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\반하다헤어" "NoModify" 1
    WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\반하다헤어" "NoRepair" 1
    
    ; 제거 프로그램 생성
    WriteUninstaller "$INSTDIR\Uninstall.exe"
SectionEnd

; ============================================
; 제거 섹션
; ============================================
Section "Uninstall"
    ; 파일 삭제
    RMDir /r "$INSTDIR"
    
    ; 시작 메뉴 바로가기 삭제
    Delete "$SMPROGRAMS\반하다헤어\반하다헤어.lnk"
    Delete "$SMPROGRAMS\반하다헤어\제거.lnk"
    RMDir "$SMPROGRAMS\반하다헤어"
    
    ; 바탕화면 바로가기 삭제
    Delete "$DESKTOP\반하다헤어.lnk"
    
    ; 레지스트리 삭제
    DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\반하다헤어"
SectionEnd
