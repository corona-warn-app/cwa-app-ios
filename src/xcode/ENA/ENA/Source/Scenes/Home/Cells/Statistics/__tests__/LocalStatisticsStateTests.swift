////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class LocalStatisticsStateTests: XCTestCase {

    func testState() throws {
		// empty state
        let store = MockTestStore()
		XCTAssertEqual(LocalStatisticsState.with(store), .empty)

		// partially filled
		store.selectedLocalStatisticsDistricts = [
			LocalStatisticsDistrict(federalState: .berlin, districtName: "", districtId: "")
		]
		XCTAssertEqual(LocalStatisticsState.with(store), .notYetFull)

		// full
		store.selectedLocalStatisticsDistricts = [
			LocalStatisticsDistrict(federalState: .berlin, districtName: "", districtId: ""),
			LocalStatisticsDistrict(federalState: .berlin, districtName: "", districtId: ""),
			LocalStatisticsDistrict(federalState: .berlin, districtName: "", districtId: ""),
			LocalStatisticsDistrict(federalState: .berlin, districtName: "", districtId: ""),
			LocalStatisticsDistrict(federalState: .berlin, districtName: "", districtId: "")
		]
		XCTAssertEqual(LocalStatisticsState.with(store), .full)

		// over threshold
		store.selectedLocalStatisticsDistricts.append(
			LocalStatisticsDistrict(federalState: .berlin, districtName: "", districtId: ""))
		XCTAssertEqual(LocalStatisticsState.with(store), .full)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
