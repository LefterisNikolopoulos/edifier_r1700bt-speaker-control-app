@echo off
echo Building ESP Speaker Control APK...
echo.
echo Make sure Flutter is installed and in PATH
echo.
flutter pub get
flutter build apk --release
echo.
echo APK created at: build\app\outputs\flutter-apk\app-release.apk
pause