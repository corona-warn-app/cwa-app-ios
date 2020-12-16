//
// 🦠 Corona-Warn-App
//

import XCTest
import OpenCombine
@testable import ENA

class BackgroundAppRefreshViewModelTests: XCTestCase {

    func testBackgroundRefreshStatusAvailableLowPowerModeDisabled() {
		let viewModel = BackgroundAppRefreshViewModel(
			backgroundRefreshStatusProvider: MockBackgroundRefreshStatusProvider(backgroundRefreshStatus: .available),
			lowPowerModeStatusProvider: MockLowPowerModeStatusProvider(isLowPowerModeEnabled: false),
			onOpenSettings: {},
			onShare: {}
		)

		XCTAssertEqual(viewModel.backgroundAppRefreshStatusText, AppStrings.BackgroundAppRefreshSettings.Status.on)
		XCTAssertEqual(viewModel.image, UIImage(named: "Illu_Hintergrundaktualisierung_An"))
		XCTAssertNil(viewModel.infoBoxViewModel)
		XCTAssertEqual(viewModel.backgroundAppRefreshStatusAccessibilityLabel, "\(AppStrings.BackgroundAppRefreshSettings.Status.title) \(AppStrings.BackgroundAppRefreshSettings.Status.on)")
		XCTAssertEqual(viewModel.backgroundAppRefreshStatusImageAccessibilityLabel, AppStrings.BackgroundAppRefreshSettings.onImageDescription)
    }

	func testBackgroundRefreshStatusDeniedLowPowerModeDisabled() {
		let onOpenSettingsExpectation = XCTestExpectation(description: "onOpenSettings is called")
		let onOpenSettings = { onOpenSettingsExpectation.fulfill() }

		let onShareExpectation = XCTestExpectation(description: "onShare is called")
		let onShare = { onShareExpectation.fulfill() }

		let viewModel = BackgroundAppRefreshViewModel(
			backgroundRefreshStatusProvider: MockBackgroundRefreshStatusProvider(backgroundRefreshStatus: .denied),
			lowPowerModeStatusProvider: MockLowPowerModeStatusProvider(isLowPowerModeEnabled: false),
			onOpenSettings: onOpenSettings,
			onShare: onShare
		)

		XCTAssertEqual(viewModel.backgroundAppRefreshStatusText, AppStrings.BackgroundAppRefreshSettings.Status.off)
		XCTAssertEqual(viewModel.image, UIImage(named: "Illu_Hintergrundaktualisierung_Aus"))

		XCTAssertNotNil(viewModel.infoBoxViewModel)
		XCTAssertEqual(viewModel.infoBoxViewModel?.instructions.count, 2)
		XCTAssertEqual(viewModel.infoBoxViewModel?.instructions[0].steps.count, 4)
		XCTAssertEqual(viewModel.infoBoxViewModel?.instructions[1].steps.count, 3)
		XCTAssertEqual(viewModel.infoBoxViewModel?.descriptionText, AppStrings.BackgroundAppRefreshSettings.InfoBox.description)

		viewModel.infoBoxViewModel?.settingsAction()
		viewModel.infoBoxViewModel?.shareAction()
		wait(for: [onOpenSettingsExpectation, onShareExpectation], timeout: 3.0)

		XCTAssertEqual(viewModel.backgroundAppRefreshStatusAccessibilityLabel, "\(AppStrings.BackgroundAppRefreshSettings.Status.title) \(AppStrings.BackgroundAppRefreshSettings.Status.off)")
		XCTAssertEqual(viewModel.backgroundAppRefreshStatusImageAccessibilityLabel, AppStrings.BackgroundAppRefreshSettings.offImageDescription)
    }

	func testBackgroundRefreshStatusDeniedLowPowerModeEnabled() {
		let onOpenSettingsExpectation = XCTestExpectation(description: "onOpenSettings is called")
		let onOpenSettings = { onOpenSettingsExpectation.fulfill() }

		let onShareExpectation = XCTestExpectation(description: "onShare is called")
		let onShare = { onShareExpectation.fulfill() }

		let viewModel = BackgroundAppRefreshViewModel(
			backgroundRefreshStatusProvider: MockBackgroundRefreshStatusProvider(backgroundRefreshStatus: .denied),
			lowPowerModeStatusProvider: MockLowPowerModeStatusProvider(isLowPowerModeEnabled: true),
			onOpenSettings: onOpenSettings,
			onShare: onShare
		)

		XCTAssertEqual(viewModel.backgroundAppRefreshStatusText, AppStrings.BackgroundAppRefreshSettings.Status.off)
		XCTAssertEqual(viewModel.image, UIImage(named: "Illu_Hintergrundaktualisierung_Aus"))

		XCTAssertNotNil(viewModel.infoBoxViewModel)
		XCTAssertEqual(viewModel.infoBoxViewModel?.instructions.count, 3)
		XCTAssertEqual(viewModel.infoBoxViewModel?.instructions[0].steps.count, 3)
		XCTAssertEqual(viewModel.infoBoxViewModel?.instructions[1].steps.count, 4)
		XCTAssertEqual(viewModel.infoBoxViewModel?.instructions[2].steps.count, 3)
		XCTAssertEqual(viewModel.infoBoxViewModel?.descriptionText, AppStrings.BackgroundAppRefreshSettings.InfoBox.description + "\n\n" + AppStrings.BackgroundAppRefreshSettings.InfoBox.lowPowerModeDescription)

		viewModel.infoBoxViewModel?.settingsAction()
		viewModel.infoBoxViewModel?.shareAction()
		wait(for: [onOpenSettingsExpectation, onShareExpectation], timeout: 3.0)

		XCTAssertEqual(viewModel.backgroundAppRefreshStatusAccessibilityLabel, "\(AppStrings.BackgroundAppRefreshSettings.Status.title) \(AppStrings.BackgroundAppRefreshSettings.Status.off)")
		XCTAssertEqual(viewModel.backgroundAppRefreshStatusImageAccessibilityLabel, AppStrings.BackgroundAppRefreshSettings.offImageDescription)
    }

    func testBackgroundRefreshStatusTextChangeForBackgroundRefreshStatusChangeFromAvailableToDeniedWithLowPowerModeDisabled() {
		let mockBackgroundRefreshStatusProvider = MockBackgroundRefreshStatusProvider(backgroundRefreshStatus: .available)
		let viewModel = BackgroundAppRefreshViewModel(
			backgroundRefreshStatusProvider: mockBackgroundRefreshStatusProvider,
			lowPowerModeStatusProvider: MockLowPowerModeStatusProvider(isLowPowerModeEnabled: false),
			onOpenSettings: {},
			onShare: {}
		)

		let expectedValues = [
			AppStrings.BackgroundAppRefreshSettings.Status.on,
			AppStrings.BackgroundAppRefreshSettings.Status.off
		]
		let expectation = XCTestExpectation(description: "backgroundAppRefreshStatusText changed")
		expectation.expectedFulfillmentCount = expectedValues.count

		var receivedValues = [String]()
		let subscription = viewModel.$backgroundAppRefreshStatusText.receive(on: RunLoop.main.ocombine).sink {
			receivedValues.append($0)
			expectation.fulfill()
		}

		mockBackgroundRefreshStatusProvider.backgroundRefreshStatus = .denied
		NotificationCenter.default.post(name: UIApplication.backgroundRefreshStatusDidChangeNotification, object: nil)

		wait(for: [expectation], timeout: 3.0)

		subscription.cancel()

		XCTAssertEqual(receivedValues, expectedValues)
    }

    func testBackgroundRefreshStatusAccessibilityLabelChangeForBackgroundRefreshStatusChangeFromAvailableToDeniedWithLowPowerModeDisabled() {
		let mockBackgroundRefreshStatusProvider = MockBackgroundRefreshStatusProvider(backgroundRefreshStatus: .available)
		let viewModel = BackgroundAppRefreshViewModel(
			backgroundRefreshStatusProvider: mockBackgroundRefreshStatusProvider,
			lowPowerModeStatusProvider: MockLowPowerModeStatusProvider(isLowPowerModeEnabled: false),
			onOpenSettings: {},
			onShare: {}
		)

		let expectedValues = [
			"\(AppStrings.BackgroundAppRefreshSettings.Status.title) \(AppStrings.BackgroundAppRefreshSettings.Status.on)",
			"\(AppStrings.BackgroundAppRefreshSettings.Status.title) \(AppStrings.BackgroundAppRefreshSettings.Status.off)"
		]
		let expectation = XCTestExpectation(description: "backgroundAppRefreshStatusAccessibilityLabel changed")
		expectation.expectedFulfillmentCount = expectedValues.count

		var receivedValues = [String]()
		let subscription = viewModel.$backgroundAppRefreshStatusAccessibilityLabel.receive(on: RunLoop.main.ocombine).sink {
			receivedValues.append($0)
			expectation.fulfill()
		}

		mockBackgroundRefreshStatusProvider.backgroundRefreshStatus = .denied
		NotificationCenter.default.post(name: UIApplication.backgroundRefreshStatusDidChangeNotification, object: nil)

		wait(for: [expectation], timeout: 3.0)

		subscription.cancel()

		XCTAssertEqual(receivedValues, expectedValues)
    }
	
    func testBackgroundRefreshStatusImageAccessibilityLabelChangeForBackgroundRefreshStatusChangeFromAvailableToDeniedWithLowPowerModeDisabled() {
		let mockBackgroundRefreshStatusProvider = MockBackgroundRefreshStatusProvider(backgroundRefreshStatus: .available)
		let viewModel = BackgroundAppRefreshViewModel(
			backgroundRefreshStatusProvider: mockBackgroundRefreshStatusProvider,
			lowPowerModeStatusProvider: MockLowPowerModeStatusProvider(isLowPowerModeEnabled: false),
			onOpenSettings: {},
			onShare: {}
		)

		let expectedValues = [
			AppStrings.BackgroundAppRefreshSettings.onImageDescription,
			AppStrings.BackgroundAppRefreshSettings.offImageDescription
		]
		let expectation = XCTestExpectation(description: "backgroundAppRefreshStatusImageAccessibilityLabel changed")
		expectation.expectedFulfillmentCount = expectedValues.count

		var receivedValues = [String]()
		let subscription = viewModel.$backgroundAppRefreshStatusImageAccessibilityLabel.receive(on: RunLoop.main.ocombine).sink {
			receivedValues.append($0)
			expectation.fulfill()
		}

		mockBackgroundRefreshStatusProvider.backgroundRefreshStatus = .denied
		NotificationCenter.default.post(name: UIApplication.backgroundRefreshStatusDidChangeNotification, object: nil)

		wait(for: [expectation], timeout: 3.0)

		subscription.cancel()

		XCTAssertEqual(receivedValues, expectedValues)
    }

    func testImageChangeForBackgroundRefreshStatusChangeFromAvailableToDeniedWithLowPowerModeDisabled() {
		let mockBackgroundRefreshStatusProvider = MockBackgroundRefreshStatusProvider(backgroundRefreshStatus: .available)
		let viewModel = BackgroundAppRefreshViewModel(
			backgroundRefreshStatusProvider: mockBackgroundRefreshStatusProvider,
			lowPowerModeStatusProvider: MockLowPowerModeStatusProvider(isLowPowerModeEnabled: false),
			onOpenSettings: {},
			onShare: {}
		)

		let expectedValues = [
			UIImage(named: "Illu_Hintergrundaktualisierung_An"),
			UIImage(named: "Illu_Hintergrundaktualisierung_Aus")
		]
		let expectation = XCTestExpectation(description: "image changed")
		expectation.expectedFulfillmentCount = expectedValues.count

		var receivedValues = [UIImage?]()
		let subscription = viewModel.$image.receive(on: RunLoop.main.ocombine).sink {
			receivedValues.append($0)
			expectation.fulfill()
		}

		mockBackgroundRefreshStatusProvider.backgroundRefreshStatus = .denied
		NotificationCenter.default.post(name: UIApplication.backgroundRefreshStatusDidChangeNotification, object: nil)

		wait(for: [expectation], timeout: 3.0)

		subscription.cancel()

		XCTAssertEqual(receivedValues, expectedValues)
    }

    func testInfoBoxViewModelChangeForBackgroundRefreshStatusChangeFromAvailableToDeniedWithLowPowerModeDisabled() {
		let mockBackgroundRefreshStatusProvider = MockBackgroundRefreshStatusProvider(backgroundRefreshStatus: .available)
		let viewModel = BackgroundAppRefreshViewModel(
			backgroundRefreshStatusProvider: mockBackgroundRefreshStatusProvider,
			lowPowerModeStatusProvider: MockLowPowerModeStatusProvider(isLowPowerModeEnabled: false),
			onOpenSettings: {},
			onShare: {}
		)

		let expectedValues = [
			nil,
			2
		]
		let expectation = XCTestExpectation(description: "image changed")
		expectation.expectedFulfillmentCount = expectedValues.count

		var receivedValues = [Int?]()
		let subscription = viewModel.$infoBoxViewModel.receive(on: RunLoop.main.ocombine).sink {
			receivedValues.append($0?.instructions.count)
			expectation.fulfill()
		}

		mockBackgroundRefreshStatusProvider.backgroundRefreshStatus = .denied
		NotificationCenter.default.post(name: UIApplication.backgroundRefreshStatusDidChangeNotification, object: nil)

		wait(for: [expectation], timeout: 3.0)

		subscription.cancel()

		XCTAssertEqual(receivedValues, expectedValues)
    }

    func testInfoBoxViewModelChangeForBackgroundRefreshStatusDeniedWithLowPowerModeChangeFromDisabledToEnabled() {
		let mockLowPowerModeStatusProvider = MockLowPowerModeStatusProvider(isLowPowerModeEnabled: false)
		let viewModel = BackgroundAppRefreshViewModel(
			backgroundRefreshStatusProvider: MockBackgroundRefreshStatusProvider(backgroundRefreshStatus: .denied),
			lowPowerModeStatusProvider: mockLowPowerModeStatusProvider,
			onOpenSettings: {},
			onShare: {}
		)

		let expectedValues = [
			2,
			3
		]
		let expectation = XCTestExpectation(description: "image changed")
		expectation.expectedFulfillmentCount = expectedValues.count

		var receivedValues = [Int?]()
		let subscription = viewModel.$infoBoxViewModel.receive(on: RunLoop.main.ocombine).sink {
			receivedValues.append($0?.instructions.count)
			expectation.fulfill()
		}

		mockLowPowerModeStatusProvider.isLowPowerModeEnabled = true
		NotificationCenter.default.post(name: Notification.Name.NSProcessInfoPowerStateDidChange, object: nil)

		wait(for: [expectation], timeout: 3.0)

		subscription.cancel()

		XCTAssertEqual(receivedValues, expectedValues)
    }

    func testInfoBoxViewModelChangeForBackgroundRefreshStatusAvailableWithLowPowerModeChangeFromDisabledToEnabled() {
		let mockLowPowerModeStatusProvider = MockLowPowerModeStatusProvider(isLowPowerModeEnabled: false)
		let viewModel = BackgroundAppRefreshViewModel(
			backgroundRefreshStatusProvider: MockBackgroundRefreshStatusProvider(backgroundRefreshStatus: .available),
			lowPowerModeStatusProvider: mockLowPowerModeStatusProvider,
			onOpenSettings: {},
			onShare: {}
		)

		let expectedValues: [Int?] = [
			nil,
			nil
		]
		let expectation = XCTestExpectation(description: "image changed")
		expectation.expectedFulfillmentCount = expectedValues.count

		var receivedValues = [Int?]()
		let subscription = viewModel.$infoBoxViewModel.receive(on: RunLoop.main.ocombine).sink {
			receivedValues.append($0?.instructions.count)
			expectation.fulfill()
		}

		mockLowPowerModeStatusProvider.isLowPowerModeEnabled = true
		NotificationCenter.default.post(name: Notification.Name.NSProcessInfoPowerStateDidChange, object: nil)

		wait(for: [expectation], timeout: 3.0)

		subscription.cancel()

		XCTAssertEqual(receivedValues, expectedValues)
    }

}
