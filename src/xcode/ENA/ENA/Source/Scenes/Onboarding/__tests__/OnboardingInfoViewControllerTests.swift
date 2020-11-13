//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class OnboardingInfoViewControllerTests: XCTestCase {

	func test_createOnboardingInfoViewController() {
		let storyboard = AppStoryboard.onboarding.instance
		let mockExposureManager = MockExposureManager(exposureNotificationError: nil, diagnosisKeysResult: nil)
		let mockStore = MockTestStore()
		let mockClient = ClientMock()

		guard let germanCountry = Country(countryCode: "DE") else {
			XCTFail("Could not create country.")
			return
		}

		let supportedCountries = [germanCountry]

		let onboardingInfoViewController = storyboard.instantiateInitialViewController { coder in
			OnboardingInfoViewController(
				coder: coder,
				pageType: .enableLoggingOfContactsPage,
				exposureManager: mockExposureManager,
				store: mockStore,
				client: mockClient,
				supportedCountries: supportedCountries
			)
		}
		
		XCTAssertNotNil(onboardingInfoViewController, "Could not create OnboardingInfoViewController")

	}
}
