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

import XCTest
@testable import ENA

class DynamicTableViewSpaceCellTests: XCTestCase {
	
	func testHeight_whenHeightIsAutomaticDimension_isAutomaticDimentsion() {
		let cell = DynamicTableViewSpaceCell()
		cell.height = UITableView.automaticDimension
		
		XCTAssertEqual(cell.height, UITableView.automaticDimension)
	}
	
	func testHeight_whenHeightIsNegative_isLeastNonzeroMagnitude() {
		let cell = DynamicTableViewSpaceCell()
		cell.height = -42
		
		XCTAssertEqual(cell.height, .leastNonzeroMagnitude)
	}
	
	func testHeight_whenHeightIsOne_isOne() {
		let cell = DynamicTableViewSpaceCell()
		cell.height = 1
		
		XCTAssertEqual(cell.height, 1)
	}
	
	func testHeight_whenHeightIsFourtyTwo_isFourtyTwo() {
		let cell = DynamicTableViewSpaceCell()
		cell.height = 42
		
		XCTAssertEqual(cell.height, 42)
	}
	
	func testPrepareForReuse_setsHeightToAutomaticDimension() {
		let cell = DynamicTableViewSpaceCell()
		cell.prepareForReuse()
		
		XCTAssertEqual(cell.height, UITableView.automaticDimension)
	}
	
	func testPrepareForReuse_setsBackgroundColorToNil() {
		let cell = DynamicTableViewSpaceCell()
		cell.backgroundColor = .yellow
		cell.prepareForReuse()
		
		XCTAssertNil(cell.backgroundColor)
	}
	
	func testAccessibilityElementCount_isZero() {
		let cell = DynamicTableViewSpaceCell()
		
		XCTAssertEqual(cell.accessibilityElementCount(), 0)
	}
}
