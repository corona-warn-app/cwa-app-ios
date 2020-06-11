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

class DynamicTableViewControllerRowsTests: XCTestCase {
	
	var sut: DynamicTableViewController!
	var window: UIWindow!
	
	override func setUpWithError() throws {
		// The fake storyboard is needed here to instantiate an instance of
		// DynamicTableViewController like it will be done in the real app.
		// Without that, the tableView property doesn't get assign properly.
		let testBundle = Bundle(for: DynamicTableViewControllerRowsTests.self)
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
		
		window = UIWindow(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
		window.makeKeyAndVisible()
	}
	
	override func tearDownWithError() throws {
		sut = nil
		window = nil
	}
}

// MARK: Rows
extension DynamicTableViewControllerRowsTests {
	func testHeightForRow_returnsAutomaticDimension() {
		let section = DynamicSection.section(cells: [.body(text: "Foo", accessibilityIdentifier: "Foo")])
		sut.dynamicTableViewModel = DynamicTableViewModel([section])

		let indexPath = IndexPath(row: 0, section: 0)
		let height = sut.tableView.delegate?.tableView?(sut.tableView, heightForRowAt: indexPath)
		
		XCTAssertEqual(height, UITableView.automaticDimension)
	}
	
	func testHeightForRow_whenSectionIsHidden_returnsLeastNonzeroMagnitude() {
		let section = DynamicSection.section(isHidden: { _ in return true }, cells: [.body(text: "Foo", accessibilityIdentifier: "Foo")])
		sut.dynamicTableViewModel = DynamicTableViewModel([section])

		let indexPath = IndexPath(row: 0, section: 0)
		let height = sut.tableView.delegate?.tableView?(sut.tableView, heightForRowAt: indexPath)
		
		XCTAssertEqual(height, .leastNonzeroMagnitude)
	}
	
	func testCellForRowAt_configuresCell() {
		let expectedText = "Foo"
		let section = DynamicSection.section(cells: [.body(text: expectedText, accessibilityIdentifier: "Foo")])
		sut.dynamicTableViewModel = DynamicTableViewModel([section])
		// Set as root of a window with non-zero frame because otherwise cellForRow returns nil
		window.rootViewController = sut
		
		let indexPath = IndexPath(row: 0, section: 0)
		let cell = sut.tableView.cellForRow(at: indexPath)
		
		XCTAssertEqual(cell?.textLabel?.text, expectedText)
	}
	
	func testCellForRowAt_whenSectionIsHidden_returnsIsPlainUITableViewCell() {
		let section = DynamicSection.section(isHidden: { _ in return true }, cells: [.body(text: "Foo", accessibilityIdentifier: "Foo")])
		sut.dynamicTableViewModel = DynamicTableViewModel([section])
		// Set as root of a window with non-zero frame because otherwise cellForRow returns nil
		window.rootViewController = sut
		
		let indexPath = IndexPath(row: 0, section: 0)
		let cell = sut.tableView.cellForRow(at: indexPath)
		
		guard let unwrappedCell = cell else {
			return XCTFail("cell should not be nil")
		}
		XCTAssert(type(of: unwrappedCell) == UITableViewCell.self, "Got \(type(of: unwrappedCell)), expected \(UITableViewCell.self)")
	}
	
	func testCellForRowAt_whenSectionHasSeparators_addsTopSeparatorToFirstCell() {
		let cells: [DynamicCell] = [
			.body(text: "Foo", accessibilityIdentifier: "Foo"),
			.body(text: "Bar", accessibilityIdentifier: "Bar")
		]
		let section = DynamicSection.section(separators: true, cells: cells)
		sut.dynamicTableViewModel = DynamicTableViewModel([section])
		// Set as root of a window with non-zero frame because otherwise cellForRow returns nil
		window.rootViewController = sut

		let indexPath = IndexPath(row: 0, section: 0)
		let cell = sut.tableView.cellForRow(at: indexPath)
		
		guard let unwrappedCell = cell else {
			return XCTFail("cell should not be nil")
		}
		let topSeparator = unwrappedCell.contentView.viewWithTag(100_001)
		let topSeparatorIsSubview = topSeparator?.isDescendant(of: unwrappedCell)
		XCTAssertEqual(topSeparatorIsSubview, true)
	}
	
	func testCellForRowAt_whenSectionHasSeparators_NotAddsTopSeparatorToSecondCell() {
		let cells: [DynamicCell] = [
			.body(text: "Foo", accessibilityIdentifier: "Foo"),
			.body(text: "Bar", accessibilityIdentifier: "Bar")
		]
		let section = DynamicSection.section(separators: true, cells: cells)
		sut.dynamicTableViewModel = DynamicTableViewModel([section])
		// Set as root of a window with non-zero frame because otherwise cellForRow returns nil
		window.rootViewController = sut

		let indexPath = IndexPath(row: 1, section: 0)
		let cell = sut.tableView.cellForRow(at: indexPath)
		
		guard let unwrappedCell = cell else {
			return XCTFail("cell should not be nil")
		}
		let topSeparator = unwrappedCell.contentView.viewWithTag(100_001)
		XCTAssertNil(topSeparator)
	}
	
	func testCellForRowAt_whenSectionHasSeparators_addsBottomSeparatorToLastCell() {
		let cells: [DynamicCell] = [
			.body(text: "Foo", accessibilityIdentifier: "Foo"),
			.body(text: "Bar", accessibilityIdentifier: "Bar")
		]
		let section = DynamicSection.section(separators: true, cells: cells)
		sut.dynamicTableViewModel = DynamicTableViewModel([section])
		// Set as root of a window with non-zero frame because otherwise cellForRow returns nil
		window.rootViewController = sut

		let rowOfLastCell = cells.count - 1
		let indexPath = IndexPath(row: rowOfLastCell, section: 0)
		let cell = sut.tableView.cellForRow(at: indexPath)
		
		guard let unwrappedCell = cell else {
			return XCTFail("cell should not be nil")
		}
		let bottomSeparator = unwrappedCell.contentView.viewWithTag(100_002)
		let isSubview = bottomSeparator?.isDescendant(of: unwrappedCell)
		XCTAssertEqual(isSubview, true)
	}
	
	func testCellForRowAt_whenSectionHasSeparators_notAddsBottomSeparatorToFirstCell() {
		let cells: [DynamicCell] = [
			.body(text: "Foo", accessibilityIdentifier: "Foo"),
			.body(text: "Bar", accessibilityIdentifier: "Bar")
		]
		let section = DynamicSection.section(separators: true, cells: cells)
		sut.dynamicTableViewModel = DynamicTableViewModel([section])
		// Set as root of a window with non-zero frame because otherwise cellForRow returns nil
		window.rootViewController = sut

		let indexPath = IndexPath(row: 0, section: 0)
		let cell = sut.tableView.cellForRow(at: indexPath)
		
		guard let unwrappedCell = cell else {
			return XCTFail("cell should not be nil")
		}
		let bottomSeparator = unwrappedCell.contentView.viewWithTag(100_002)
		XCTAssertNil(bottomSeparator)
	}
	
	func testCellForRowAt_whenSectionHasSeparators_addsInsetSeparatorToFirstCell() {
		let cells: [DynamicCell] = [
			.body(text: "Foo", accessibilityIdentifier: "Foo"),
			.body(text: "Bar", accessibilityIdentifier: "Bar"),
			.body(text: "Baz", accessibilityIdentifier: "Baz")
		]
		let section = DynamicSection.section(separators: true, cells: cells)
		sut.dynamicTableViewModel = DynamicTableViewModel([section])
		// Set as root of a window with non-zero frame because otherwise cellForRow returns nil
		window.rootViewController = sut

		let indexPath = IndexPath(row: 0, section: 0)
		let cell = sut.tableView.cellForRow(at: indexPath)
		
		guard let unwrappedCell = cell else {
			return XCTFail("cell should not be nil")
		}
		let insetSeparator = unwrappedCell.contentView.viewWithTag(100_003)
		let isSubview = insetSeparator?.isDescendant(of: unwrappedCell)
		XCTAssertEqual(isSubview, true)
	}
	
	func testCellForRowAt_whenSectionHasSeparators_addsInsetSeparatorToIntermediateCells() {
		let cells: [DynamicCell] = [
			.body(text: "Foo", accessibilityIdentifier: "Foo"),
			.body(text: "Bar", accessibilityIdentifier: "Bar"),
			.body(text: "Baz", accessibilityIdentifier: "Baz")
		]
		let section = DynamicSection.section(separators: true, cells: cells)
		sut.dynamicTableViewModel = DynamicTableViewModel([section])
		// Set as root of a window with non-zero frame because otherwise cellForRow returns nil
		window.rootViewController = sut

		let rowOfSecondToLastCell = cells.count - 2
		let indexPath = IndexPath(row: rowOfSecondToLastCell, section: 0)
		let cell = sut.tableView.cellForRow(at: indexPath)
		
		guard let unwrappedCell = cell else {
			return XCTFail("cell should not be nil")
		}
		let insetSeparator = unwrappedCell.contentView.viewWithTag(100_003)
		let isSubview = insetSeparator?.isDescendant(of: unwrappedCell)
		XCTAssertEqual(isSubview, true)
	}
	
	func testCellForRowAt_whenSectionHasSeparators_notAddsInsetSeparatorToLastCell() {
		let cells: [DynamicCell] = [
			.body(text: "Foo", accessibilityIdentifier: "Foo"),
			.body(text: "Bar", accessibilityIdentifier: "Bar"),
			.body(text: "Baz", accessibilityIdentifier: "Baz")
		]
		let section = DynamicSection.section(separators: true, cells: cells)
		sut.dynamicTableViewModel = DynamicTableViewModel([section])
		// Set as root of a window with non-zero frame because otherwise cellForRow returns nil
		window.rootViewController = sut

		let rowOfLastCell = cells.count - 1
		let indexPath = IndexPath(row: rowOfLastCell, section: 0)
		let cell = sut.tableView.cellForRow(at: indexPath)
		
		guard let unwrappedCell = cell else {
			return XCTFail("cell should not be nil")
		}
		let insetSeparator = unwrappedCell.contentView.viewWithTag(100_003)
		XCTAssertNil(insetSeparator)
	}
}
