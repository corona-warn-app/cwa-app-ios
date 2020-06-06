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

@testable import ENA
import ExposureNotification
import XCTest

final class ENStateTests: XCTestCase {

	var stateHandler: ENStateHandler!
	var exposureManagerState: ExposureManagerState!
	lazy var mockReachabilityService = MockReachabilityService()
	let mockStateHandler = MockStateHandlerObserverDelegate()
	
	// setup stateHandler to be in enabled state
	override func setUp() {
		super.setUp()
		exposureManagerState = ExposureManagerState(authorized: true, enabled: true, status: .active)

		stateHandler = ENStateHandler(
				initialExposureManagerState: exposureManagerState,
				reachabilityService: self.mockReachabilityService,
				delegate: mockStateHandler
		)

	}

	override func tearDown() {
		super.tearDown()
	}

	// MARK: Enable/Disable State Tests

	// statehandler should reflect enabled state after setup
	func testInitialState() {
		XCTAssert(stateHandler.state == .enabled)
	}

	// statehandler should reflect disabled state
	func testDisableTracing() {
		XCTAssert(stateHandler.state == .enabled)
		exposureManagerState = ExposureManagerState(authorized: true, enabled: false, status: .disabled)
		stateHandler.updateExposureState(exposureManagerState)
		XCTAssert(stateHandler.state == .disabled)
	}

	// MARK: Bluetooth State Tests

	// when statehandler is enabled bluetooth is turnedOff statehandler should be bluetooth off
	func testTurnOffBluetooth() {
		XCTAssert(stateHandler.state == .enabled)
		exposureManagerState = ExposureManagerState(authorized: true, enabled: true, status: .bluetoothOff)
		stateHandler.updateExposureState(exposureManagerState)
		XCTAssert(stateHandler.state == .bluetoothOff)
	}

	// MARK: Internet State Tests

	// when internet is turned off and turned on again
	func testTurnOffTurnOnInternet() {
		exposureManagerState = ExposureManagerState(authorized: true, enabled: true, status: .active)
		stateHandler.updateExposureState(exposureManagerState)
		XCTAssert(stateHandler.state == .enabled)
		self.mockReachabilityService.reachabilityState = .disconnected
		XCTAssert(stateHandler.state == .internetOff)
		self.mockReachabilityService.reachabilityState = .connected
		XCTAssert(stateHandler.state == .enabled)
	}

	// MARK: Tests with combined state changes

	func testDisableTracingAndBluetoothOff() {
		XCTAssert(stateHandler.state == .enabled)
		exposureManagerState = ExposureManagerState(authorized: true, enabled: false, status: .bluetoothOff)
		stateHandler.updateExposureState(exposureManagerState)
		XCTAssert(stateHandler.state == .disabled)
	}

	func testDisableTracingAndBluetoothOffAndInternetOff() {
		XCTAssert(stateHandler.state == .enabled)
		self.mockReachabilityService.reachabilityState = .disconnected
		XCTAssert(stateHandler.state == .internetOff)
		exposureManagerState = ExposureManagerState(authorized: true, enabled: false, status: .bluetoothOff)
		stateHandler.updateExposureState(exposureManagerState)
		XCTAssert(stateHandler.state == .disabled)
	}

	func testDisableTracingAndBluetoothOnAndInternetOn() {
		XCTAssert(stateHandler.state == .enabled)
		exposureManagerState = ExposureManagerState(authorized: true, enabled: false, status: .disabled)
		stateHandler.updateExposureState(exposureManagerState)
		self.mockReachabilityService.reachabilityState = .disconnected
		XCTAssert(stateHandler.state == .disabled)
		self.mockReachabilityService.reachabilityState = .connected
		XCTAssert(stateHandler.state == .disabled)
	}

	func testEnableTracingStepByStep() {
		XCTAssert(stateHandler.state == .enabled)
		exposureManagerState = ExposureManagerState(authorized: true, enabled: false, status: .bluetoothOff)
		stateHandler.updateExposureState(exposureManagerState)
		self.mockReachabilityService.reachabilityState = .disconnected
		XCTAssert(stateHandler.state == .disabled)
		exposureManagerState = ExposureManagerState(authorized: true, enabled: true, status: .bluetoothOff)
		stateHandler.updateExposureState(exposureManagerState)
		XCTAssert(stateHandler.state == .bluetoothOff)
		exposureManagerState = ExposureManagerState(authorized: true, enabled: true, status: .active)
		stateHandler.updateExposureState(exposureManagerState)
		XCTAssert(stateHandler.state == .internetOff)
		self.mockReachabilityService.reachabilityState = .connected
		XCTAssert(stateHandler.state == .enabled)
	}

	// MARK: Tests different ENStatus states

	func testRestrictedState() {
		exposureManagerState = ExposureManagerState(authorized: false, enabled: false, status: .restricted)
		stateHandler.updateExposureState(exposureManagerState)
		XCTAssert(stateHandler.state == .restricted)
	}

	func testUnknownState() {
		exposureManagerState = ExposureManagerState(authorized: false, enabled: false, status: .unknown)
		stateHandler.updateExposureState(exposureManagerState)
		XCTAssert(stateHandler.state == .disabled)
	}
}
