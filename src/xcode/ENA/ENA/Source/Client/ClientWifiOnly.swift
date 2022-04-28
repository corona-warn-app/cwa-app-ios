//
// 🦠 Corona-Warn-App
//

import ExposureNotification
import Foundation

protocol ClientWifiOnly {

	typealias HourCompletionHandler = (Result<PackageDownloadResponse, Client.Failure>) -> Void

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
