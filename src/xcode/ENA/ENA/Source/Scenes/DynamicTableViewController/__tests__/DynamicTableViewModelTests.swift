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

class DynamicTableViewModelTests: XCTestCase {
	
	var sut: DynamicTableViewModel!
	var sections: [DynamicSection] = []
	var cellsSection0: [DynamicCell] = []
	var cellsSection1: [DynamicCell] = []

	override func setUpWithError() throws {
		cellsSection0 = [
			DynamicCell.bold(text: "Foo"),
			DynamicCell.bold(text: "Bar")
		]
		cellsSection1 = [
			DynamicCell.bold(text: "Baz")
		]
		sections = [
			DynamicSection.section(cells: cellsSection0),
		  DynamicSection.section(cells: cellsSection1),
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
		let cell = section.cells.first
		if case .bold(text: let text) = cell {
			XCTAssertEqual(text, "Baz")
		} else {
			XCTFail()
		}
	}
	
	func testSectionAt_returnsInitializedSection() {
		
		let section = sut.section(at: IndexPath(row: 0, section: 1))
		
		XCTAssertEqual(section.cells.count, 1)
		let cell = section.cells.first
		if case .bold(text: let text) = cell {
			XCTAssertEqual(text, "Baz")
		} else {
			XCTFail()
		}
	}
	
	func testCellAt_returnsInitializedCell() {
		
		let cell = sut.cell(at: IndexPath(row: 0, section: 0))
		
		if case .bold(text: let text) = cell {
			XCTAssertEqual(text, "Foo")
		} else {
			XCTFail()
		}
	}
	
	func testNumberOfSections() {
		
		XCTAssertEqual(sut.numberOfSection, sections.count)
	}
	
	func testNumberOfRows_section0() {
		
		XCTAssertEqual(sut.numberOfRows(inSection: 0, for: DynamicTableViewController()), cellsSection0.count)
	}
	
	func testAdd_appendsSection() {
		
		let cells = [DynamicCell.semibold(text: "23")]
		sut.add(DynamicSection.section(cells: cells))

		// get last section
		let section = getLastSection(from: sut)
		// assert cell type and content
		let cell = section.cells.first
		if case .semibold(text: let text) = cell {
			XCTAssertEqual(text, "23")
		} else {
			XCTFail()
		}
	}
	
	func testWith_returnsAlteredModel() {
		
		let model = DynamicTableViewModel.with { model in
			let cells = [DynamicCell.semibold(text: "42")]
			model.add(DynamicSection.section(cells: cells))
		}
		
		// get last section
		let section = getLastSection(from: model)
		// assert cell type and content
		let cell = section.cells.first
		if case .semibold(text: let text) = cell {
			XCTAssertEqual(text, "42")
		} else {
			XCTFail()
		}
	}
}

extension DynamicTableViewModelTests {
	func getLastSection(from model: DynamicTableViewModel) -> DynamicSection {
		let numberOfSections = model.numberOfSection
		return model.section(numberOfSections - 1)
	}
}
