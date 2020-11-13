//
// 🦠 Corona-Warn-App
//

@testable import ENA
import ExposureNotification
import XCTest

final class ENStateTests: XCTestCase {

	var stateHandler: ENStateHandler!
	var exposureManagerState: ExposureManagerState!
	let mockStateHandler = MockStateHandlerObserverDelegate()
	
	// setup stateHandler to be in enabled state
	override func setUp() {
		super.setUp()
		exposureManagerState = ExposureManagerState(authorized: true, enabled: true, status: .active)
		stateHandler = ENStateHandler(
				initialExposureManagerState: exposureManagerState,
				delegate: mockStateHandler
		)

	}

	// MARK: Enable/Disable State Tests

	// statehandler should reflect enabled state after setup
	func testInitialState() {
		XCTAssertEqual(stateHandler.state, .enabled)
	}

	// statehandler should reflect disabled state
	func testDisableTracing() {
		XCTAssertEqual(stateHandler.state, .enabled)
		exposureManagerState = ExposureManagerState(authorized: true, enabled: false, status: .disabled)
		stateHandler.updateExposureState(exposureManagerState)
		XCTAssertEqual(stateHandler.state, .disabled)
	}

	// MARK: Bluetooth State Tests

	// when statehandler is enabled bluetooth is turnedOff statehandler should be bluetooth off
	func testTurnOffBluetooth() {
		XCTAssertEqual(stateHandler.state, .enabled)
		exposureManagerState = ExposureManagerState(authorized: true, enabled: true, status: .bluetoothOff)
		stateHandler.updateExposureState(exposureManagerState)
		XCTAssertEqual(stateHandler.state, .bluetoothOff)
	}

	// MARK: Tests with combined state changes

	func testDisableTracingAndBluetoothOff() {
		XCTAssertEqual(stateHandler.state, .enabled)
		exposureManagerState = ExposureManagerState(authorized: true, enabled: false, status: .bluetoothOff)
		stateHandler.updateExposureState(exposureManagerState)
		XCTAssertEqual(stateHandler.state, .disabled)
	}

	func testDisableTracingAndBluetoothOn() {
		XCTAssertEqual(stateHandler.state, .enabled)
		exposureManagerState = ExposureManagerState(authorized: true, enabled: false, status: .disabled)
		stateHandler.updateExposureState(exposureManagerState)
		XCTAssertEqual(stateHandler.state, .disabled)
	}

	func testEnableTracingStepByStep() {
		XCTAssertEqual(stateHandler.state, .enabled)
		exposureManagerState = ExposureManagerState(authorized: true, enabled: false, status: .bluetoothOff)
		stateHandler.updateExposureState(exposureManagerState)
		exposureManagerState = ExposureManagerState(authorized: true, enabled: true, status: .bluetoothOff)
		stateHandler.updateExposureState(exposureManagerState)
		XCTAssertEqual(stateHandler.state, .bluetoothOff)
		exposureManagerState = ExposureManagerState(authorized: true, enabled: true, status: .active)
		stateHandler.updateExposureState(exposureManagerState)
		XCTAssertEqual(stateHandler.state, .enabled)
	}

	// MARK: Tests different ENStatus states

	func testRestrictedState() {
		exposureManagerState = ExposureManagerState(authorized: false, enabled: false, status: .restricted)
		stateHandler.updateExposureState(exposureManagerState)
		switch ENManager.authorizationStatus {
		case .notAuthorized:
			XCTAssertEqual(stateHandler.state, .notAuthorized)
		case .restricted:
			XCTAssertEqual(stateHandler.state, .restricted)
		case .unknown:
			XCTAssertEqual(stateHandler.state, .unknown)
		case .authorized:
			XCTAssertEqual(stateHandler.state, .notActiveApp)
		@unknown default:
			fatalError("Not all cases handled by Test cases of ENStateHandler")
		}

	}

	func testUnknownState() {
		exposureManagerState = ExposureManagerState(authorized: false, enabled: false, status: .unknown)
		stateHandler.updateExposureState(exposureManagerState)
		XCTAssertEqual(stateHandler.state, .disabled)
	}
}
