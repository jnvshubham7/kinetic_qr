# KineticQR

## Overview

KineticQR is a Flutter application designed to simplify the process of scanning and generating QR codes. The app provides a user-friendly interface for both Android and iOS devices, allowing you to effortlessly handle QR codes for various purposes.

## Features

- **QR Code Scanning**: Quickly scan and decode QR codes to access the embedded information.
- **QR Code Generation**: Create QR codes from text, URLs, contact details, and Wi-Fi settings with ease.
- **Export and Share**: Save and share your generated QR codes in different formats.
- **Dark Mode Support**: Switch to dark mode for a better experience in low-light conditions.

## Installation and Setup

### Prerequisites

- [Flutter](https://flutter.dev/docs/get-started/install) installed on your machine.
- [Dart](https://dart.dev/get-dart) SDK installed (comes with Flutter).
- [Xcode](https://developer.apple.com/xcode/) installed for iOS development (macOS only).

### Running the App

1. **Clone the Repository**

   ```bash
   git clone https://github.com/jnvshubham7/kinetic_qr.git
   ```
2. **Navigate to the Project Directory**

   ```bash
   cd kinetic_qr
   ```
3. **Install Dependencies**

   ```bash
   flutter pub get
   ```
4. **Run the App**

   ```bash
   flutter run
   ```

## Building the App

- **For Android**

  ```bash
  flutter build apk
  ```

  To create a release APK:

  ```bash
  flutter build apk --release
  ```
- **For iOS**

  ```bash
  flutter build ios
  ```

  Make sure you have Xcode configured for iOS builds.

## Additional Features

- **Dark Mode**: Easily switch to dark mode for a more comfortable viewing experience in low light.
- **Animations**: Add animations to enhance user interactions when scanning and generating QR codes.
