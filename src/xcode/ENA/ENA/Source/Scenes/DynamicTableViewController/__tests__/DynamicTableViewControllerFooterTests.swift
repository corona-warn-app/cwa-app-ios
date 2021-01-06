//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class DynamicTableViewControllerFooterTests: XCTestCase {

	var sut: DynamicTableViewController!
	
	override func setUpWithError() throws {
		sut = DynamicTableViewController()
		// trigger viewDidLoad
		sut.loadViewIfNeeded()
	}
	
	override func tearDownWithError() throws {
		sut = nil
	}
}

// MARK: - Footer
extension DynamicTableViewControllerFooterTests {
	func testTitleForFooter_whenFooterIsText_returnsFooterText() {
		// set up view model
		let expectedFooterTitle = "Foo"
		let section = DynamicSection.section(footer: .text(expectedFooterTitle), cells: [.headline(text: "Bar",
																								   accessibilityIdentifier: "Bar")])
		sut.dynamicTableViewModel = DynamicTableViewModel([section])

		let footerTitle = sut.tableView.dataSource?.tableView?(sut.tableView, titleForFooterInSection: 0)
		
		XCTAssertEqual(footerTitle, expectedFooterTitle)
	}
	
	func testTitleForFooter_whenFooterIsTextAndSectionIsHidden_returnsNil() {
		// set up view model
		let section = DynamicSection.section(
			footer: .text("Foo"),
			isHidden: { _ in return true },
			cells: [.headline(text: "Bar",
							  accessibilityIdentifier: "Bar")]
		)
		sut.dynamicTableViewModel = DynamicTableViewModel([section])

		let footerTitle = sut.tableView.dataSource?.tableView?(sut.tableView, titleForFooterInSection: 0)
		
		XCTAssertNil(footerTitle)
	}
	
	func testTitleForFooter_whenFooterIsNotText_returnsNil() {

		let dynamicFooter: [DynamicFooter] = [
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
		
		dynamicFooter.forEach { footer in
			let section = DynamicSection.section(
				footer: footer,
				cells: [.headline(text: "Bar",
								  accessibilityIdentifier: "Bar")]
			)
			sut.dynamicTableViewModel = DynamicTableViewModel([section])
			
			// get header title from data source
			let footerTitle = sut.tableView.dataSource?.tableView?(sut.tableView, titleForFooterInSection: 0)
			
			XCTAssertNil(footerTitle)
		}
	}
	
	func testHeightForFooter_whenFooterIsNone_isLeastNonezeroMagnitude() {
		// set up view model
		let section = DynamicSection.section(footer: .none, cells: [.body(text: "Bar",
																		  accessibilityIdentifier: "Bar")])
		sut.dynamicTableViewModel = DynamicTableViewModel([section])

		let height = sut.tableView?.delegate?.tableView?(sut.tableView, heightForFooterInSection: 0)
		
		XCTAssertEqual(height, .leastNonzeroMagnitude)
	}
	
	func testHeightForFooter_whenFooterIsBlank_isAutomaticDimension() {
		// set up view model
		let section = DynamicSection.section(footer: .blank, cells: [.body(text: "Bar",
																		   accessibilityIdentifier: "Bar")])
		sut.dynamicTableViewModel = DynamicTableViewModel([section])

		let height = sut.tableView?.delegate?.tableView?(sut.tableView, heightForFooterInSection: 0)
		
		XCTAssertEqual(height, UITableView.automaticDimension)
	}
	
	func testHeightForFooter_whenFooterIsSpace_isHeightOfSpace() {
		// set up view model
		let expectedHeight: CGFloat = 42
		let section = DynamicSection.section(footer: .space(height: expectedHeight, color: nil), cells: [.body(text: "Bar",
																											   accessibilityIdentifier: "Bar")])
		sut.dynamicTableViewModel = DynamicTableViewModel([section])

		let height = sut.tableView?.delegate?.tableView?(sut.tableView, heightForFooterInSection: 0)
		
		XCTAssertEqual(height, expectedHeight)
	}
	
	func testHeightForFooter_whenFooterIsNotNoneOrBlankOrSpace_isAutomaticDimension() {
		// set up view model
		let dynamicFooter: [DynamicHeader] = [
			.separator(color: .red),
			.image(nil, accessibilityIdentifier: nil),
			.view(UIView()),
			.identifier(DynamicTableViewController.HeaderFooterReuseIdentifier.header),
			.cell(withIdentifier: DynamicCell.CellReuseIdentifier.dynamicTypeLabel),
			.custom({ _ in return nil })
		]
		
		dynamicFooter.forEach { footer in
			let section = DynamicSection.section(footer: footer, cells: [.body(text: "Bar",
																			   accessibilityIdentifier: "Bar")])
			sut.dynamicTableViewModel = DynamicTableViewModel([section])
			
			let height = sut.tableView?.delegate?.tableView?(sut.tableView, heightForFooterInSection: 0)
			
			XCTAssertEqual(height, UITableView.automaticDimension)
		}
	}
	
	func testHeightForFooterInSection_whenFooterIsHidden_isLeastNonzeroMagnitude() {
		// set up view model
		let section = DynamicSection.section(
			footer: .text("Foo"),
			isHidden: { _ in return true },
			cells: [.body(text: "Bar",
						  accessibilityIdentifier: "Bar")]
		)
		sut.dynamicTableViewModel = DynamicTableViewModel([section])
		
		let height = sut.tableView?.delegate?.tableView?(sut.tableView, heightForFooterInSection: 0)
		
		XCTAssertEqual(height, .leastNonzeroMagnitude)
	}
	
	func testViewForFooterInSection_whenFooterIsSpace_returnsColoredView() {
		// set up view model
		let section = DynamicSection.section(footer: .space(height: 42, color: .red), cells: [.body(text: "Bar",
																									accessibilityIdentifier: "Bar")])
		sut.dynamicTableViewModel = DynamicTableViewModel([section])

		let view = sut.tableView?.delegate?.tableView?(sut.tableView, viewForFooterInSection: 0)
		
		XCTAssertEqual(view?.backgroundColor, .red)
	}
	
	func testViewForFooterInSection_whenFooterIsSeparator_returnsColoredView() {
		// set up view model
		let color: UIColor = .red
		let height: CGFloat = 42
		let insets = UIEdgeInsets(top: 1, left: 2, bottom: 3, right: 4)
		let section = DynamicSection.section(footer: .separator(color: color, height: height, insets: insets), cells: [.body(text: "Bar",
																															 accessibilityIdentifier: "Bar")])
		sut.dynamicTableViewModel = DynamicTableViewModel([section])

		let view = sut.tableView?.delegate?.tableView?(sut.tableView, viewForFooterInSection: 0)
		
		guard let headerSeparatorView = view as? DynamicTableViewHeaderSeparatorView else {
			return XCTFail("Unexpected type")
		}
		XCTAssertEqual(headerSeparatorView.color, color)
		XCTAssertEqual(headerSeparatorView.height, height)
		XCTAssertEqual(headerSeparatorView.layoutMargins, insets)
	}
	
	func testViewForFooterInSection_whenFooterIsImage_returnsImageView() {
		// set up view model
		let image = UIImage()
		let height: CGFloat = 42
		let section = DynamicSection.section(footer: .image(image, accessibilityIdentifier: nil, height: height), cells: [.body(text: "Bar",
																								  accessibilityIdentifier: "Bar")])
		sut.dynamicTableViewModel = DynamicTableViewModel([section])

		let view = sut.tableView?.delegate?.tableView?(sut.tableView, viewForFooterInSection: 0)
		
		guard let headerImageView = view as? DynamicTableViewHeaderImageView else {
			return XCTFail("Unexpected type")
		}
		XCTAssertEqual(headerImageView.imageView.image, image)
		XCTAssertEqual(headerImageView.height, height)
	}
	
	func testViewForFooterInSection_whenFooterIsView_returnsView() {
		// set up view model
		let expectedView = UIView()
		let section = DynamicSection.section(footer: .view(expectedView), cells: [.body(text: "Bar",
																						accessibilityIdentifier: "Bar")])
		sut.dynamicTableViewModel = DynamicTableViewModel([section])

		let view = sut.tableView?.delegate?.tableView?(sut.tableView, viewForFooterInSection: 0)
		
		XCTAssertEqual(view, expectedView)
	}
	
	func testViewForFooterInSection_whenFooterIsTextOrNoneOrBlank_returnsNil() {
		
		let dynamicFooter: [DynamicHeader] = [
			.text("foo"),
			.none,
			.blank
		]
		
		dynamicFooter.forEach { footer in
			// set up view model
			let section = DynamicSection.section(footer: footer, cells: [.body(text: "Bar",
																			   accessibilityIdentifier: "Bar")])
			sut.dynamicTableViewModel = DynamicTableViewModel([section])
			
			let view = sut.tableView?.delegate?.tableView?(sut.tableView, viewForFooterInSection: 0)
			
			XCTAssertNil(view, "Expected nil but got something for \(footer)")
		}
	}
	
	func testViewForFooter_whenFooterIsHidden_isNil() {
		// set up view model
		let section = DynamicSection.section(
			footer: .text("Foo"),
			isHidden: { _ in return true },
			cells: [.body(text: "Bar",
						  accessibilityIdentifier: "Bar")]
		)
		sut.dynamicTableViewModel = DynamicTableViewModel([section])
		
		let view = sut.tableView?.delegate?.tableView?(sut.tableView, viewForFooterInSection: 0)
		
		XCTAssertNil(view)
	}
}
