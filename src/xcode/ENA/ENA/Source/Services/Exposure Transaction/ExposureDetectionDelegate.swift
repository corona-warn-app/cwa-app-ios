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

typealias DaysAndHours = (days: [String], hours: [Int])

/// Methods required to move an exposure detection transaction forward and for consuming
/// the results of a transaction.
protocol ExposureDetectionDelegate: AnyObject {
	typealias Completion = (DaysAndHours?) -> Void
	typealias DetectionHandler = (Result<ENExposureDetectionSummary, Error>) -> Void

	func exposureDetection(
		_ detection: ExposureDetection,
		determineAvailableData completion: @escaping (DaysAndHours?) -> Void
	)

	func exposureDetection(
		_ detection: ExposureDetection,
		downloadDeltaFor remote: DaysAndHours
	) -> DaysAndHours

	func exposureDetection(
		_ detection: ExposureDetection,
		downloadAndStore delta: DaysAndHours,
		completion: @escaping (Error?) -> Void
	)

	func exposureDetection(
		_ detection: ExposureDetection,
		downloadConfiguration completion: @escaping (ENExposureConfiguration?) -> Void
	)

	func exposureDetectionWriteDownloadedPackages(_ detection: ExposureDetection) -> WrittenPackages?

	func exposureDetection(
		_ detection: ExposureDetection,
		detectSummaryWithConfiguration
		configuration: ENExposureConfiguration,
		writtenPackages: WrittenPackages,
		completion: @escaping DetectionHandler
	)
}
