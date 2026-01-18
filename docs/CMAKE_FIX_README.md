# CMake 한글 이름 문제 해결

## 문제
CMake는 타겟 이름에 한글을 사용할 수 없습니다. 한글 이름을 사용하면 다음과 같은 오류가 발생합니다:

```
CMake Error: The target name "반하다헤어" is reserved or not valid
```

## 해결 방법

CMake 타겟 이름은 영문으로 설정하고, 실행 파일 이름만 한글로 유지하도록 수정했습니다.

### 변경 사항

1. **`windows/CMakeLists.txt`**
   - `project()` 이름: `반하다헤어` → `bandaha_hair`
   - `BINARY_NAME`: `반하다헤어` → `bandaha_hair`

2. **`windows/runner/CMakeLists.txt`**
   - `set_target_properties()` 추가하여 실행 파일 이름을 `반하다헤어.exe`로 설정

### 결과

- **CMake 타겟 이름**: `bandaha_hair` (영문, 빌드 시스템 내부 사용)
- **실행 파일 이름**: `반하다헤어.exe` (한글, 최종 사용자에게 표시)

## 빌드 확인

빌드 후 다음 위치에 한글 이름의 실행 파일이 생성됩니다:

```
build/windows/x64/runner/Release/반하다헤어.exe
```

## 참고

- `file_picker:windows` 경고는 무시해도 됩니다. 플러그인 자체의 문제이며 앱 동작에는 영향이 없습니다.
- 실행 파일 이름은 `Runner.rc`의 `OriginalFilename`과 `CMakeLists.txt`의 `OUTPUT_NAME` 설정에 따라 결정됩니다.
