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
import ExposureNotification

final class ExposureDetection_DidEndPrematurelyReason_ErrorHandlingTests: XCTestCase {

	private typealias Reason = ExposureDetection.DidEndPrematurelyReason

    func testNonSummaryReasonsShouldNotReturnAnAlert() {
		let root = UIViewController()

		XCTAssertNil(Reason.noDaysAndHours.errorAlertController(rootController: root))
		XCTAssertNil(Reason.noExposureManager.errorAlertController(rootController: root))
		XCTAssertNil(Reason.noDaysAndHours.errorAlertController(rootController: root))
		XCTAssertNil(Reason.noExposureConfiguration.errorAlertController(rootController: root))
		XCTAssertNil(Reason.unableToWriteDiagnosisKeys.errorAlertController(rootController: root))
	}
	
	func testSummaryErrorCreatesAlert() {
		let root = UIViewController()
		
		XCTAssertNotNil(
			Reason.noSummary(ENError(.apiMisuse)).errorAlertController(rootController: root)
		)
	}

	// MARK: - Special ENError handling tests
	
	func testErrorDescription() {
		XCTAssertTrue(
			Reason.noSummary(ENError(.apiMisuse)).errorDescription?.contains("EN Code: 10") == true
		)
	}

	func testError_ENError_Unsupported() {
		let root = UIViewController()
		let alert = Reason.noSummary(ENError(.unsupported)).errorAlertController(rootController: root)

		XCTAssertEqual(alert?.title, AppStrings.ExposureDetectionError.errorAlertTitle)
		XCTAssertEqual(alert?.message, AppStrings.Common.enError5Description)
		XCTAssertEqual(alert?.actions.count, 2)
		XCTAssertEqual(alert?.actions[0].title, AppStrings.Common.alertActionOk)
		XCTAssertEqual(alert?.actions[1].title, AppStrings.Common.errorAlertActionMoreInfo)
	}

	func testError_ENError_Internal() {
		let root = UIViewController()
		let alert = Reason.noSummary(ENError(.internal)).errorAlertController(rootController: root)

		XCTAssertEqual(alert?.title, AppStrings.ExposureDetectionError.errorAlertTitle)
		XCTAssertEqual(alert?.message, AppStrings.Common.enError11Description)
		XCTAssertEqual(alert?.actions.count, 2)
		XCTAssertEqual(alert?.actions[0].title, AppStrings.Common.alertActionOk)
		XCTAssertEqual(alert?.actions[1].title, AppStrings.Common.errorAlertActionMoreInfo)
	}

	func testError_ENError_RateLimit() {
		let root = UIViewController()
		let alert = Reason.noSummary(ENError(.rateLimited)).errorAlertController(rootController: root)

		XCTAssertEqual(alert?.title, AppStrings.ExposureDetectionError.errorAlertTitle)
		XCTAssertEqual(alert?.message, AppStrings.Common.enError13Description)
		XCTAssertEqual(alert?.actions.count, 2)
		XCTAssertEqual(alert?.actions[0].title, AppStrings.Common.alertActionOk)
		XCTAssertEqual(alert?.actions[1].title, AppStrings.Common.errorAlertActionMoreInfo)
	}

	// MARK: - ENError FAQ URL mapping tests

	func testENError_Unsupported_FAQURL() {
		XCTAssertEqual(ENError(.unsupported).faqURL, URL(string: AppStrings.Links.appFaqENError5))
	}

	func testENError_Internal_FAQURL() {
		XCTAssertEqual(ENError(.internal).faqURL, URL(string: AppStrings.Links.appFaqENError11))
	}

	func testENError_RateLimited_FAQURL() {
		XCTAssertEqual(ENError(.rateLimited).faqURL, URL(string: AppStrings.Links.appFaqENError13))
	}
}
