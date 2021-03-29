<h1 align="center">
    Corona Warn App - iOS
</h1>

<p align="center">
   <a href="https://github.com/corona-warn-app/cwa-app-ios/commits/" title="Last Commit"><img src="https://img.shields.io/github/last-commit/corona-warn-app/cwa-app-ios?style=flat"></a>
   <a href="https://github.com/corona-warn-app/cwa-app-ios/issues" title="Open Issues"><img src="https://img.shields.io/github/issues/corona-warn-app/cwa-app-ios?style=flat"></a>
   <a href="https://circleci.com/gh/corona-warn-app/cwa-app-ios" title="Build Status"><img src="https://circleci.com/gh/corona-warn-app/cwa-app-ios.png?circle-token=656940b0df758209128b0d782c5f8885ddceb7a8&style=shield"></a>
   <a href="https://sonarcloud.io/component_measures?id=corona-warn-app_cwa-app-ios&metric=Coverage&view=list" title="Coverage"><img src="https://sonarcloud.io/api/project_badges/measure?project=corona-warn-app_cwa-app-ios&metric=coverage"></a>
   <a href="./LICENSE" title="License"><img src="https://img.shields.io/badge/License-Apache%202.0-green.svg"></a>
   <a href="https://github-tools.github.io/github-release-notes/" title="Automated Release Notes"><img src="https://img.shields.io/badge/%F0%9F%A4%96-release%20notes-00B2EE.svg"></a>
   <a href="https://api.reuse.software/info/github.com/corona-warn-app/cwa-app-ios" title="REUSE Status"><img src="https://api.reuse.software/badge/github.com/corona-warn-app/cwa-app-ios"></a>      
</p>

<p align="center">
  <a href="#development">Development</a> •
  <a href="#architecture--documentation">Documentation</a> •
  <a href="#how-to-contribute">Contribute</a> •
  <a href="#support--feedback">Support</a> •
  <a href="https://github.com/corona-warn-app/cwa-app-ios/releases">Changelog</a> •
  <a href="#licensing">Licensing</a>
</p>

The goal of this project is to develop the official Corona-Warn-App for Germany based on the exposure notification API from [Apple](https://www.apple.com/covid19/contacttracing/) and [Google](https://www.google.com/covid19/exposurenotifications/). The apps (for both iOS and Android) use Bluetooth technology to exchange anonymous encrypted data with other mobile phones (on which the app is also installed) in the vicinity of an app user's phone. The data is stored locally on each user's device, preventing authorities or other parties from accessing or controlling the data. This repository contains the **native iOS implementation** of the Corona-Warn-App.
**Visit our [FAQ page](https://www.coronawarn.app/en/faq/) for more information and common issues.**

## Development

### Setup

1. Install Xcode 11.5 or higher
2. Select the right app scheme.

   We added the schema `ENACommunity` to our project which should enable third party developers to run and test the code. This schema uses a mocked implementation of `ExposureManager` in `SceneDelegate` and injects it into the application.

3. Set the user-defined variable to your development team

   In the [project.pbxproj](./src/xcode/ENA/ENA.xcodeproj/project.pbxproj) file, set IPHONE_APP_DEV_TEAM for the build setting `Community` to your development team
4. Install SwiftLint

   ```console
   brew install swiftlint
   ```

5. (Optional) Set up fastlane:
   Make sure you have the latest version of the Xcode command line tools installed:

   ```console
   xcode-select --install
   ```
   Install _fastlane_ using [Bundler](https://bundler.io/)
   ```console
   cd src/xcode && bundle install --path vendor/bundle
   ```

6. (Optional) Add code snippet to Xcode:
CodeSnipets are located inside the folder 'CodeSnippets'.
Copy MARKs.codesnippet  to Xcode UserData folder:
 ```console
 cp CodeSnippets/MARKs.codesnippet ~/Library/Developer/Xcode/UserData/CodeSnippets/
 ```

### Build

After setting up your environment as stated in [Setup](#Setup), you should be able to build the app using the scheme `ENACommunity`.

If you want to use fastlane instead, you can do so by running the following commands:

```console
cd src/xcode && bundle exec fastlane build_community
cd src/xcode && bundle exec fastlane test
```

## Architecture & Documentation

The full documentation for the Corona-Warn-App is in the [cwa-documentation](https://github.com/corona-warn-app/cwa-documentation) repository. The documentation repository contains technical documents, architecture information, UI/UX specifications, and whitepapers related to this implementation.

Automatically generated documentation of the source code can be found at [GitHub Pages](https://corona-warn-app.github.io/cwa-app-ios/index.html)

## Support & Feedback

The following channels are available for discussions, feedback, and support requests:

| Type                     | Channel                                                |
| ------------------------ | ------------------------------------------------------ |
| **General Discussion**   | <a href="https://github.com/corona-warn-app/cwa-documentation/issues/new/choose" title="General Discussion"><img src="https://img.shields.io/github/issues/corona-warn-app/cwa-documentation/question.svg?style=flat-square"></a> </a>   |
| **Feature Requests**    | <a href="https://github.com/corona-warn-app/cwa-wishlist/issues/new/choose" title="Create Feature Request"><img src="https://img.shields.io/github/issues/corona-warn-app/cwa-wishlist?style=flat-square"></a>  |
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

A list of all public repositories from the Corona-Warn-App can be found [here](https://github.com/corona-warn-app/cwa-documentation/blob/master/README.md#repositories).

## Licensing

Copyright (c) 2020-2021 SAP SE or an SAP affiliate company.

Licensed under the **Apache License, Version 2.0** (the "License"); you may not use this file except in compliance with the License.

You may obtain a copy of the License from [here](./LICENSE).

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the [LICENSE](./LICENSE) for the specific language governing permissions and limitations under the License.

Please see the [detailed licensing information](https://api.reuse.software/info/github.com/corona-warn-app/cwa-app-ios) via the [REUSE Tool](https://reuse.software/) for more details.
