//
// Corona-Warn-App
//
// SAP SE and all other contributors
// copyright owners license this file to you under the Apache
// License, Version 2.0 (the "License"); you may not use this
// file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.
//

import Foundation
import XCTest
@testable import ENA

class ExposureSubmissionWarnOthersViewControllerTests: XCTestCase {
	
	private var store: SecureStore!
	
	override func setUpWithError() throws {
		store = try SecureStore(at: URL(staticString: ":memory:"), key: "123456", serverEnvironment: ServerEnvironment())
	}

	private func createVC() -> ExposureSubmissionWarnOthersViewController {
		
		AppStoryboard.exposureSubmission.initiate(viewControllerType: ExposureSubmissionWarnOthersViewController.self) { coder -> UIViewController? in
			ExposureSubmissionWarnOthersViewController(
				coder: coder,
				supportedCountries: ["DE", "IT", "ES", "NL", "CZ", "AT", "DK", "IE", "LV", "EE"].compactMap { Country(countryCode: $0) }, warnOthers: WarnOthers(store: self.store),
				onPrimaryButtonTap: { _ in }
			)
		}
	}

	func testCellsInSection0() {
		let vc = createVC()
		_ = vc.view

		let section = vc.dynamicTableViewModel.section(0)
		let cells = section.cells
		XCTAssertEqual(cells.count, 5)

		let firstItem = cells[0]
		var id = firstItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "labelCell")

		let secondItem = cells[1]
		id = secondItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "labelCell")

		let thirdItem = cells[2]
		id = thirdItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "spaceCell")

		let fourthItem = cells[3]
		id = fourthItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "labelCell")

  		let fifthItem = cells[4]
  		id = fifthItem.cellReuseIdentifier
  		XCTAssertEqual(id.rawValue, "spaceCell")
	}

	func testCellsInSection1() {
		let vc = createVC()
		_ = vc.view

		let section = vc.dynamicTableViewModel.section(1)
		let cells = section.cells
		XCTAssertEqual(cells.count, 10)

		let firstItem = cells[0]
		var id = firstItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "iconCell")

		let secondItem = cells[1]
		id = secondItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "iconCell")

		let thirdItem = cells[2]
		id = thirdItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "iconCell")

		let fourthItem = cells[3]
		id = fourthItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "iconCell")

		let fifthItem = cells[4]
		id = fifthItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "iconCell")

		let sixthItem = cells[5]
		id = sixthItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "iconCell")

		let seventhItem = cells[6]
		id = seventhItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "iconCell")

		let eighthItem = cells[7]
		id = eighthItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "iconCell")

		let ninthItem = cells[8]
		id = ninthItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "iconCell")

		let tenthItem = cells[9]
		id = tenthItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "iconCell")
	}

	func testCellsInSection2() {
		let vc = createVC()
		_ = vc.view

		let section = vc.dynamicTableViewModel.section(2)
		let cells = section.cells
		XCTAssertEqual(cells.count, 3)

		let firstItem = cells[0]
		var id = firstItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "spaceCell")

		let secondItem = cells[1]
		id = secondItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "roundedCell")

		let thirdItem = cells[2]
		id = thirdItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "roundedCell")
	}

}
