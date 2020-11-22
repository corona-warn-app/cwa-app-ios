//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class DynamicTableViewModelTests: XCTestCase {
	
	var sut: DynamicTableViewModel!
	var sections: [DynamicSection] = []
	var cellsSection0: [DynamicCell] = []
	var cellsSection1: [DynamicCell] = []

	override func setUpWithError() throws {
		cellsSection0 = [
			DynamicCell.body(
				text: "Foo",
				accessibilityIdentifier: "Foo"
			),
			DynamicCell.body(
				text: "Bar",
				accessibilityIdentifier: "Bar"
			)
		]
		cellsSection1 = [
			DynamicCell.body(
				text: "Baz",
				accessibilityIdentifier: "Baz"
			)
		]
		sections = [
			DynamicSection.section(cells: cellsSection0),
			DynamicSection.section(cells: cellsSection1)
		]
		sut = DynamicTableViewModel(sections)
	}

	override func tearDownWithError() throws {
		sut = nil
		sections = []
		cellsSection0 = []
		cellsSection1 = []
	}

	func testSection_returnsInitializedSection() {
		let section = sut.section(1)
		
		XCTAssertEqual(section.cells.count, 1)
		XCTAssertEqual(section.cells.first?.cellReuseIdentifier as? DynamicCell.CellReuseIdentifier, DynamicCell.CellReuseIdentifier.dynamicTypeLabel)
		
	}

	func testSectionAt_returnsInitializedSection() {
		let section = sut.section(at: IndexPath(row: 0, section: 1))

		XCTAssertEqual(section.cells.count, 1)
		XCTAssertEqual(
			section.cells.first?.cellReuseIdentifier as? DynamicCell.CellReuseIdentifier,
			DynamicCell.CellReuseIdentifier.dynamicTypeLabel
		)
	}

	func testCellAt_returnsInitializedCell() {
		let cell = sut.cell(at: IndexPath(row: 0, section: 0))
		XCTAssertEqual(cell.cellReuseIdentifier as? DynamicCell.CellReuseIdentifier, DynamicCell.CellReuseIdentifier.dynamicTypeLabel)
	}
	
	func testNumberOfSections() {
		XCTAssertEqual(sut.numberOfSection, sections.count)
	}
	
	func testNumberOfRows_section0() {
		XCTAssertEqual(sut.numberOfRows(inSection: 0, for: DynamicTableViewController()), cellsSection0.count)
	}
	
	func testAdd_appendsSection() {
		let cells = [DynamicCell.headline(
			text: "23",
			accessibilityIdentifier: "23")
		]
		sut.add(DynamicSection.section(cells: cells))

		// get last section
		let section = getLastSection(from: sut)
		// assert cell type and content
		XCTAssertEqual(
			section.cells.first?.cellReuseIdentifier as? DynamicCell.CellReuseIdentifier, DynamicCell.CellReuseIdentifier.dynamicTypeLabel
		)
	}

	func testWith_returnsAlteredModel() {
		let model = DynamicTableViewModel.with { model in
			let cells = [
				DynamicCell.headline(
					text: "42",
					accessibilityIdentifier: "42"
				)
			]
			model.add(DynamicSection.section(cells: cells))
		}

		// get last section
		let section = getLastSection(from: model)
		// assert cell type and content
		XCTAssertEqual(
			section.cells.first?.cellReuseIdentifier as? DynamicCell.CellReuseIdentifier,
			DynamicCell.CellReuseIdentifier.dynamicTypeLabel
		)
	}
}

extension DynamicTableViewModelTests {
	func getLastSection(from model: DynamicTableViewModel) -> DynamicSection {
		model.section(model.numberOfSection - 1)
	}
}
