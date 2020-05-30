# Architecture CWA Mobile Client - iOS

## Cover iOS special aspects
### used Frameworks
The latest UI technology for iOS is SwiftUI which was introduced at WWDC 2019. As it was only released one year ago, we choose the traditional and more mature UIKit to develop this app.
### major used libraries
#### swift-protobuf
Protocol Buffers is used as the data exchange format between backend and frontend. [swift-protobuf](https://github.com/apple/swift-protobuf) is chosen to parse the data from backend.
#### Reachability.swift
We use the [Reachability.swift](https://github.com/ashleymills/Reachability.swift) library to detect the connectivity of internet.
#### fmdb
[fmdb](https://github.com/ccgus/fmdb) helps us to simplify the interface to access the SQLite database.
#### ZIPFoundation
[ZIPFoundation](https://github.com/weichsel/ZIPFoundation) is used to extract zip file that is downloaded from backend.
#### SQLCipher
We leverages the [SQLCipher](https://github.com/sqlcipher/sqlcipher) to encrypt the SQLite database protecting the users' privacy.

### used implementation patterns
#### UI Patterns
In general, the App is built with MVC and MVVM pattern. As the code is still under construction. Depending on the complexity of project in the future, some other patterns might be applied.
#### Others
The [Exposure Notification Framework](https://developer.apple.com/documentation/exposurenotification) supports KVO, so we also use KVO to watch the state of some important properties.
### Storage
There're two different storages which are used in the project. The random generated key is stored in [Keychain Services](https://developer.apple.com/documentation/security/keychain_services), and the other information is stored in the SQLite database that is encrypted by the [SQLCipher](https://github.com/sqlcipher/sqlcipher).
### Encryption
We use the popular [SQLCipher](https://github.com/sqlcipher/sqlcipher) library to encrypt the SQLite database.
