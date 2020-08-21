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

final class SettingsViewModelTests: XCTestCase {
    func testStateIsNilInitially() {
		XCTAssertNil(SettingsViewModel().notifications.state)
		XCTAssertNil(SettingsViewModel().tracing.state)
    }

	func testSetStateWorks() {
		let model = SettingsViewModel()
		
		model.notifications.setState(state: true)
		XCTAssertEqual(model.notifications.state, model.notifications.stateActive)
		XCTAssertNil(model.tracing.state)

		model.tracing.setState(state: true)
		XCTAssertEqual(model.notifications.state, model.notifications.stateActive)
		XCTAssertEqual(model.tracing.state, model.tracing.stateActive)

		model.notifications.setState(state: true)
		XCTAssertEqual(model.notifications.state, model.notifications.stateActive)
		XCTAssertEqual(model.tracing.state, model.tracing.stateActive)
	}
}
