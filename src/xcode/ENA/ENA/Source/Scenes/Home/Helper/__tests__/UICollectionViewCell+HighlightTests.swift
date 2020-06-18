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

final class UICollectionViewCell_HighlightTests: XCTestCase {
    func testHasNoHighlightViewByDefault() throws {
		let sut = UICollectionViewCell()
		XCTAssertNil(sut.highlightView)
		XCTAssertTrue(sut.highlightViews.isEmpty)
    }

	func testAddsHighlightView_OnlyOnce() throws {
		let sut = UICollectionViewCell()
		sut.highlight()
		XCTAssertNotNil(sut.highlightView)
		XCTAssertEqual(sut.highlightViews.count, 1)

		sut.highlight()
		XCTAssertNotNil(sut.highlightView)
		XCTAssertEqual(sut.highlightViews.count, 1)
	}

	func testRemovesHighlightViewOnUnhighlight() throws {
		let sut = UICollectionViewCell()
		sut.highlight()
		XCTAssertNotNil(sut.highlightView)
		XCTAssertEqual(sut.highlightViews.count, 1)

		sut.unhighlight()

		XCTAssertNil(sut.highlightView)
		XCTAssertTrue(sut.highlightViews.isEmpty)
	}

	func testAdjustsCornerRadiusOfHomeCardCollectionViewCells() throws {
		let sut = CustomHomeCardCollectionViewCell()
		sut.contentView.layer.cornerRadius = 20
		sut.highlight()

		XCTAssertEqual(sut.highlightViews.count, 1)
		let highlightView = try XCTUnwrap(sut.highlightView)
		XCTAssertEqual(highlightView.layer.cornerRadius, 20, accuracy: 0.01)
	}

	func testDoesNotAdjustsCornerRadiusOfNonHomeCardCollectionViewCells() throws {
		let sut = UICollectionViewCell()
		sut.contentView.layer.cornerRadius = 20
		sut.highlight()

		XCTAssertEqual(sut.highlightViews.count, 1)
		let highlightView = try XCTUnwrap(sut.highlightView)
		XCTAssertEqual(highlightView.layer.cornerRadius, 0, accuracy: 0.01)
	}
}

private extension UIView {
	var highlightViews: [UIView] {
		let immediate = subviews.filter { $0.tag == .highlightViewTag }
		let nested = immediate.map { $0.highlightViews }.flatMap { $0 }
		return immediate + nested
	}
}

private class CustomHomeCardCollectionViewCell: HomeCardCollectionViewCell { }
