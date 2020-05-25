//
//  BackendMode.swift
//  ENA
//
//  Created by Kienle, Christian on 17.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation

/// Describes the mode of operation used by the app when talking to the backend.
///
/// The app has two main modes of operation:
///
/// 1. `mock`: In this mode the app talks to a 100% mocked backend that does not even require an HTTP connection.
/// 2. `https`: In this mode the app us using an `URLSession` to talk to the backend.
///
/// As a developer you can override the client mode by setting the environment variable `CWA_CLIENT_MODE` either to `mock` or `https`. In `APP_STORE` builds this feature is disabled.
enum ClientMode: String {
    case mock = "mock"
    case https = "https"

    static func from(environment: [String: String]) -> ClientMode {
        // We disable mocking
        .https
//        #if APP_STORE
//        return .https
//        #endif
//        let defaultMode = ClientMode.https
//        let value = environment["CWA_CLIENT_MODE"] ?? defaultMode.rawValue
//        return ClientMode(rawValue: value) ?? defaultMode
    }

    static func from(processInfo: ProcessInfo) -> ClientMode {
        from(environment: processInfo.environment)
    }

    static let `default` = ClientMode.from(processInfo: .processInfo)
}
