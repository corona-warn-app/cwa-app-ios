//
// 🦠 Corona-Warn-App
//

import ExposureNotification
import Foundation

protocol ClientWifiOnly {

	typealias HourCompletionHandler = (Result<PackageDownloadResponse, Client.Failure>) -> Void
	typealias AvailableHoursCompletionHandler = (Result<[Int], Client.Failure>) -> Void

	/// Determines hours that can be downloaded for a given day.
	func availableHours(
		day: String,
		country: String,
		completion: @escaping AvailableHoursCompletionHandler
	)

	/// Fetches the keys for a given `hour` of a specific `day`.
	func fetchHour(
		_ hour: Int,
		day: String,
		country: String,
		completion: @escaping HourCompletionHandler
	)

	func fetchHours(
		_ hours: [Int],
		day: String,
		country: String,
		completion completeWith: @escaping (HoursResult) -> Void
	)

}
