# Android 아이콘 설정 가이드

Android 앱 아이콘을 Windows와 동일한 `assets/icon.png`로 설정하는 방법입니다.

## 📱 아이콘 생성

### 자동 생성 (권장)

`flutter_launcher_icons` 패키지를 사용하여 자동으로 생성합니다.

#### 1. 패키지 설치 확인

`pubspec.yaml`에 다음이 포함되어 있는지 확인:

```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1

flutter_launcher_icons:
  android: true
  ios: false
  image_path: "assets/icon.png"
  min_sdk_android: 21
```

#### 2. 아이콘 생성

다음 명령어를 실행:

```bash
flutter pub get
flutter pub run flutter_launcher_icons
```

#### 3. 결과 확인

다음 경로에 아이콘이 생성됩니다:

```
android/app/src/main/res/
├── mipmap-hdpi/ic_launcher.png      (72x72)
├── mipmap-mdpi/ic_launcher.png      (48x48)
├── mipmap-xhdpi/ic_launcher.png     (96x96)
├── mipmap-xxhdpi/ic_launcher.png    (144x144)
└── mipmap-xxxhdpi/ic_launcher.png   (192x192)
```

## 🔄 아이콘 업데이트

아이콘을 변경하려면:

1. `assets/icon.png` 파일을 새 아이콘으로 교체
2. 다음 명령어 실행:
   ```bash
   flutter pub run flutter_launcher_icons
   ```

## 📋 요구사항

### 원본 이미지

- **파일 형식**: PNG
- **권장 크기**: 1024x1024 픽셀 이상
- **위치**: `assets/icon.png`

### Android 아이콘 크기

Android는 다양한 화면 밀도에 맞춰 여러 크기의 아이콘을 필요로 합니다:

| 밀도 | 크기 | 경로 |
|------|------|------|
| mdpi | 48x48 | mipmap-mdpi |
| hdpi | 72x72 | mipmap-hdpi |
| xhdpi | 96x96 | mipmap-xhdpi |
| xxhdpi | 144x144 | mipmap-xxhdpi |
| xxxhdpi | 192x192 | mipmap-xxxhdpi |

`flutter_launcher_icons`가 자동으로 모든 크기를 생성합니다.

## ✅ 확인 방법

### 빌드 후 확인

1. APK 빌드:
   ```bash
   flutter build apk --release
   ```

2. 설치 후 홈 화면에서 아이콘 확인

### 개발 중 확인

1. 앱 실행:
   ```bash
   flutter run
   ```

2. 홈 화면에서 앱 아이콘 확인

## 🔧 문제 해결

### 아이콘이 변경되지 않음

1. 앱 완전 삭제 후 재설치
2. 기기 재시작
3. 캐시 삭제:
   ```bash
   flutter clean
   flutter pub get
   flutter pub run flutter_launcher_icons
   ```

### 아이콘 생성 실패

1. `assets/icon.png` 파일이 존재하는지 확인
2. 이미지 파일이 손상되지 않았는지 확인
3. `pubspec.yaml` 설정이 올바른지 확인

## 📝 참고

- Windows 아이콘과 동일한 `assets/icon.png` 파일을 사용합니다.
- iOS 아이콘도 필요하면 `ios: true`로 설정할 수 있습니다.
- 아이콘을 변경한 후에는 앱을 재빌드해야 합니다.
