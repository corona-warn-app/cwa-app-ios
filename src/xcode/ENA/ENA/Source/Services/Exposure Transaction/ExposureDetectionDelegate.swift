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

import ExposureNotification
import Foundation

struct DaysAndHours {
	var days: [String]
	var hours: [Int]

	static let none = DaysAndHours(
		days: [],
		hours: []
	)
}

/// Methods required to move an exposure detection transaction forward and for consuming
/// the results of a transaction.
protocol ExposureDetectionDelegate: AnyObject {
	typealias Completion = (DaysAndHours?) -> Void
	typealias DetectionHandler = (Result<ENExposureDetectionSummary, Error>) -> Void
	typealias SupportedCountriesResult = Result<[Country], URLSession.Response.Failure>

	func exposureDetection(
		country: Country.ID,
		determineAvailableData completion: @escaping (DaysAndHours?, Country.ID) -> Void
	)

	func exposureDetection(
		country: Country.ID,
		downloadDeltaFor remote: DaysAndHours
	) -> DaysAndHours

	func exposureDetection(
		country: Country.ID,
		downloadAndStore delta: DaysAndHours,
		completion: @escaping (Error?) -> Void
	)

	func exposureDetectionWriteDownloadedPackages(country: Country.ID) -> WrittenPackages?

	func exposureDetection(
		downloadConfiguration completion: @escaping (ENExposureConfiguration?) -> Void
	)

	func exposureDetection(supportedCountries completion: @escaping (SupportedCountriesResult) -> Void)

	func exposureDetection(
		_ detection: ExposureDetection,
		detectSummaryWithConfiguration
		configuration: ENExposureConfiguration,
		writtenPackages: WrittenPackages,
		completion: @escaping DetectionHandler
	) -> Progress
}
