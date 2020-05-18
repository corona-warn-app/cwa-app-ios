//
//  Mode.swift
//  ENA
//
//  Created by Kienle, Christian on 13.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation

/// Represents the mode of the current execution.
enum Mode: String {
    case https = "https"
    case mock = "mock"

    static func from(environment: [String: String]) -> Mode {
        #if APP_STORE
            return Mode.production
        #endif
        
        let defaultMode: Mode = .https
        let value = environment["CW_MODE"] ?? defaultMode.rawValue
        return Mode(rawValue: value) ?? defaultMode
    }

    static func from(processInfo: ProcessInfo = .processInfo) -> Mode {
        return from(environment: processInfo.environment)
    }
}
