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

class DynamicTableViewControllerTests: XCTestCase {
	
	var sut: DynamicTableViewController!
	
	override func setUpWithError() throws {
		// The fake storyboard is needed here to instantiate an instance of
		// DynamicTableViewController like it will be done in the real app.
		// Without that, the tableView property doesn't get assign properly.
		let testBundle = Bundle(for: DynamicTableViewControllerTests.self)
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
extension DynamicTableViewControllerTests {
	
	func testViewDidLoad_registersDynamicTypeCell() {
		// setup view model
		let sections = [DynamicSection.section(cells: [.dynamicType(text: "Foo")])]
		sut.dynamicTableViewModel = DynamicTableViewModel(sections)
		
		// dequeue cell
		let reuseIdentifier = DynamicCell.CellReuseIdentifier.dynamicTypeText.rawValue
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
		let dynamicCell = DynamicCell.icon(action: .none, .init(text: "Foo", image: nil, backgroundColor: .red, tintColor: .green))
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
}

// MARK: - Number of rows and sections
extension DynamicTableViewControllerTests {
	func testNumberOfSections_returnsValueFromViewModel_withOneSection() {
		// setup view model
		let sections = [
			DynamicSection.section(cells: [.headline(text: "Foo")])
		]
		sut.dynamicTableViewModel = DynamicTableViewModel(sections)
		
		let numberOfSections = sut.tableView.dataSource?.numberOfSections?(in: sut.tableView)
		
		// assert
		XCTAssertEqual(numberOfSections, sections.count)
	}
	
	func testNumberOfSections_returnsValueFromViewModel_withThreeSections() {
		// setup view model
		let sections: [DynamicSection] = [
			.section(cells: [.headline(text: "Foo")]),
			.section(cells: [.headline(text: "Bar")]),
			.section(cells: [.headline(text: "Baz")])
		]
		sut.dynamicTableViewModel = DynamicTableViewModel(sections)
		
		let numberOfSections = sut.tableView.dataSource?.numberOfSections?(in: sut.tableView)
		
		// assert
		XCTAssertEqual(numberOfSections, sections.count)
	}
	
	func testNumberOfRows_returnsValueFromViewModel_withOneCell() {
		// setup view model
		let cells = [
			DynamicCell.headline(text: "Foo")
		]
		sut.dynamicTableViewModel = DynamicTableViewModel([.section(cells: cells)])
		
		let numberOfCells = sut.tableView.dataSource?.tableView(sut.tableView, numberOfRowsInSection: 0)
		
		// assert
		XCTAssertEqual(numberOfCells, cells.count)
	}
	
	func testNumberOfRows_returnsValueFromViewModel_withThreeCells() {
		// setup view model
		let cells: [DynamicCell] = [
			.headline(text: "Foo"),
			.headline(text: "Bar"),
			.headline(text: "Baz")
		]
		sut.dynamicTableViewModel = DynamicTableViewModel([.section(cells: cells)])
		
		let numberOfCells = sut.tableView.dataSource?.tableView(sut.tableView, numberOfRowsInSection: 0)

		// assert
		XCTAssertEqual(numberOfCells, cells.count)
	}
	
	func testNumberOfRows_returnsOne_forHiddenSection() {
		// setup view model
		let cells: [DynamicCell] = [
			.headline(text: "Foo"),
			.headline(text: "Bar"),
			.headline(text: "Baz")
		]
		let section = DynamicSection.section(isHidden: { _ in return true }, cells: cells)
		sut.dynamicTableViewModel = DynamicTableViewModel([section])
		
		let numberOfCells = sut.tableView.dataSource?.tableView(sut.tableView, numberOfRowsInSection: 0)

		// hidden sections have only one cell
		XCTAssertEqual(numberOfCells, 1)
	}
}

// MARK: - Header
extension DynamicTableViewControllerTests {
	func testTitleForHeader_whenHeaderIsText_returnsHeaderText() {
		// set up view model
		let expectedHeaderTitle = "Foo"
		let section = DynamicSection.section(
			header: .text(expectedHeaderTitle),
			cells: [.headline(text: "Bar")]
		)
		sut.dynamicTableViewModel = DynamicTableViewModel([section])

		// get header title from data source
		let headerTitle = sut.tableView.dataSource?.tableView?(sut.tableView, titleForHeaderInSection: 0)
		
		XCTAssertEqual(headerTitle, expectedHeaderTitle)
	}
	
	func testTitleForHeader_whenHeaderIsTextAndSectionIsHidden_returnsNil() {
		// set up view model
		let section = DynamicSection.section(
			header: .text("Foo"),
			isHidden: { _ in return true },
			cells: [.headline(text: "Bar")]
		)
		sut.dynamicTableViewModel = DynamicTableViewModel([section])

		// get header title from data source
		let headerTitle = sut.tableView.dataSource?.tableView?(sut.tableView, titleForHeaderInSection: 0)
		
		XCTAssertNil(headerTitle)
	}
	
	func testTitleForHeader_whenHeaderIsNotText_returnsNil() {

		let dynamicHeader: [DynamicHeader] = [
			.none,
			.blank,
			.space(height: 1),
			.separator(color: .red),
			.image(nil),
			.view(UIView()),
			.identifier(DynamicTableViewController.HeaderFooterReuseIdentifier.header),
			.cell(withIdentifier: DynamicTableViewStepCell.ReuseIdentifier.cell),
			.custom({ _ in return nil })
		]
		
		dynamicHeader.forEach { header in
			let section = DynamicSection.section(
				header: header,
				cells: [.headline(text: "Bar")]
			)
			sut.dynamicTableViewModel = DynamicTableViewModel([section])
			
			// get header title from data source
			let headerTitle = sut.tableView.dataSource?.tableView?(sut.tableView, titleForHeaderInSection: 0)
			
			XCTAssertNil(headerTitle)
		}
	}
	
	func testHeightForHeader_whenHeaderIsNone_isLeastNonezeroMagnitude() {
		// set up view model
		let section = DynamicSection.section(header: .none,
																				 cells: [.body(text: "Bar")])
		sut.dynamicTableViewModel = DynamicTableViewModel([section])

		// get header height
		let height = sut.tableView?.delegate?.tableView?(sut.tableView, heightForHeaderInSection: 0)
		
		XCTAssertEqual(height, .leastNonzeroMagnitude)
	}
	
	func testHeightForHeader_whenHeaderIsBlank_isAutomaticDimension() {
		// set up view model
		let section = DynamicSection.section(header: .blank,
																				 cells: [.body(text: "Bar")])
		sut.dynamicTableViewModel = DynamicTableViewModel([section])

		// get header height
		let height = sut.tableView?.delegate?.tableView?(sut.tableView, heightForHeaderInSection: 0)
		
		XCTAssertEqual(height, UITableView.automaticDimension)
	}
	
	func testHeightForHeader_whenHeaderIsSpace_isHeightOfSpace() {
		// set up view model
		let expectedHeight: CGFloat = 42
		let section = DynamicSection.section(header: .space(height: expectedHeight, color: nil),
																				 cells: [.body(text: "Bar")])
		sut.dynamicTableViewModel = DynamicTableViewModel([section])

		// get header height
		let height = sut.tableView?.delegate?.tableView?(sut.tableView, heightForHeaderInSection: 0)
		
		XCTAssertEqual(height, expectedHeight)
	}
	
	func testHeightForHeader_whenHeaderIsNotNoneOrBlankOrSpace_isAutomaticDimension() {
		// set up view model
		let dynamicHeader: [DynamicHeader] = [
			.separator(color: .red),
			.image(nil),
			.view(UIView()),
			.identifier(DynamicTableViewController.HeaderFooterReuseIdentifier.header),
			.cell(withIdentifier: DynamicTableViewStepCell.ReuseIdentifier.cell),
			.custom({ _ in return nil })
		]
		
		dynamicHeader.forEach { header in
			let section = DynamicSection.section(header: header,
																					 cells: [.body(text: "Bar")])
			sut.dynamicTableViewModel = DynamicTableViewModel([section])
			
			// get header height
			let height = sut.tableView?.delegate?.tableView?(sut.tableView, heightForHeaderInSection: 0)
			
			XCTAssertEqual(height, UITableView.automaticDimension)
		}
	}
	
	func testHeightForHeader_whenHeaderIsHidden_isLeastNonzeroMagnitude() {
		// set up view model
		let section = DynamicSection.section(header: .text("Foo"),
																				 isHidden: { _ in return true },
																				 cells: [.body(text: "Bar")])
		sut.dynamicTableViewModel = DynamicTableViewModel([section])

		// get header height
		let height = sut.tableView?.delegate?.tableView?(sut.tableView, heightForHeaderInSection: 0)
		
		XCTAssertEqual(height, .leastNonzeroMagnitude)
	}
	
	func testViewForHeaderInSection_whenHeaderIsSpace_returnsColoredView() {
		// set up view model
		let section = DynamicSection.section(header: .space(height: 42, color: .red),
																				 cells: [.body(text: "Bar")])
		sut.dynamicTableViewModel = DynamicTableViewModel([section])

		// get header height
		let view = sut.tableView?.delegate?.tableView?(sut.tableView, viewForHeaderInSection: 0)
		
		XCTAssertEqual(view?.backgroundColor, .red)
	}
	
	func testViewForHeaderInSection_whenHeaderIsSeparator_returnsColoredView() {
		// set up view model
		let color: UIColor = .red
		let height: CGFloat = 42
		let insets = UIEdgeInsets(top: 1, left: 2, bottom: 3, right: 4)
		let section = DynamicSection.section(header: .separator(color: color, height: height, insets: insets),
																				 cells: [.body(text: "Bar")])
		sut.dynamicTableViewModel = DynamicTableViewModel([section])

		// get header height
		let view = sut.tableView?.delegate?.tableView?(sut.tableView, viewForHeaderInSection: 0) as! DynamicTableViewHeaderSeparatorView
		
		XCTAssertEqual(view.color, color)
		XCTAssertEqual(view.height, height)
		XCTAssertEqual(view.layoutMargins, insets)
	}
	
	func testViewForHeaderInSection_whenHeaderIsImage_returnsImageView() {
		// set up view model
		let image = UIImage()
		let height: CGFloat = 42
		let section = DynamicSection.section(header: .image(image, height: height),
																				 cells: [.body(text: "Bar")])
		sut.dynamicTableViewModel = DynamicTableViewModel([section])

		// get header height
		let view = sut.tableView?.delegate?.tableView?(sut.tableView, viewForHeaderInSection: 0) as! DynamicTableViewHeaderImageView
		
		XCTAssertEqual(view.imageView.image, image)
		XCTAssertEqual(view.height, height)
	}
	
	func testViewForHeaderInSection_whenHeaderIsView_returnsView() {
		// set up view model
		let expectedView = UIView()
		let section = DynamicSection.section(header: .view(expectedView),
																				 cells: [.body(text: "Bar")])
		sut.dynamicTableViewModel = DynamicTableViewModel([section])

		// get header height
		let view = sut.tableView?.delegate?.tableView?(sut.tableView, viewForHeaderInSection: 0)
		
		XCTAssertEqual(view, expectedView)
	}
	
	func testViewForHeaderInSection_whenHeaderIsTextOrNoneOrBlank_returnsNil() {
		
		let dynamicHeader: [DynamicHeader] = [
			.text("foo"),
			.none,
			.blank
		]
		
		dynamicHeader.forEach { header in
			// set up view model
			let section = DynamicSection.section(header: header,
																					 cells: [.body(text: "Bar")])
			sut.dynamicTableViewModel = DynamicTableViewModel([section])
			
			// get header height
			let view = sut.tableView?.delegate?.tableView?(sut.tableView, viewForHeaderInSection: 0)
			
			XCTAssertNil(view, "Expected nil but got something for \(header)")
		}
	}
}

// MARK: - Footer
extension DynamicTableViewControllerTests {
	func testTitleForFooter_whenFooterIsText_returnsFooterText() {
		// set up view model
		let expectedFooterTitle = "Foo"
		let section = DynamicSection.section(footer: .text(expectedFooterTitle), cells: [.headline(text: "Bar")])
		sut.dynamicTableViewModel = DynamicTableViewModel([section])

		// get header title from data source
		let footerTitle = sut.tableView.dataSource?.tableView?(sut.tableView, titleForFooterInSection: 0)
		
		XCTAssertEqual(footerTitle, expectedFooterTitle)
	}
	
	func testTitleForFooter_whenFooterIsTextAndSectionIsHidden_returnsNil() {
		// set up view model
		let section = DynamicSection.section(
			footer: .text("Foo"),
			isHidden: { _ in return true },
			cells: [.headline(text: "Bar")]
		)
		sut.dynamicTableViewModel = DynamicTableViewModel([section])

		// get header title from data source
		let footerTitle = sut.tableView.dataSource?.tableView?(sut.tableView, titleForFooterInSection: 0)
		
		XCTAssertNil(footerTitle)
	}
	
	func testTitleForFooter_whenFooterIsNotText_returnsNil() {

		let dynamicFooter: [DynamicFooter] = [
			.none,
			.blank,
			.space(height: 1),
			.separator(color: .red),
			.image(nil),
			.view(UIView()),
			.identifier(DynamicTableViewController.HeaderFooterReuseIdentifier.header),
			.cell(withIdentifier: DynamicTableViewStepCell.ReuseIdentifier.cell),
			.custom({ _ in return nil })
		]
		
		dynamicFooter.forEach { footer in
			let section = DynamicSection.section(
				footer: footer,
				cells: [.headline(text: "Bar")]
			)
			sut.dynamicTableViewModel = DynamicTableViewModel([section])
			
			// get header title from data source
			let footerTitle = sut.tableView.dataSource?.tableView?(sut.tableView, titleForFooterInSection: 0)
			
			XCTAssertNil(footerTitle)
		}
	}
	
	func testHeightForFooter_whenFooterIsNone_isLeastNonezeroMagnitude() {
		// set up view model
		let section = DynamicSection.section(footer: .none,
																				 cells: [.body(text: "Bar")])
		sut.dynamicTableViewModel = DynamicTableViewModel([section])

		// get header height
		let height = sut.tableView?.delegate?.tableView?(sut.tableView, heightForFooterInSection: 0)
		
		XCTAssertEqual(height, .leastNonzeroMagnitude)
	}
	
	func testHeightForFooter_whenFooterIsBlank_isAutomaticDimension() {
		// set up view model
		let section = DynamicSection.section(footer: .blank,
																				 cells: [.body(text: "Bar")])
		sut.dynamicTableViewModel = DynamicTableViewModel([section])

		// get header height
		let height = sut.tableView?.delegate?.tableView?(sut.tableView, heightForFooterInSection: 0)
		
		XCTAssertEqual(height, UITableView.automaticDimension)
	}
	
	func testHeightForFooter_whenFooterIsSpace_isHeightOfSpace() {
		// set up view model
		let expectedHeight: CGFloat = 42
		let section = DynamicSection.section(footer: .space(height: expectedHeight, color: nil),
																				 cells: [.body(text: "Bar")])
		sut.dynamicTableViewModel = DynamicTableViewModel([section])

		// get header height
		let height = sut.tableView?.delegate?.tableView?(sut.tableView, heightForFooterInSection: 0)
		
		XCTAssertEqual(height, expectedHeight)
	}
	
	func testHeightForFooter_whenFooterIsNotNoneOrBlankOrSpace_isAutomaticDimension() {
		// set up view model
		let dynamicFooter: [DynamicHeader] = [
			.separator(color: .red),
			.image(nil),
			.view(UIView()),
			.identifier(DynamicTableViewController.HeaderFooterReuseIdentifier.header),
			.cell(withIdentifier: DynamicTableViewStepCell.ReuseIdentifier.cell),
			.custom({ _ in return nil })
		]
		
		dynamicFooter.forEach { footer in
			let section = DynamicSection.section(footer: footer,
																					 cells: [.body(text: "Bar")])
			sut.dynamicTableViewModel = DynamicTableViewModel([section])
			
			// get header height
			let height = sut.tableView?.delegate?.tableView?(sut.tableView, heightForFooterInSection: 0)
			
			XCTAssertEqual(height, UITableView.automaticDimension)
		}
	}
	
	func testHeightForFooterInSection_whenFooterIsHidden_isLeastNonzeroMagnitude() {
		// set up view model
		let section = DynamicSection.section(footer: .text("Foo"),
																				 isHidden: { _ in return true },
																				 cells: [.body(text: "Bar")])
		sut.dynamicTableViewModel = DynamicTableViewModel([section])

		// get header height
		let height = sut.tableView?.delegate?.tableView?(sut.tableView, heightForFooterInSection: 0)
		
		XCTAssertEqual(height, .leastNonzeroMagnitude)
	}
}
