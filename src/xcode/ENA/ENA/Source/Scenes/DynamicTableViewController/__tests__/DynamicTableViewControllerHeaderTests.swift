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

class DynamicTableViewControllerHeaderTests: XCTestCase {
	
	var sut: DynamicTableViewController!
	
	override func setUpWithError() throws {
		// The fake storyboard is needed here to instantiate an instance of
		// DynamicTableViewController like it will be done in the real app.
		// Without that, the tableView property doesn't get assign properly.
		let testBundle = Bundle(for: DynamicTableViewControllerHeaderTests.self)
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

// MARK: - Header
extension DynamicTableViewControllerHeaderTests {
	func testTitleForHeader_whenHeaderIsText_returnsHeaderText() {
		// set up view model
		let expectedHeaderTitle = "Foo"
		let section = DynamicSection.section(
			header: .text(expectedHeaderTitle),
			cells: [.headline(text: "Bar",
							  accessibilityIdentifier: "Bar")]
		)
		sut.dynamicTableViewModel = DynamicTableViewModel([section])

		let headerTitle = sut.tableView.dataSource?.tableView?(sut.tableView, titleForHeaderInSection: 0)
		
		XCTAssertEqual(headerTitle, expectedHeaderTitle)
	}
	
	func testTitleForHeader_whenHeaderIsTextAndSectionIsHidden_returnsNil() {
		// set up view model
		let section = DynamicSection.section(
			header: .text("Foo"),
			isHidden: { _ in return true },
			cells: [.headline(text: "Bar",
							  accessibilityIdentifier: "Bar")]
		)
		sut.dynamicTableViewModel = DynamicTableViewModel([section])

		let headerTitle = sut.tableView.dataSource?.tableView?(sut.tableView, titleForHeaderInSection: 0)
		
		XCTAssertNil(headerTitle)
	}
	
	func testTitleForHeader_whenHeaderIsNotText_returnsNil() {

		let dynamicHeader: [DynamicHeader] = [
			.none,
			.blank,
			.space(height: 1),
			.separator(color: .red),
			.image(nil, accessibilityIdentifier: nil),
			.view(UIView()),
			.identifier(DynamicTableViewController.HeaderFooterReuseIdentifier.header),
			.cell(withIdentifier: DynamicCell.CellReuseIdentifier.dynamicTypeLabel),
			.custom({ _ in return nil })
		]
		
		dynamicHeader.forEach { header in
			let section = DynamicSection.section(
				header: header,
				cells: [.headline(text: "Bar",
								  accessibilityIdentifier: "Bar")]
			)
			sut.dynamicTableViewModel = DynamicTableViewModel([section])
			
			let headerTitle = sut.tableView.dataSource?.tableView?(sut.tableView, titleForHeaderInSection: 0)
			
			XCTAssertNil(headerTitle)
		}
	}
	
	func testHeightForHeader_whenHeaderIsNone_isLeastNonezeroMagnitude() {
		// set up view model
		let section = DynamicSection.section(header: .none, cells: [.body(text: "Bar",
																		  accessibilityIdentifier: "Bar")])
		sut.dynamicTableViewModel = DynamicTableViewModel([section])

		let height = sut.tableView?.delegate?.tableView?(sut.tableView, heightForHeaderInSection: 0)
		
		XCTAssertEqual(height, .leastNonzeroMagnitude)
	}
	
	func testHeightForHeader_whenHeaderIsBlank_isAutomaticDimension() {
		// set up view model
		let section = DynamicSection.section(header: .blank, cells: [.body(text: "Bar",
																		   accessibilityIdentifier: "Bar")])
		sut.dynamicTableViewModel = DynamicTableViewModel([section])

		let height = sut.tableView?.delegate?.tableView?(sut.tableView, heightForHeaderInSection: 0)
		
		XCTAssertEqual(height, UITableView.automaticDimension)
	}
	
	func testHeightForHeader_whenHeaderIsSpace_isHeightOfSpace() {
		// set up view model
		let expectedHeight: CGFloat = 42
		let section = DynamicSection.section(header: .space(height: expectedHeight, color: nil), cells: [.body(text: "Bar",
																											   accessibilityIdentifier: "Bar")])
		sut.dynamicTableViewModel = DynamicTableViewModel([section])

		let height = sut.tableView?.delegate?.tableView?(sut.tableView, heightForHeaderInSection: 0)
		
		XCTAssertEqual(height, expectedHeight)
	}
	
	func testHeightForHeader_whenHeaderIsNotNoneOrBlankOrSpace_isAutomaticDimension() {
		// set up view model
		let dynamicHeader: [DynamicHeader] = [
			.separator(color: .red),
			.image(nil, accessibilityIdentifier: nil),
			.view(UIView()),
			.identifier(DynamicTableViewController.HeaderFooterReuseIdentifier.header),
			.cell(withIdentifier: DynamicCell.CellReuseIdentifier.dynamicTypeLabel),
			.custom({ _ in return nil })
		]
		
		dynamicHeader.forEach { header in
			let section = DynamicSection.section(header: header, cells: [.body(text: "Bar",
																			   accessibilityIdentifier: "Bar")])
			sut.dynamicTableViewModel = DynamicTableViewModel([section])
			
			let height = sut.tableView?.delegate?.tableView?(sut.tableView, heightForHeaderInSection: 0)
			
			XCTAssertEqual(height, UITableView.automaticDimension)
		}
	}
	
	func testHeightForHeader_whenHeaderIsHidden_isLeastNonzeroMagnitude() {
		// set up view model
		let section = DynamicSection.section(header: .text("Foo"), isHidden: { _ in return true }, cells: [.body(text: "Bar",
																												 accessibilityIdentifier: "Bar")])
		sut.dynamicTableViewModel = DynamicTableViewModel([section])

		let height = sut.tableView?.delegate?.tableView?(sut.tableView, heightForHeaderInSection: 0)
		
		XCTAssertEqual(height, .leastNonzeroMagnitude)
	}
	
	func testViewForHeader_whenHeaderIsSpace_returnsColoredView() {
		// set up view model
		let section = DynamicSection.section(header: .space(height: 42, color: .red), cells: [.body(text: "Bar",
																									accessibilityIdentifier: "Bar")])
		sut.dynamicTableViewModel = DynamicTableViewModel([section])

		let view = sut.tableView?.delegate?.tableView?(sut.tableView, viewForHeaderInSection: 0)
		
		XCTAssertEqual(view?.backgroundColor, .red)
	}
	
	func testViewForHeader_whenHeaderIsSeparator_returnsColoredView() {
		// set up view model
		let color: UIColor = .red
		let height: CGFloat = 42
		let insets = UIEdgeInsets(top: 1, left: 2, bottom: 3, right: 4)
		let section = DynamicSection.section(header: .separator(color: color, height: height, insets: insets), cells: [.body(text: "Bar",
																															 accessibilityIdentifier: "Bar")])
		sut.dynamicTableViewModel = DynamicTableViewModel([section])

		let view = sut.tableView?.delegate?.tableView?(sut.tableView, viewForHeaderInSection: 0)
		
		guard let headerSeparatorView = view as? DynamicTableViewHeaderSeparatorView else {
			return XCTFail("Unexpeced type")
		}
		XCTAssertEqual(headerSeparatorView.color, color)
		XCTAssertEqual(headerSeparatorView.height, height)
		XCTAssertEqual(headerSeparatorView.layoutMargins, insets)
	}
	
	func testViewForHeader_whenHeaderIsImage_returnsImageView() {
		// set up view model
		let image = UIImage()
		let height: CGFloat = 42
		let section = DynamicSection.section(header: .image(image, accessibilityIdentifier: nil, height: height), cells: [.body(text: "Bar",
																								  accessibilityIdentifier: "Bar")])
		sut.dynamicTableViewModel = DynamicTableViewModel([section])

		let view = sut.tableView?.delegate?.tableView?(sut.tableView, viewForHeaderInSection: 0)
		
		guard let headerImageView = view as? DynamicTableViewHeaderImageView else {
			return XCTFail("Unexpeced type")
		}
		XCTAssertEqual(headerImageView.imageView.image, image)
		XCTAssertEqual(headerImageView.height, height)
	}
	
	func testViewForHeader_whenHeaderIsView_returnsView() {
		// set up view model
		let expectedView = UIView()
		let section = DynamicSection.section(header: .view(expectedView), cells: [.body(text: "Bar",
																						accessibilityIdentifier: "Bar")])
		sut.dynamicTableViewModel = DynamicTableViewModel([section])

		let view = sut.tableView?.delegate?.tableView?(sut.tableView, viewForHeaderInSection: 0)
		
		XCTAssertEqual(view, expectedView)
	}
	
	func testViewForHeader_whenHeaderIsTextOrNoneOrBlank_returnsNil() {
		
		let dynamicHeader: [DynamicHeader] = [
			.text("foo"),
			.none,
			.blank
		]
		
		dynamicHeader.forEach { header in
			// set up view model
			let section = DynamicSection.section(header: header, cells: [.body(text: "Bar",
																			   accessibilityIdentifier: "Bar")])
			sut.dynamicTableViewModel = DynamicTableViewModel([section])
			
			let view = sut.tableView?.delegate?.tableView?(sut.tableView, viewForHeaderInSection: 0)
			
			XCTAssertNil(view, "Expected nil but got something for \(header)")
		}
	}
	
	func testViewForHeader_whenHeaderIsHidden_isNil() {
		// set up view model
		let section = DynamicSection.section(
			header: .text("Foo"),
			isHidden: { _ in return true },
			cells: [.body(text: "Bar",
						  accessibilityIdentifier: "Bar")]
		)
		sut.dynamicTableViewModel = DynamicTableViewModel([section])

		let view = sut.tableView?.delegate?.tableView?(sut.tableView, viewForHeaderInSection: 0)
		
		XCTAssertNil(view)
	}
}
