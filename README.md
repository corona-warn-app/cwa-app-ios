<h1 align="center">
    Corona Warn App - iOS
</h1>

<p align="center">
    <a href="https://github.com/corona-warn-app/cwa-app-ios/commits/" title="Last Commit"><img src="https://img.shields.io/github/last-commit/corona-warn-app/cwa-app-ios?style=flat"></a>
    <a href="https://github.com/corona-warn-app/cwa-app-ios/issues" title="Open Issues"><img src="https://img.shields.io/github/issues/corona-warn-app/cwa-app-ios?style=flat"></a>
    <a href="https://circleci.com/gh/corona-warn-app/cwa-app-ios" title="Build Status"><img src="https://circleci.com/gh/corona-warn-app/cwa-app-ios.png?circle-token=656940b0df758209128b0d782c5f8885ddceb7a8&style=shield"></a>
    <a href="./LICENSE" title="License"><img src="https://img.shields.io/badge/License-Apache%202.0-green.svg"></a>
</p>

<p align="center">
  <a href="#development">Development</a> •
  <a href="#architecture--documentation">Documentation</a> •
  <a href="#how-to-contribute">Contribute</a> •
  <a href="#support--feedback">Support</a> •
  <a href="https://github.com/corona-warn-app/cwa-app-ios/releases">Changelog</a> •
  <a href="#licensing">Licensing</a>
</p>

The goal of this project is to develop the official Corona-Warn-App for Germany based on the exposure notification API from [Apple](https://www.apple.com/covid19/contacttracing/) and [Google](https://www.google.com/covid19/exposurenotifications/). The apps (for both iOS and Android) use Bluetooth technology to exchange anonymous encrypted data with other mobile phones (on which the app is also installed) in the vicinity of an app user's phone. The data is stored locally on each user's device, preventing authorities or other parties from accessing or controlling the data. This repository contains the **native iOS implementation** of the Corona-Warn-App. This implementation is still a **work in progress**, and the code it contains is currently alpha-quality code.

![Figure 1: UI Screens for Apple iOS](https://github.com/corona-warn-app/cwa-documentation/blob/master/images/ui_screens/ui_screens_ios.png "Figure 1: UI Screens for Apple iOS")

## Development

### Setup

1. Install Xcode 11.5 or higher
2. Select the right app scheme.

   We added the schema `ENACommunity` to our project which should enable third party developers to run and test the code. This schema uses a mocked implementation of `ExposureManager` in `SceneDelegate` and injects it into the application.

3. Set the user-defined variable to your development team

   In [project.pbxproj](./src/xcode/ENA/ENA.xcodeproj/project.pbxproj), set IPHONE_APP_DEV_TEAM to your development team
4. Install SwiftLint

   ```console
   brew install swiftlint
   ```

5. (Optional) Set up fastlane:
   Make sure you have the latest version of the Xcode command line tools installed:

   ```console
   xcode-select --install
   ```
   Install _fastlane_ using
   ```console
   [sudo] gem install fastlane -NV
   [sudo] gem install xcov
   ```
   or alternatively using `brew cask install fastlane`


### Build

After setting up your environment as stated in [Setup](#Setup), you should be able to build the app using the scheme `ENACommunity`.

If you want to use fastlane instead, you can do so by running the following commands:

```console
cd src/xcode && fastlane build_community
cd src/xcode && fastlane test
```

### Run

1. Run the server locally

   If you have Docker installed locally, the overall cwa-server setup can be easily built and run (incl. dependencies) by 'docker-compose up'. More information at: https://github.com/corona-warn-app/cwa-server
2. Configure the URL scheme
  * On your device, store a deep link that has the following structure:
    `corona-warn-app://configure?distributionBaseURL=https://fix.me/&submissionBaseURL=https://fix.me&verificationBaseURL=https://fix.me`
  * Tap on the link and then relaunch the app because the changes will only be effective in a new session. You can validate the configuration in the developer menu (triple-tap somewhere in the homescreen and click on the settings icon in the toolbar).

## Architecture & Documentation

The full documentation for the Corona-Warn-App is in the [cwa-documentation](https://github.com/corona-warn-app/cwa-documentation) repository. The documentation repository contains technical documents, architecture information, UI/UX specifications, and whitepapers related to this implementation.

## Support & Feedback

The following channels are available for discussions, feedback, and support requests:

| Type                     | Channel                                                |
| ------------------------ | ------------------------------------------------------ |
| **General Discussion**   | <a href="https://github.com/corona-warn-app/cwa-documentation/issues/new/choose" title="General Discussion"><img src="https://img.shields.io/github/issues/corona-warn-app/cwa-documentation/question.svg?style=flat-square"></a> </a>   |
| **Concept Feedback**    | <a href="https://github.com/corona-warn-app/cwa-documentation/issues/new/choose" title="Open Concept Feedback"><img src="https://img.shields.io/github/issues/corona-warn-app/cwa-documentation/architecture.svg?style=flat-square"></a>  |
| **iOS App Issue**    | <a href="https://github.com/corona-warn-app/cwa-app-ios/issues/new/choose" title="Open iOS Suggestion"><img src="https://img.shields.io/github/issues/corona-warn-app/cwa-app-ios?style=flat-square"></a>  |
| **Backend Issue**    | <a href="https://github.com/corona-warn-app/cwa-server/issues/new/choose" title="Open Backend Issue"><img src="https://img.shields.io/github/issues/corona-warn-app/cwa-server?style=flat-square"></a>  |
| **Other Requests**    | <a href="mailto:corona-warn-app.opensource@sap.com" title="Email CWA Team"><img src="https://img.shields.io/badge/email-CWA%20team-green?logo=mail.ru&style=flat-square&logoColor=white"></a>   |

## How to Contribute

Contribution and feedback are encouraged and always welcome. For more information about how to contribute, the project structure, as well as additional contribution information, see our [Contribution Guidelines](./CONTRIBUTING.md). By participating in this project, you agree to abide by its [Code of Conduct](./CODE_OF_CONDUCT.md) at all times.

#### SwiftLint

This project uses [SwiftLint](https://github.com/realm/SwiftLint) to ensure a unified code style. The linter is run on every build and shows all warnings and error within Xcode's Issue Navigator.

Please ensure you have installed SwiftLint when working on this project and fix any warnings or error before committing your changes.

Use `brew install swiftlint` to install SwiftLint or download it manually from https://github.com/realm/SwiftLint. When not installed a warning will be triggered during build.

## Contributors

The German government has asked SAP and Deutsche Telekom to develop the Corona-Warn-App for Germany as open source software. Deutsche Telekom is providing the network and mobile technology and will operate and run the backend for the app in a safe, scalable and stable manner. SAP is responsible for the app development, its framework and the underlying platform. Therefore, development teams of SAP and Deutsche Telekom are contributing to this project. At the same time our commitment to open source means that we are enabling -in fact encouraging- all interested parties to contribute and become part of its developer community.

## Repositories

| Repository          | Description                                                           |
| ------------------- | --------------------------------------------------------------------- |
| [cwa-documentation] | Project overview, general documentation, and white papers.            |
| [cwa-app-ios]       | Native iOS app using the Apple/Google exposure notification API.      |
| [cwa-app-android]   | Native Android app using the Apple/Google exposure notification API.  |
| [cwa-server]        | Backend implementation for the Apple/Google exposure notification API.|
| [cwa-verification-server] | Backend implementation of the verification process. |

[cwa-verification-server]: https://github.com/corona-warn-app/cwa-verification-server
[cwa-documentation]: https://github.com/corona-warn-app/cwa-documentation
[cwa-app-ios]: https://github.com/corona-warn-app/cwa-app-ios
[cwa-app-android]: https://github.com/corona-warn-app/cwa-app-android
[cwa-server]: https://github.com/corona-warn-app/cwa-server

## Licensing

Copyright (c) 2020 SAP SE or an SAP affiliate company.

Licensed under the **Apache License, Version 2.0** (the "License"); you may not use this file except in compliance with the License.

You may obtain a copy of the License at https://www.apache.org/licenses/LICENSE-2.0.

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the [LICENSE](./LICENSE) for the specific language governing permissions and limitations under the License.
