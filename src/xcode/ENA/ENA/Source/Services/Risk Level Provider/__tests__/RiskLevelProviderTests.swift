//
// Corona-Warn-App
//
// SAP SE and all other contributors /
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

private final class RiskLevelProviderStoreMock: RiskLevelProviderStore {
	var dateLastExposureDetection: Date?
}

final class RiskLevelProviderTests: XCTestCase {


    func testExample() throws {
		var duration = DateComponents()
		duration.day = 1

		let calendar = Calendar.current

		let lastExposureDetectionDate = calendar.date(
			byAdding: .hour,
			value: -12,
			to: Date(),
			wrappingComponents: true
		)

		let store = RiskLevelProviderStoreMock()
		store.dateLastExposureDetection = lastExposureDetectionDate

		let config = RiskLevelProvidingConfiguration(
			updateMode: .automatic,
			exposureDetectionValidityDuration: duration
		)

		let sut = RiskLevelProvider(configuration: config, store: store)

		let consumer = RiskLevelConsumer()
		let expectWillCalculateRiskLevelIn = expectation(
			description: "expect willCalculateRiskLevelIn to be called"
		)
		consumer.willCalculateRiskLevelIn = { dateComponents in
			expectWillCalculateRiskLevelIn.fulfill()
		}
		sut.observeRiskLevel(consumer)
		waitForExpectations(timeout: 1.0)
    }


}
