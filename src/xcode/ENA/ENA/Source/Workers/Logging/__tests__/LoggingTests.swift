//
// 🦠 Corona-Warn-App
//

import Foundation
import os.log

import XCTest
@testable import ENA

class LoggingTests: CWATestCase {
	func testMockLogger() {
		let expectedLogMessages = [
			MockLogger.Item(type: "Info", message: "RiskProvider: soft rate limit is stricter than effective rate limit"),
			MockLogger.Item(type: "Debug", message: "RiskProvider: soft rate limit is in synch with effective rate limit"),
			MockLogger.Item(type: "Warning", message: "RiskProvider: soft rate limit is too strict - it would have blocked this successful exposure detection"),
			MockLogger.Item(type: "Error", message: "Fatal error - you need to reinstall cwa")
		]
		let mock = MockLogger()

		Log.info("RiskProvider: soft rate limit is stricter than effective rate limit", log: .riskDetection, logger: mock)
		Log.debug("RiskProvider: soft rate limit is in synch with effective rate limit", log: .riskDetection, logger: mock)
		Log.warning("RiskProvider: soft rate limit is too strict - it would have blocked this successful exposure detection", log: .riskDetection, logger: mock)
		Log.error("Fatal error - you need to reinstall cwa", log: .riskDetection, logger: mock)

		XCTAssertEqual(mock.data, expectedLogMessages)
	}
}

class MockLogger: Logging {
	init() {
		self.data = [Item]()
	}
	
	func debug(_ message: String, log: OSLog, file: String, line: Int, function: String) {
		data.append(Item(type: OSLogType.debug.title, message: message))
	}
	
	func info(_ message: String, log: OSLog, file: String, line: Int, function: String) {
		data.append(Item(type: OSLogType.info.title, message: message))
	}
	
	func warning(_ message: String, log: OSLog, file: String, line: Int, function: String) {
		data.append(Item(type: OSLogType.default.title, message: message))
	}
	
	func error(_ message: String, log: OSLog, error: Error?, file: String, line: Int, function: String) {
		data.append(Item(type: OSLogType.error.title, message: message))
	}

	struct Item: Equatable {
		let type: String
		let message: String
	}
	
	var data: [Item]
}
