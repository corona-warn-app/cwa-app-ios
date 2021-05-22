//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
@testable import ENA
import OpenCombine

class DiaryEditEntriesCellModelTest: XCTestCase {

	func testContactPersonText() throws {
		let name = "Martin Hermes"
		let viewModel = DiaryEditEntriesCellModel(
			entry: .contactPerson(
				DiaryContactPerson(
					id: 0,
					name: name
				)
			)
		)

		XCTAssertEqual(viewModel.text, name)
	}

	func testLocationText() throws {
		let name = "Frittenwerk"
		let viewModel = DiaryEditEntriesCellModel(
			entry: .location(
				DiaryLocation(
					id: 0,
					name: name,
					traceLocationId: nil
				)
			)
		)

		XCTAssertEqual(viewModel.text, name)
	}
	
}
