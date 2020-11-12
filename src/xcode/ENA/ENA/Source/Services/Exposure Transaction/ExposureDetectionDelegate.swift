//
// 🦠 Corona-Warn-App
//

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
		completion: @escaping (ExposureDetection.DidEndPrematurelyReason?) -> Void
	)

	func exposureDetectionWriteDownloadedPackages(country: Country.ID) -> WrittenPackages?

	func exposureDetection(
		_ detection: ExposureDetection,
		detectSummaryWithConfiguration
		configuration: ENExposureConfiguration,
		writtenPackages: WrittenPackages,
		completion: @escaping DetectionHandler
	) -> Progress
}
