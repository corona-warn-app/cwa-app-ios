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

class OnboardingInfoViewControllerTests: XCTestCase {

	func test_something() {
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

	}
}
