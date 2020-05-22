<h1 align="center">
    Corona Warn App - iOS
</h1>

<p align="center">
    <a href="https://github.com/corona-warn-app/cwa-app-ios/issues" title="Open Issues"><img src="https://img.shields.io/github/issues/corona-warn-app/cwa-app-ios"></a>
    <a href="https://circleci.com/gh/corona-warn-app/cwa-app-ios" title="Build Status"><img src="https://circleci.com/gh/corona-warn-app/cwa-app-ios.png?circle-token=656940b0df758209128b0d782c5f8885ddceb7a8&style=shield"></a>
    <a href="./LICENSE" title="License"><img src="https://img.shields.io/badge/License-Apache%202.0-green.svg"></a>
</p>

<p align="center">
  <a href="#development">Development</a> •
  <a href="#architecture--documentation">Documenation</a> •
  <a href="#contributing">Contributing</a> •
  <a href="#support--feedback">Support</a> •
  <a href="https://github.com/corona-warn-app/cwa-admin/releases">Changelog</a>
</p>

This project has the goal to develop the official Corona-Warn-App for Germany based on the Exposure Notification API by [Apple](https://www.apple.com/covid19/contacttracing/) and [Google](https://www.google.com/covid19/exposurenotifications/).  The apps (for both iOS and Android) will collect anonymous data from nearby mobile phones using Bluetooth technology. The data will be stored locally on each device, preventing authorities’ access and control over tracing data. This repository contains the **native iOS implementation** of the Corona-Warn-App. This implementation is **work in progress** and contains alpha-quality code only.

_TODO: Add screenshots here._

## Development

### Setup

Open Xcode 11.5 or higher and let the Swift Package Manager handle the rest 🎉

### Build

Either build directly from Xcode or use fastlane to build and run all tests:

```console
cd src/xcode && fastlane build
cd src/xcode && fastlane test
```

Find all available lanes: [Fastfile documenation](src/xcode/fastlane/README.md)

### Run

_TODO: Steps/commmands needed to run the project in development mode._

## Known Issues

_TODO: Use this section to list known issues of the current implementation._

## Architecture & Documentation

The full documentation for the Corona-Warn-App is in the [cwa-documentation](https://github.com/corona-warn-app/cwa-documentation) repository. Please refer to this repository for technical documents, UI/UX specifications, architectures, and whitepapers of this implementation.

## Support & Feedback

| Type                     | Channel                                                |
| ------------------------ | ------------------------------------------------------ |
| **General Discussion**   | <a href="https://github.com/corona-warn-app/cwa-documentation/issues/new/choose" title="General Discussion"><img src="https://img.shields.io/github/issues/DP-3T/documents/question.svg?style=flat-square"></a> </a>   |
| **Concept Feedback**    | <a href="https://github.com/corona-warn-app/cwa-documentation/issues/new/choose" title="Open Concept Feedback"><img src="https://img.shields.io/github/issues/DP-3T/documents/concept-extension.svg?style=flat-square"></a>  |
| **iOS App Issue**    | <a href="https://github.com/corona-warn-app/cwa-app-ios/issues/new/choose" title="Open iOS Suggestion"><img src="https://img.shields.io/github/issues/DP-3T/documents/ios-app.svg?style=flat-square"></a>  |
| **Android App Issue**    | <a href="https://github.com/corona-warn-app/cwa-app-android/issues/new/choose" title="Open Android Issue"><img src="https://img.shields.io/github/issues/DP-3T/documents/android-app.svg?style=flat-square"></a>  |
| **Backend Issue**    | <a href="https://github.com/corona-warn-app/cwa-server/issues/new/choose" title="Open Backend Issue"><img src="https://img.shields.io/github/issues/DP-3T/documents/backend.svg?style=flat-square"></a>  |
| **Other Requests**    | <a href="mailto:corona-warn-app.opensource@sap.com" title="Email CWD Team"><img src="https://img.shields.io/badge/email-CWD%20team-green?logo=mail.ru&style=flat-square&logoColor=white"></a>   |

## Contributing

Contributions and feedback are encouraged and always welcome. Please see our [Contribution Guidelines](./CONTRIBUTING.md) for details on how to contribute, the project structure and additional details you need to know to work with us. By participating in this project, you agree to abide by its [Code of Conduct](./CODE_OF_CONDUCT.md).

#### SwiftLint

This project uses [SwiftLint](https://github.com/realm/SwiftLint) to ensure a unified code style. The linter is run on every build and shows all warnings and error within Xcode's Issue Navigator.

Please ensure you have installed SwiftLint when working on this project and fix any warnings or error before committing your changes.

Use `brew install swiftlint` to install SwiftLint or download it manually from https://github.com/realm/SwiftLint. When not installed a warning will be triggered during build.

## Contributors

The German government has asked SAP and Deutsche Telekom to develop the Corona-Warn-App. Deutsche Telekom is providing the infrastructure technology and will operate and run the backend for the app in a safe, scalable, and stable manner. SAP is responsible for the development of the app development and the exposure notification backend. Therefore, development teams of SAP and T-Systems are contributing to this project. At the same time, our commitment to open source means that we are enabling -and encouraging- all interested parties to contribute and become part of its developer community.

## Repositories

| Repository          | Description                                                           |
| ------------------- | --------------------------------------------------------------------- |
| [cwa-documentation] | Project overview, general documentation, and white papers.            |
| [cwa-app-ios]       | Native iOS app using the Apple/Google exposure notification API.      |
| [cwa-app-android]   | Native Android app using the Apple/Google exposure notification API.  |
| [cwa-server]        | Backend implementation for the Apple/Google exposure notification API.|

[cwa-documentation]: https://github.com/corona-warn-app/cwa-documentation
[cwa-app-ios]: https://github.com/corona-warn-app/cwa-app-ios
[cwa-app-android]: https://github.com/corona-warn-app/cwa-app-android
[cwa-server]: https://github.com/corona-warn-app/cwa-server

---

This project is licensed under the **Apache-2.0** license. For more information, see the [LICENSE](./LICENSE) file.