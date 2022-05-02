//
// 🦠 Corona-Warn-App
//

import Foundation

struct FetchHoursServiceHelper {

	// MARK: - Init

	init(
		restService: RestServiceProviding
	) {
		self.restService = restService
	}

	// MARK: - Internal

	func fetchHours(
		_ hours: [Int],
		day: String,
		country: String,
		completion completeWith: @escaping (HoursResult) -> Void
	) {
		var errors = [Client.Failure]()
		var buckets = [Int: PackageDownloadResponse]()
		let group = DispatchGroup()

		hours.forEach { hour in
			group.enter()
			let resource = FetchHourResource(day: day, country: country, hour: hour)
			restService.load(resource) { result in
				defer {
					group.leave()
				}
				switch result {
				case let .success(hourBucket):
					buckets[hour] = hourBucket
				case let .failure(error):
					switch error {
					case .transportationError:
						errors.append(.invalidResponse)
					case .unexpectedServerError:
						errors.append(.invalidResponse)
					case .resourceError:
						errors.append(.invalidResponse)
					case .receivedResourceError:
						errors.append(.noResponse)
					case .invalidResponse:
						errors.append(.noResponse)
					case .invalidResponseType:
						errors.append(.noResponse)
					case .fakeResponse:
						errors.append(.fakeResponse)
					default:
						Log.error("Unhandled error", error: error)
					}
				}
			}
		}

		group.notify(queue: .main) {
			completeWith(
				HoursResult(errors: errors, bucketsByHour: buckets, day: day)
			)
		}
	}


	// MARK: - Private

	private let restService: RestServiceProviding
}
