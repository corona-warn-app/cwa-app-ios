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

import Foundation
import ExposureNotification

enum RiskExposureCalculation {

	/**
	Calculates the risk level of the user

	Preconditions:
	1. Check that notification exposure is turned on (via preconditions) on If not, `.inactive`
	2. Check tracingActiveDays >= 1 (needs to be active for 24hours) If not, `.unknownInitial`
	3. Check if ExposureDetectionSummaryContainer is there. If not, `.unknownInitial`
	4. Check dateLastExposureDetection is less than 24h ago. If not `.unknownOutdated`

	Everything needed for the calculation is passed in,
	no async work needed

	Until RKI formula can be implemented:
	Once all preconditions above are passed, simply use the `maximumRiskScore` from the injected `ENExposureDetectionSummaryContainer`

	- parameters:
		- summary: The lastest `ENExposureDetectionSummaryContainer`, `nil` if it does not exist
		- configuration: The latest `ENExposureConfiguration`
		- dateLastExposureDetection: The date of the most recent exposure detection
		- numberOfTracingActiveDays: A count of how many days tracing has been active for
		- preconditions: Current state of the `ExposureManager`
		- currentDate: The current `Date` to use in checks. Defaults to `Date()`
	*/
	static func riskLevel(
		summary: ENExposureDetectionSummaryContainer?,
		configuration: ENExposureConfiguration,
//		exposureDetectionValidityDuration: DateComponents,
		dateLastExposureDetection: Date?,
		numberOfTracingActiveDays: Int, // Get this from the `TracingStatusHistory`
		preconditions: ExposureManagerState,
		currentDate: Date = Date()
	) -> RiskLevel {
		var riskLevel = RiskLevel.low
		// Precondition 1 - Exposure Notifications must be turned on
		guard preconditions.isGood else {
			// This overrides all other levels
			return .inactive
		}

		// Precondition 2 - If tracing is active less than 1 day, risk is .unknownInitial
		if numberOfTracingActiveDays < 1, riskLevel < .unknownInitial {
			riskLevel = .unknownInitial
		}

		// Precondition 3 - Risk is unknownInitial if summary is not present
		if summary == nil, riskLevel < .unknownInitial {
			riskLevel = .unknownInitial
		}

		// Precondition 4 - If date of last exposure detection was not within 1 day, risk is unknownOutdated
		if
			let dateLastExposureDetection = dateLastExposureDetection,
			!dateLastExposureDetection.isWithinExposureDetectionValidInterval(from: currentDate),
			riskLevel < .unknownOutdated
		{
			riskLevel = .unknownOutdated
		}

		if let summary = summary {
			// TODO: More in-depth calculation to be done by RKI provided formula
			// TODO: Anything we need from backend?
			let calculatedLevel = RiskLevel(riskScore: summary.maximumRiskScore)
			if calculatedLevel > riskLevel {
				riskLevel = calculatedLevel
			}
		}

		return riskLevel
	}
}

extension Date {
	func isWithinExposureDetectionValidInterval(from date: Date = Date()) -> Bool {
		Calendar.current.dateComponents(
			[.day],
			from: date,
			to: self
		).day ?? .max < 1
	}
}
