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

final class DynamicTypeLabelTests: XCTestCase {
    func testDesignatedInitializer() {
		XCTAssertNotNil(DynamicTypeLabel())
    }

	func testBoldWeight() {
		let sut = DynamicTypeLabel()
		sut.dynamicTypeWeight = "bold"
		// swiftlint:disable:next force_cast
		let traits = sut.font.fontDescriptor.object(forKey: .traits) as! [UIFontDescriptor.TraitKey: AnyObject]
		let weight = traits[.weight] as? NSNumber ?? NSNumber(-1)
		XCTAssertEqual(CGFloat(weight.doubleValue), UIFont.Weight.bold.rawValue, accuracy: 0.001)
	}

	func testSemboldWeight() {
		let sut = DynamicTypeLabel()
		sut.dynamicTypeWeight = "semibold"
		// swiftlint:disable:next force_cast
		let traits = sut.font.fontDescriptor.object(forKey: .traits) as! [UIFontDescriptor.TraitKey: AnyObject]
		let weight = traits[.weight] as? NSNumber ?? NSNumber(-1)
		XCTAssertEqual(CGFloat(weight.doubleValue), UIFont.Weight.semibold.rawValue, accuracy: 0.001)
	}
}
