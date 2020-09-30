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

class DeltaOnboardingViewControllerTests: XCTestCase {

	private func createVC() -> DeltaOnboardingV15ViewController {
		AppStoryboard.onboarding.initiate(viewControllerType: DeltaOnboardingV15ViewController.self) { coder -> UIViewController? in
			DeltaOnboardingV15ViewController(
				coder: coder,
				supportedCountries: [ Country.defaultCountry() ]
			)
		}
	}
	
	private func createVCWithoutCountries() -> DeltaOnboardingV15ViewController {
		AppStoryboard.onboarding.initiate(viewControllerType: DeltaOnboardingV15ViewController.self) { coder -> UIViewController? in
			DeltaOnboardingV15ViewController(
				coder: coder,
				supportedCountries: []
			)
		}
	}
	
	func testCellsInSection0() {
		let vc = createVC()
		vc.loadViewIfNeeded()

		let section = vc.dynamicTableViewModel.section(0)
		let cells = section.cells
		XCTAssertEqual(cells.count, 4)

		
		let firstItem = cells[0]
		var id = firstItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "labelCell")

		let secondItem = cells[1]
		id = secondItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "labelCell")

		let thirdItem = cells[2]
		id = thirdItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "labelCell")

		let fourthItem = cells[3]
		id = fourthItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "spaceCell")
	}
	
	func testCellsInSection1WithCountries() {
		let vc = createVC()
		vc.loadViewIfNeeded()

		let section = vc.dynamicTableViewModel.section(1)
		let cells = section.cells
		XCTAssertEqual(cells.count, 1)
		
		let firstItem = cells[0]
		let id = firstItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "labelCell")
		
	}
	
	func testCellsInSection1WithoutCountries() {
		let vc = createVCWithoutCountries()
		vc.loadViewIfNeeded()

		let section = vc.dynamicTableViewModel.section(1)
		let cells = section.cells
		XCTAssertEqual(cells.count, 2)
		
		let firstItem = cells[0]
		var id = firstItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "labelCell")
		
		let secondItem = cells[1]
		id = secondItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "labelCell")
	}
	
	func testCellsInSection2WithCountries() {
		let vc = createVC()
		vc.loadViewIfNeeded()

		let section = vc.dynamicTableViewModel.section(2)
		let cells = section.cells
		XCTAssertEqual(cells.count, 1)
		
		let firstItem = cells[0]
		let id = firstItem.cellReuseIdentifier
		XCTAssertEqual(id.rawValue, "iconCell")
		
	}
	
	func testCellsInSection2WithoutCountries() {
		let vc = createVCWithoutCountries()
		vc.loadViewIfNeeded()

		let section = vc.dynamicTableViewModel.section(2)
		let cells = section.cells
		XCTAssertEqual(cells.count, 0)
	}
}
