//
// Corona-Warn-App
//
// SAP SE and all other contributors /
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

import XCTest
@testable import ENA

class DynamicTableViewControllerRegisterCellsTests: XCTestCase {
	
	var sut: DynamicTableViewController!
	
	override func setUpWithError() throws {
		// The fake storyboard is needed here to instantiate an instance of
		// DynamicTableViewController like it will be done in the real app.
		// Without that, the tableView property doesn't get assign properly.
		let testBundle = Bundle(for: DynamicTableViewControllerRegisterCellsTests.self)
		let storyboardFake = UIStoryboard(name: "DynamicTableViewControllerFake", bundle: testBundle)
		// The force unwrap it used here because when the type doesn't match, a
		// crash immedeately informs about a problem in the test.
		guard let viewController = storyboardFake.instantiateViewController(identifier: "DynamicTableViewController") as? DynamicTableViewController
			else {
				XCTAssert(false, "Unable to instantiate DynamicTableViewController from DynamicTableViewControllerFake.storyboard")
				return
		}
		sut = viewController
		// trigger viewDidLoad
		sut.loadViewIfNeeded()
	}
	
	override func tearDownWithError() throws {
		sut = nil
	}
}

// MARK: - Register Cells
extension DynamicTableViewControllerRegisterCellsTests {
	
	func testViewDidLoad_registersDynamicTypeCell() {
		// setup view model
		let sections = [DynamicSection.section(cells: [.dynamicType(text: "Foo")])]
		sut.dynamicTableViewModel = DynamicTableViewModel(sections)
		
		// dequeue cell
		let reuseIdentifier = DynamicCell.CellReuseIdentifier.dynamicTypeLabel.rawValue
		let cell = sut.tableView.dequeueReusableCell(
			withIdentifier: reuseIdentifier,
			for: IndexPath(row: 0, section: 0)
		)
		// assert type
		XCTAssertTrue(cell is DynamicTypeTableViewCell)
	}
	
	func testViewDidLoad_registersSpaceCell() {
		// setup view model
		let sections = [DynamicSection.section(cells: [.space(height: 1)])]
		sut.dynamicTableViewModel = DynamicTableViewModel(sections)
		
		// dequeue cell
		let reuseIdentifier = DynamicCell.CellReuseIdentifier.space.rawValue
		let cell = sut.tableView.dequeueReusableCell(
			withIdentifier: reuseIdentifier,
			for: IndexPath(row: 0, section: 0)
		)
		// assert type
		XCTAssertTrue(cell is DynamicTableViewSpaceCell)
	}
	
	func testViewDidLoad_registersIconCell() {
		let dynamicCell = DynamicCell.icon(nil, text: "Foo", tintColor: .green, action: .none)
		let sections = [DynamicSection.section(cells: [dynamicCell])]
		sut.dynamicTableViewModel = DynamicTableViewModel(sections)

		// dequeue cell
		let reuseIdentifier = DynamicCell.CellReuseIdentifier.icon.rawValue
		let cell = sut.tableView.dequeueReusableCell(
			withIdentifier: reuseIdentifier,
			for: IndexPath(row: 0, section: 0)
		)
		// assert type
		XCTAssertTrue(cell is DynamicTableViewIconCell)
	}

	func testViewDidLoad_registersTextViewCell() {
		// setup view model
		let sections = [DynamicSection.section(cells: [.dynamicType(text: "Foo")])]
		sut.dynamicTableViewModel = DynamicTableViewModel(sections)

		// dequeue cell
		let reuseIdentifier = DynamicCell.CellReuseIdentifier.dynamicTypeTextView.rawValue
		let cell = sut.tableView.dequeueReusableCell(
			withIdentifier: reuseIdentifier,
			for: IndexPath(row: 0, section: 0)
		)
		// assert type
		XCTAssertTrue(cell is DynamicTableViewTextViewCell)
	}
}
