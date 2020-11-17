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
	typealias SupportedCountriesResult = Result<[Country], URLSession.Response.Failure>

	func exposureDetectionWriteDownloadedPackages(country: Country.ID) -> WrittenPackages?

	func detectExposureWindows(
		_ detection: ExposureDetection,
		detectSummaryWithConfiguration configuration: ENExposureConfiguration,
		writtenPackages: WrittenPackages,
		completion: @escaping (Result<[ENExposureWindow], Error>) -> Void
	) -> Progress

}
