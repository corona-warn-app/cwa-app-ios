//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class DynamicCellTests: XCTestCase {
	// A `DynamicTableViewController` is required to test the `DynamicCell` configurations,
	// as `CellConfigurator` require an instance of `DynamicTableViewController`
	var dynamicVC: DynamicTableViewController!
	var window: UIWindow!

	override func setUpWithError() throws {
		dynamicVC = DynamicTableViewController()

		// trigger viewDidLoad
		dynamicVC.loadViewIfNeeded()

		window = UIWindow(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
		window.makeKeyAndVisible()
		
		window.rootViewController = dynamicVC
	}

	override func tearDownWithError() throws {
		dynamicVC = nil
		window = nil
	}
}

extension DynamicCellTests {
	// MARK: - Dynamic Type Cell Tests

	func testMakeDynamicCell_TextCell_DefaultIsLabelStyle() {
		let section = DynamicSection.section(cells: [.dynamicType(text: "Foo")])
		dynamicVC.dynamicTableViewModel = DynamicTableViewModel([section])
		
		dynamicVC.tableView.reloadData() // Force a reload that new ViewModel gets used

		let indexPath = IndexPath(row: 0, section: 0)
		let cell = dynamicVC.tableView.cellForRow(at: indexPath)
		
		XCTAssertTrue(cell is DynamicTableViewTextCell)
	}

	func testMakeDynamicCell_UseTextViewCellStyle() {
		let section = DynamicSection.section(cells: [.dynamicType(text: "Foo", cellStyle: .textView([]))])
		dynamicVC.dynamicTableViewModel = DynamicTableViewModel([section])

		dynamicVC.tableView.reloadData() // Force a reload that new ViewModel gets used

		let indexPath = IndexPath(row: 0, section: 0)
		let cell = dynamicVC.tableView.cellForRow(at: indexPath)

		XCTAssertTrue(cell is DynamicTableViewTextViewCell)
	}

	func testMakeDynamicCell_UseTextViewCellStyle_WithDataDetectors() throws {
		let expectedDetectors = UIDataDetectorTypes.all
		let section = DynamicSection.section(cells: [.dynamicType(text: "Foo", cellStyle: .textView(expectedDetectors))])
		dynamicVC.dynamicTableViewModel = DynamicTableViewModel([section])

		dynamicVC.tableView.reloadData() // Force a reload that new ViewModel gets used

		let indexPath = IndexPath(row: 0, section: 0)
		let cell = dynamicVC.tableView.cellForRow(at: indexPath)

		let textViewCell = try XCTUnwrap(cell as? DynamicTableViewTextViewCell)
		let textView = try textViewCell.getTextView()
		XCTAssertEqual(textView.dataDetectorTypes, expectedDetectors)
	}

	// MARK: - Body Dynamic Cell Tests

	func testMakeDynamicCell_Body_DefaultIsLabelStyle() {
		let section = DynamicSection.section(cells: [.body(text: "Foo", accessibilityIdentifier: "Foo")])
		dynamicVC.dynamicTableViewModel = DynamicTableViewModel([section])
		
		dynamicVC.tableView.reloadData() // Force a reload that new ViewModel gets used

		let indexPath = IndexPath(row: 0, section: 0)
		let cell = dynamicVC.tableView.cellForRow(at: indexPath)

		XCTAssertTrue(cell is DynamicTableViewTextCell)
	}
}

// MARK: - Helpers

private extension DynamicTableViewTextViewCell {
	func getTextView() throws -> UITextView {
		return try XCTUnwrap(contentView.subviews.first(where: { $0 is UITextView }) as? UITextView)
	}
}
