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

private extension UITraitCollection {
	class func lightStyle() -> UITraitCollection { .init(userInterfaceStyle: .light) }
	class func darkStyle() -> UITraitCollection { .init(userInterfaceStyle: .dark) }
	class func unspecifiedStyle() -> UITraitCollection { .init(userInterfaceStyle: .unspecified) }

}

final class UIColor_HomeBackgroundColorTests: XCTestCase {
    func testIsDynamic() throws {
		let sut = UIColor.homeBackgroundColor()
		let expectedDark = UIColor
			.enaColor(for: .separator)
			.resolvedColor(with: .darkStyle())

		XCTAssertEqual(
			sut.resolvedColor(with: .lightStyle()),
			.enaColor(for: .background)
		)

		XCTAssertEqual(
			sut.resolvedColor(with: .darkStyle()),
			expectedDark
		)

		// falls back to light
		XCTAssertEqual(
			sut.resolvedColor(with: .unspecifiedStyle()),
			.enaColor(for: .background)
		)
    }
}
