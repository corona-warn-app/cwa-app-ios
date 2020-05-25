//
//  Logger.swift
//  ENA
//
//  Created by Zildzic, Adnan on 03.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation

let appLogger = Logger()

func log(message: String, level: LogLevel = .info, file: String = #file, line: UInt = #line, function: String = #function) {
    NSLog("%@", message)
}

func logError(message: String, level: LogLevel = .error, file: String = #file, line: UInt = #line, function: String = #function) {
    NSLog("%@", message)
}

class Logger {
    func log(message: String, level: LogLevel = .info, file: String, line: UInt, function: String) {
    }

    func getLoggedData() -> Data? {
        Data()
    }
}

enum LogLevel {
    case info
    case warning
    case error
}
