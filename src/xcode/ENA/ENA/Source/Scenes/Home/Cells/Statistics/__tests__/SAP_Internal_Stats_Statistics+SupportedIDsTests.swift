//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
@testable import ENA

class SAP_Internal_Stats_StatisticsSupportedIDsTests: XCTestCase {

	func testSupportedIDs() {
		var statistics = SAP_Internal_Stats_Statistics()
		statistics.cardIDSequence = [0, 8, 2, 7, 3, 6, 1, 4, 5, 9, 999, -1]

		XCTAssertEqual(statistics.supportedCardIDSequence, [2, 3, 1, 4])
	}

}
