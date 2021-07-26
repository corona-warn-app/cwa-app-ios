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
		store.selectedLocalStatisticsRegions = [
			LocalStatisticsRegion(federalState: .berlin, name: "", id: "", regionType: .federalState)
		]
		XCTAssertEqual(LocalStatisticsState.with(store), .notYetFull)

		// full
		store.selectedLocalStatisticsRegions = [
			LocalStatisticsRegion(federalState: .berlin, name: "", id: "", regionType: .federalState),
			LocalStatisticsRegion(federalState: .berlin, name: "", id: "", regionType: .federalState),
			LocalStatisticsRegion(federalState: .berlin, name: "", id: "", regionType: .federalState),
			LocalStatisticsRegion(federalState: .berlin, name: "", id: "", regionType: .federalState),
			LocalStatisticsRegion(federalState: .berlin, name: "", id: "", regionType: .federalState)
		]
		XCTAssertEqual(LocalStatisticsState.with(store), .full)

		// over threshold
		store.selectedLocalStatisticsRegions.append(
			LocalStatisticsRegion(federalState: .berlin, name: "", id: "", regionType: .federalState))
		XCTAssertEqual(LocalStatisticsState.with(store), .full)
    }

}
