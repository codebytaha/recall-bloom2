# Recall Bloom

## Overview
Recall Bloom is a Flutter application designed to help users build consistent study habits through daily logging and spaced repetition reminders. This app focuses on core functionalities such as study logging, smart revision scheduling, progress tracking, and a basic focus timer.

## Building the APK

To convert your Flutter app into an APK file, follow these steps:

1. **Open Terminal**: Navigate to your project directory where the `pubspec.yaml` file is located.

2. **Ensure Dependencies are Installed**: Run the following command to ensure all dependencies are installed:
   ```
   flutter pub get
   ```

3. **Build the APK**: Use the following command to build the APK:
   ```
   flutter build apk
   ```
   This command will generate an APK file in the `build/app/outputs/flutter-apk/` directory.

4. **Locate the APK**: After the build process is complete, you can find the APK file in:
   ```
   build/app/outputs/flutter-apk/app-release.apk
   ```
   or
   ```
   build/app/outputs/flutter-apk/app-debug.apk
   ```
   depending on whether you built a release or debug version.

5. **Install the APK**: You can install the APK on your Android device using the following command (ensure your device is connected and USB debugging is enabled):
   ```
   flutter install
   ```

6. **Run the App**: Once installed, you can run the app on your device.

## Requirements
Make sure you have the necessary Android SDK and Flutter environment set up correctly on your machine.