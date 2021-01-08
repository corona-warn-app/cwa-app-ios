////
// 🦠 Corona-Warn-App
//

import XCTest
import OpenCombine
@testable import ENA

class HomeExposureLoggingCellModelTests: XCTestCase {
	
	func test_whenHomeENStateChanges_then_changesAreReflectedInTheSubscription() {
		
		let expectationTitles = expectation(description: "StateTitle")
		let expectationIcons = expectation(description: "StateIcon")
		let expectationAnimationImages = expectation(description: "AnimationImages")
		let expectationAccessibilityIdentifiers = expectation(description: "AccessibilityIdentifier")
		
		let titlesArray = [
			AppStrings.Home.activateCardOnTitle,
			AppStrings.Home.activateCardBluetoothOffTitle,
			AppStrings.Home.activateCardOffTitle,
			AppStrings.Home.activateCardOffTitle,
			AppStrings.Home.activateCardOffTitle,
			AppStrings.Home.activateCardOffTitle,
			AppStrings.Home.activateCardOffTitle
		]
		let iconsArray = [
			UIImage(named: "Icons_Risikoermittlung_25"),
			UIImage(named: "Icons_Bluetooth_aus"),
			UIImage(named: "Icons_Risikoermittlung_gestoppt"),
			UIImage(named: "Icons_Risikoermittlung_gestoppt"),
			UIImage(named: "Icons_Risikoermittlung_gestoppt"),
			UIImage(named: "Icons_Risikoermittlung_gestoppt"),
			UIImage(named: "Icons_Risikoermittlung_gestoppt")
		]
		
		let animationImagesArray = [(0...60).compactMap({ UIImage(named: String(format: "Icons_Risikoermittlung_%02d", $0)) }), nil, nil, nil, nil, nil, nil]
		let accessabilityIdentifiersArray = [
			AccessibilityIdentifiers.Home.activateCardOnTitle,
			AccessibilityIdentifiers.Home.activateCardBluetoothOffTitle,
			AccessibilityIdentifiers.Home.activateCardOffTitle,
			AccessibilityIdentifiers.Home.activateCardOffTitle,
			AccessibilityIdentifiers.Home.activateCardOffTitle,
			AccessibilityIdentifiers.Home.activateCardOffTitle,
			AccessibilityIdentifiers.Home.activateCardOffTitle
		]
		
		var recievedTitleValues = [String?]()
		var recievedIconsArray = [UIImage?]()
		var recievedAnimationImages = [[UIImage]?]()
		var recievedAccessibilityIdentifiers = [String?]()
		
		expectationTitles.expectedFulfillmentCount = titlesArray.count
		expectationIcons.expectedFulfillmentCount = iconsArray.count
		expectationAnimationImages.expectedFulfillmentCount = animationImagesArray.count
		expectationAccessibilityIdentifiers.expectedFulfillmentCount = accessabilityIdentifiersArray.count

		let state = makeHomeState(with: .enabled)
		let sut = HomeExposureLoggingCellModel(state: state)
		
		let titlesSubscription = sut.$title
			.sink { recievedValue in
				recievedTitleValues.append(recievedValue)
				expectationTitles.fulfill()
			}
		let iconsSubscription = sut.$icon
			.sink { recievedValue in
				recievedIconsArray.append(recievedValue)
				expectationIcons.fulfill()
			}
		let animationsSubscription = sut.$animationImages
			.sink { recievedValue in
				recievedAnimationImages.append(recievedValue)
				expectationAnimationImages.fulfill()
			}
		let accessabilityIdentifiersSubscription = sut.$accessibilityIdentifier
			.sink { recievedValue in
				recievedAccessibilityIdentifiers.append(recievedValue)
				expectationAccessibilityIdentifiers.fulfill()
			}

		state.enState = .bluetoothOff
		state.enState = .disabled
		state.enState = .restricted
		state.enState = .notActiveApp
		state.enState = .notAuthorized
		state.enState = .unknown
		
		waitForExpectations(timeout: 1, handler: nil)
		titlesSubscription.cancel()
		iconsSubscription.cancel()
		animationsSubscription.cancel()
		accessabilityIdentifiersSubscription.cancel()

		XCTAssertEqual(recievedTitleValues, titlesArray)
		XCTAssertEqual(recievedIconsArray, iconsArray)
		XCTAssertEqual(recievedAnimationImages, animationImagesArray)
		XCTAssertEqual(recievedAccessibilityIdentifiers, accessabilityIdentifiersArray)
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
