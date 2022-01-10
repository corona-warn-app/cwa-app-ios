//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
@testable import ENA

class SAP_Internal_Stats_StatisticsSupportedIDsTests: CWATestCase {

	func testSupportedIDs() {
		var statistics = SAP_Internal_Stats_Statistics()
		statistics.cardIDSequence = [0, 10, 3, 6, 1, 4, 5, 9, 11, 7, 999, -1]

		XCTAssertEqual(statistics.supportedCardIDSequence, [10, 3, 6, 1, 4, 5, 9, 11, 7])
	}

}
