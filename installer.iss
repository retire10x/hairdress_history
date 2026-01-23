; 반하다헤어 설치 프로그램 스크립트 (Inno Setup)
; 파일 인코딩: UTF-8
; 사용법: Inno Setup Compiler에서 열고 Build > Compile

[Setup]
; 앱 정보
AppName=반하다헤어
AppVersion=1.0.0
AppPublisher=반하다헤어
DefaultDirName={pf}\반하다헤어
DefaultGroupName=반하다헤어
OutputBaseFilename=반하다헤어_Setup
OutputDir=.

; 압축 설정
Compression=lzma2
SolidCompression=yes
LZMAUseSeparateProcess=yes

; 설치 설정
PrivilegesRequired=admin
ArchitecturesInstallIn64BitMode=x64
DisableProgramGroupPage=no
DisableReadyPage=no
DisableWelcomePage=no

; 아이콘 설정
SetupIconFile=assets\icon.ico
UninstallDisplayIcon={app}\반하다헤어.exe

[Languages]
Name: "korean"; MessagesFile: "compiler:Languages\Korean.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
; 빌드된 모든 파일 복사
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
; 시작 메뉴 바로가기
Name: "{group}\반하다헤어"; Filename: "{app}\반하다헤어.exe"
Name: "{group}\{cm:UninstallProgram,반하다헤어}"; Filename: "{uninstallexe}"

; 바탕화면 바로가기 (선택사항)
Name: "{autodesktop}\반하다헤어"; Filename: "{app}\반하다헤어.exe"; Tasks: desktopicon

[Run]
; 설치 완료 후 실행 (선택사항)
Filename: "{app}\반하다헤어.exe"; Description: "{cm:LaunchProgram,반하다헤어}"; Flags: nowait postinstall skipifsilent
