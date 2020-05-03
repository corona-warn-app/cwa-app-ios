//
//  Logger.swift
//  ENA
//
//  Created by Zildzic, Adnan on 03.05.20.
//  Copyright © 2020 SAP SE. All rights reserved.
//

import Foundation
import CocoaLumberjackSwift

let appLogger = Logger()

class Logger {
    init() {
        DDLog.add(createFileLogger())

        #if DEBUG
        DDLog.add(createConsoleLogger())
        #endif
    }

    public func log(message: String, level: LogLevel = .info, file: String = #file, line: UInt = #line, function: String = #function) {
        let message = DDLogMessage(message: message, level: mapLogLevel(level), flag: .info, context: 0, file: file, function: function, line: line, tag: nil, options: .dontCopyMessage, timestamp: nil)

        DDLog.log(asynchronous: true, message: message)
    }

    public func getLoggedData() -> Data? {
        var data = Data()

        guard let logFileManager = DDLog.allLoggers.compactMap({ $0 as? DDFileLogger }).first?.logFileManager else {
            return data
        }

        for path in logFileManager.sortedLogFilePaths {
            let url = URL(fileURLWithPath: path)

            if let fileData = try? Data(contentsOf: url) {
                data.append(fileData)
            }
        }

        return data
    }

    private func createFileLogger() -> DDFileLogger {
        let fileLogger = DDFileLogger()
        fileLogger.maximumFileSize = 1024 * 1024 // 1 MB
        fileLogger.logFileManager.maximumNumberOfLogFiles = 5

        return fileLogger
    }

    private func createConsoleLogger() -> DDOSLogger {
        return DDOSLogger.sharedInstance
    }

    private func mapLogLevel(_ logLevel: LogLevel) -> DDLogLevel {
        switch logLevel {
        case .info:
            return .info
        case .warning:
            return .warning
        case .error:
            return .error
        }
    }
}

enum LogLevel {
    case info
    case warning
    case error
}
