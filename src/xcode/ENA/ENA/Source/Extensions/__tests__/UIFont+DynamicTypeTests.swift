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

final class UIFont_DynamicTypeTests: XCTestCase {
    func testWeightFromString() {
		XCTAssertEqual(UIFont.Weight("ultraLight").rawValue, UIFont.Weight.ultraLight.rawValue, accuracy: .high)
		XCTAssertEqual(UIFont.Weight("thin").rawValue, UIFont.Weight.thin.rawValue, accuracy: .high)
		XCTAssertEqual(UIFont.Weight("light").rawValue, UIFont.Weight.light.rawValue, accuracy: .high)
		XCTAssertEqual(UIFont.Weight("regular").rawValue, UIFont.Weight.regular.rawValue, accuracy: .high)
		XCTAssertEqual(UIFont.Weight("medium").rawValue, UIFont.Weight.medium.rawValue, accuracy: .high)
		XCTAssertEqual(UIFont.Weight("semibold").rawValue, UIFont.Weight.semibold.rawValue, accuracy: .high)
		XCTAssertEqual(UIFont.Weight("bold").rawValue, UIFont.Weight.bold.rawValue, accuracy: .high)
		XCTAssertEqual(UIFont.Weight("heavy").rawValue, UIFont.Weight.heavy.rawValue, accuracy: .high)
		XCTAssertEqual(UIFont.Weight("black").rawValue, UIFont.Weight.black.rawValue, accuracy: .high)
		XCTAssertEqual(UIFont.Weight(nil).rawValue, UIFont.Weight.regular.rawValue, accuracy: .high)
	}
}

private extension CGFloat {
	static let high: CGFloat = 0.01
}

