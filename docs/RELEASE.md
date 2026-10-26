# Release Notes: Building Nameat!

## Debug vs. release APK
| | Debug | Release |
| --- | --- | --- |
| Command | `flutter build apk --debug` | `flutter build apk --release` |
| Output | `build/app/outputs/flutter-apk/app-debug.apk` | `build/app/outputs/flutter-apk/app-release.apk` |
| Purpose | Development and testing | Submission and installing on devices |
| Size | [fill in after building] | about 47 MB |

The release build compiles the Dart code ahead of time, removes unused code
and icons (tree-shaking), and is faster and smaller than the debug build.

## Before building
1. Run `flutter pub get`.
2. Run `dart format .` and `flutter analyze` (no issues expected).
3. Run `flutter test`.

## App icon and splash screen
1. The icon image is `assets/icon.png`.
2. `pubspec.yaml` contains the `flutter_launcher_icons` and `flutter_native_splash` settings.
3. Generate them with:
   - `dart run flutter_launcher_icons`
   - `dart run flutter_native_splash:create`

## Permissions
`android/app/src/main/AndroidManifest.xml` declares
`<uses-permission android:name="android.permission.INTERNET"/>`.
Without it, the release app cannot call the Overpass API, because release
builds only get the permissions they declare.

## Notes
- The first release build took a long time because Gradle downloaded its tools. Later builds were much faster.
- Testing: [write what you actually tested, for example "installed on an Android emulator" or "ran with flutter run in Chrome"].