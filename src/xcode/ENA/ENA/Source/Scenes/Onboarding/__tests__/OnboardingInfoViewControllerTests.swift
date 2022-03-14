//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class OnboardingInfoViewControllerTests: CWATestCase {

	func test_createOnboardingInfoViewController() {
		let mockExposureManager = MockExposureManager(exposureNotificationError: nil, diagnosisKeysResult: nil)
		let mockStore = MockTestStore()
		let mockClient = ClientMock()

		guard let germanCountry = Country(countryCode: "DE") else {
			XCTFail("Could not create country.")
			return
		}

		let supportedCountries = [germanCountry]

		let onboardingInfoViewController = OnboardingInfoViewController(
			pageType: .enableLoggingOfContactsPage,
			exposureManager: mockExposureManager,
			store: mockStore,
			client: mockClient,
			supportedCountries: supportedCountries,
			appConfigProvider: CachedAppConfigurationMock()
		)
		
		XCTAssertNotNil(onboardingInfoViewController, "Could not create OnboardingInfoViewController")

	}
}
