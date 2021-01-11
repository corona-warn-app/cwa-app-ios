//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA
import UIKit

class DynamicTableViewControllerHeaderTests: XCTestCase {
	
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
	
	func testViewForHeader_whenHeaderIsImageWithHeight_returnsImageView() {
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

	func testViewForHeader_whenHeaderIsImageWithoutHeight_returnsImageView() {
		// set up view model
		let rect = CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.size.width, height: 80.0))
		UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
		UIRectFill(rect)
		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		guard let cgImage = image?.cgImage else {
			XCTFail("Failed to create a test image with expected size")
			return
		}

		let fixedImage = UIImage(cgImage: cgImage)
		let section = DynamicSection.section(header: .image(fixedImage, accessibilityIdentifier: nil), cells: [.body(text: "Bar",
																								  accessibilityIdentifier: "Bar")])
		sut.dynamicTableViewModel = DynamicTableViewModel([section])

		let view = sut.tableView?.delegate?.tableView?(sut.tableView, viewForHeaderInSection: 0)

		guard let headerImageView = view as? DynamicTableViewHeaderImageView else {
			return XCTFail("Unexpeced type")
		}
		XCTAssertEqual(headerImageView.imageView.image, fixedImage)
		XCTAssertEqual(headerImageView.height, 80.0)
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
