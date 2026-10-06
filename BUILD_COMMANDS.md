# Davochain – Build & Execution Commands

A quick reference guide for running, building, and deploying the Davochain Flutter app.

---

## 1. Run & Test on Emulator (Interactive / Dev Mode)

Make sure your Android emulator is running, then run:

```powershell
flutter run -d emulator-5554
```
*(Or simply `flutter run` if only one device is connected).*

### Keyboard Controls in Interactive Mode:
- **`r`** – Hot reload (instantly updates code changes)
- **`R`** – Hot restart (resets state and re-runs app)
- **`h`** – Show all interactive shortcuts
- **`q`** – Quit / Stop the running app

---

## 2. Build Standalone APKs

> **Note:** The first time you run a build command, Gradle may take 1–3 minutes to assemble the APK. Do not press `Ctrl+C` while `assembleDebug` or `assembleRelease` is running.

### A. Build Debug APK (Fast, unoptimized, for testing)
```powershell
flutter build apk --debug
```
- **Output File:**  
  `build\app\outputs\flutter-apk\app-debug.apk`

---

### B. Build Release APK (Optimized, for physical devices / distribution)
```powershell
flutter build apk --release
```
- **Output File:**  
  `build\app\outputs\flutter-apk\app-release.apk`

---

### C. Build Split APKs (Smaller file size by architecture)
If you want smaller APKs tailored to specific processor architectures (ARM64, ARMv7, x86_64):
```powershell
flutter build apk --split-per-abi
```
- **Output Location:**  
  `build\app\outputs\flutter-apk\`

---

## 3. Install Pre-built APK to Emulator via ADB

If you built an APK and want to push it directly to your emulator without starting a Flutter debug session:

```powershell
adb install -r build\app\outputs\flutter-apk\app-debug.apk
```
*(Or replace `app-debug.apk` with `app-release.apk`).*

---

## 4. Helpful Maintenance & Troubleshooting Commands

### Check Connected Devices & Emulators
```powershell
flutter devices
```

### Full Clean (Use if you get Gradle/cache errors or stale assets)
```powershell
flutter clean
flutter pub get
```

### Regenerate Native Splash Screen (Android & iOS)
```powershell
dart run flutter_native_splash:create
```

### Check Code Health
```powershell
flutter analyze
flutter test
```
