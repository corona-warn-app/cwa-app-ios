//
// 🦠 Corona-Warn-App
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
