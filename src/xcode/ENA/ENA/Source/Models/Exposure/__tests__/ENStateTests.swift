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
	var mockDelegate: MockStateHandlerObserverDelegate!
	var exposureManagerState: ExposureManagerState!

	// setup stateHandler to be in enabled state
	override func setUp() {
		super.setUp()
		exposureManagerState = ExposureManagerState(authorized: true, enabled: true, status: .active)
		mockDelegate = MockStateHandlerObserverDelegate(exposureManagerState: exposureManagerState)
	}

	override func tearDown() {
		super.tearDown()
	}

	// MARK: Enable/Disable State Tests

	// statehandler should reflect enabled state after setup
	func testInitialState() {
		XCTAssert(mockDelegate.getCurrentState() == .enabled)
	}

	// statehandler should reflect disabled state
	func testDisableTracing() {
		XCTAssert(mockDelegate.getCurrentState() == .enabled)
		exposureManagerState = ExposureManagerState(authorized: true, enabled: false, status: .disabled)
		mockDelegate.exposureManagerState = exposureManagerState
		XCTAssert(mockDelegate.getCurrentState() == .disabled)
	}

	// MARK: Bluetooth State Tests

	// when statehandler is enabled bluetooth is turnedOff statehandler should be bluetooth off
	func testTurnOffBluetooth() {
		XCTAssert(mockDelegate.getCurrentState() == .enabled)
		exposureManagerState = ExposureManagerState(authorized: true, enabled: true, status: .bluetoothOff)
		mockDelegate.exposureManagerState = exposureManagerState
		XCTAssert(mockDelegate.getCurrentState() == .bluetoothOff)
	}

	// MARK: Internet State Tests

	// when internet is turned off and turned on again
	func testTurnOffTurnOnInternet() {
		exposureManagerState = ExposureManagerState(authorized: true, enabled: true, status: .active)
		mockDelegate.exposureManagerState = exposureManagerState
		XCTAssert(mockDelegate.getCurrentState() == .enabled)
		mockDelegate.reachabilityChanged(false)
		XCTAssert(mockDelegate.getCurrentState() == .internetOff)
		mockDelegate.reachabilityChanged(true)
		XCTAssert(mockDelegate.getCurrentState() == .enabled)
	}

	// MARK: Tests with combined state changes

	func testDisableTracingAndBluetoothOff() {
		XCTAssert(mockDelegate.getCurrentState() == .enabled)
		exposureManagerState = ExposureManagerState(authorized: true, enabled: false, status: .bluetoothOff)
		mockDelegate.exposureManagerState = exposureManagerState
		XCTAssert(mockDelegate.getCurrentState() == .disabled)
	}

	func testDisableTracingAndBluetoothOffAndInternetOff() {
		XCTAssert(mockDelegate.getCurrentState() == .enabled)
		mockDelegate.reachabilityChanged(false)
		XCTAssert(mockDelegate.getCurrentState() == .internetOff)
		exposureManagerState = ExposureManagerState(authorized: true, enabled: false, status: .bluetoothOff)
		mockDelegate.exposureManagerState = exposureManagerState
		XCTAssert(mockDelegate.getCurrentState() == .disabled)
	}

	func testDisableTracingAndBluetoothOnAndInternetOn() {
		XCTAssert(mockDelegate.getCurrentState() == .enabled)
		exposureManagerState = ExposureManagerState(authorized: true, enabled: false, status: .disabled)
		mockDelegate.exposureManagerState = exposureManagerState
		mockDelegate.reachabilityChanged(false)
		XCTAssert(mockDelegate.getCurrentState() == .disabled)
		mockDelegate.reachabilityChanged(true)
		XCTAssert(mockDelegate.getCurrentState() == .disabled)
	}

	func testEnableTracingStepByStep() {
		XCTAssert(mockDelegate.getCurrentState() == .enabled)
		exposureManagerState = ExposureManagerState(authorized: true, enabled: false, status: .bluetoothOff)
		mockDelegate.exposureManagerState = exposureManagerState
		mockDelegate.reachabilityChanged(false)
		XCTAssert(mockDelegate.getCurrentState() == .disabled)
		exposureManagerState = ExposureManagerState(authorized: true, enabled: true, status: .bluetoothOff)
		mockDelegate.exposureManagerState = exposureManagerState
		XCTAssert(mockDelegate.getCurrentState() == .bluetoothOff)
		exposureManagerState = ExposureManagerState(authorized: true, enabled: true, status: .active)
		mockDelegate.exposureManagerState = exposureManagerState
		XCTAssert(mockDelegate.getCurrentState() == .internetOff)
		mockDelegate.reachabilityChanged(true)
		XCTAssert(mockDelegate.getCurrentState() == .enabled)
	}

	// MARK: Tests different ENStatus states

	func testRestrictedState() {
		exposureManagerState = ExposureManagerState(authorized: false, enabled: false, status: .restricted)
		mockDelegate.exposureManagerState = exposureManagerState
		XCTAssert(mockDelegate.getCurrentState() == .restricted)
	}

	func testUnknownState() {
		exposureManagerState = ExposureManagerState(authorized: false, enabled: false, status: .unknown)
		mockDelegate.exposureManagerState = exposureManagerState
		XCTAssert(mockDelegate.getCurrentState() == .disabled)
	}
}
