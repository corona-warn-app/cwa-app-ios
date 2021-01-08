////
// 🦠 Corona-Warn-App
//

import XCTest
import OpenCombine
@testable import ENA

class HomeExposureLoggingCellModelTests: XCTestCase {
	
	func testUpdateEnabledCase() {
		let homeEnabledState = makeHomeState(with: .enabled)
		runTestForState(
			state: homeEnabledState,
			expectedTitle: AppStrings.Home.activateCardOnTitle,
			expectedIcon: UIImage(named: "Icons_Risikoermittlung_25"),
			expectedAnimationImages: (0...60).compactMap({ UIImage(named: String(format: "Icons_Risikoermittlung_%02d", $0)) }),
			expectedAccessibilityIdentifier: AccessibilityIdentifiers.Home.activateCardOnTitle
		)
    }
	
	func testBluetoothOffState() {
		let homeBluetoothOffState = makeHomeState(with: .bluetoothOff)
		runTestForState(
			state: homeBluetoothOffState,
			expectedTitle: AppStrings.Home.activateCardBluetoothOffTitle,
			expectedIcon: UIImage(named: "Icons_Bluetooth_aus"),
			expectedAnimationImages: nil,
			expectedAccessibilityIdentifier: AccessibilityIdentifiers.Home.activateCardBluetoothOffTitle
		)
	}
	
	func testDisabledState() {
		let homeDisabledState = makeHomeState(with: .disabled)
		runTestForState(state: homeDisabledState)
	}
	
	func testRestrictedState() {
		let homeRestrictedState = makeHomeState(with: .restricted)
		runTestForState(state: homeRestrictedState)
	}
	
	func testNotAuthorizedState() {
		let homeNotAuthorizedState = makeHomeState(with: .notAuthorized)
		runTestForState(state: homeNotAuthorizedState)
	}
	
	func test_unknown() {
		let homeUnknownState = makeHomeState(with: .unknown)
		runTestForState(state: homeUnknownState)
	}
	
	func test_notActiveApp() {
		let homeNotActiveAppState = makeHomeState(with: .notActiveApp)
		runTestForState(state: homeNotActiveAppState)
	}

	private func runTestForState(
		state: HomeState,
		expectedTitle: String = AppStrings.Home.activateCardOffTitle,
		expectedIcon: UIImage? = UIImage(named: "Icons_Risikoermittlung_gestoppt"),
		expectedAnimationImages: [UIImage]? = nil,
		expectedAccessibilityIdentifier: String = AccessibilityIdentifiers.Home.activateCardOffTitle
	) {
		let sut = HomeExposureLoggingCellModel(state: state)
		
		let expectationTitle = expectation(description: "StateTitle")
		let expectationIcon = expectation(description: "StateIcon")
		let expectationAnimationImages = expectation(description: "AnimationImages")
		let expectationAccessibilityIdentifier = expectation(description: "AccessibilityIdentifier")

		_ = sut.$title
			.sink { recievedValue in
				XCTAssertEqual(recievedValue, expectedTitle)
				expectationTitle.fulfill()
			}
		_ = sut.$icon
			.sink { recievedValue in
				XCTAssertEqual(recievedValue, expectedIcon)
				expectationIcon.fulfill()
			}
		_ = sut.$animationImages
			.sink { recievedValue in
				XCTAssertEqual(recievedValue, expectedAnimationImages)
				expectationAnimationImages.fulfill()
			}
		_ = sut.$accessibilityIdentifier
			.sink { recievedValue in
				XCTAssertEqual(recievedValue, expectedAccessibilityIdentifier)
				expectationAccessibilityIdentifier.fulfill()
			}
		waitForExpectations(timeout: 1, handler: nil)

	}
	
	private func makeHomeState(with enState: ENStateHandler.State) -> HomeState {
		HomeState(
			store: MockTestStore(),
			riskProvider: MockRiskProvider(),
			exposureManagerState: .init(),
			enState: enState,
			exposureSubmissionService: MockExposureSubmissionService()
		)
	}
}
