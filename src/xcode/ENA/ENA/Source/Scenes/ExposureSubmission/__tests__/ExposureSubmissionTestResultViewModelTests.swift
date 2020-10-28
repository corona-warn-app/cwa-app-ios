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

class ExposureSubmissionTestResultViewModelTests: XCTestCase {

	func testDeletionClosures() {
		let serviceDeleteTestCalledExpectation = expectation(description: "deleteTest on exposure submission service is called")

		let exposureSubmissionService = MockExposureSubmissionService()
		exposureSubmissionService.deleteTestCallback = { serviceDeleteTestCalledExpectation.fulfill() }

		let onTestDeletedCalledExpectation = expectation(description: "onTestDeleted closure is called")

		let model = ExposureSubmissionTestResultViewModel(
			testResult: .expired,
			exposureSubmissionService: exposureSubmissionService,
			onContinueWithSymptomsFlowButtonTap: { _ in },
			onContinueWithoutSymptomsFlowButtonTap: { _ in },
			onTestDeleted: { onTestDeletedCalledExpectation.fulfill() }
		)

		model.deleteTest()

		waitForExpectations(timeout: .short)
	}

}
