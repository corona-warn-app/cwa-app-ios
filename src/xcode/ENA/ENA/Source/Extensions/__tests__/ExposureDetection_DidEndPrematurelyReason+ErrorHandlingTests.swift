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
	
	func testErrorDescription() {
		XCTAssertTrue(
			Reason.noSummary(ENError(.apiMisuse)).errorDescription?.contains("EN Code: 10") == true
		)
	}
}
