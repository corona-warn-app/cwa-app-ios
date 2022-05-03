//
// 🦠 Corona-Warn-App
//

import Foundation

struct DaysResult {
	let errors: [Client.Failure]
	let bucketsByDay: [String: PackageDownloadResponse]
}

struct FetchDayServiceHelper {

	// MARK: - Init
	init(
		restService: RestServiceProviding
	) {
		self.restService = restService
	}

	// MARK: - Internal

	func fetchDays(
			_ days: [String],
			forCountry country: String,
			completion completeWith: @escaping (DaysResult) -> Void
	) {
		var errors = [Client.Failure]()
		var buckets = [String: PackageDownloadResponse]()

		let group = DispatchGroup()
		days.forEach { day in
			group.enter()

			let resource = FetchDayResource(day: day, country: country)
			restService.load(resource) { result in
				defer {
					group.leave()
				}
				switch result {
				case let .success(bucket):
					buckets[day] = bucket
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
				DaysResult(
					errors: errors,
					bucketsByDay: buckets
				)
			)
		}

	}

	// MARK: - Private

	private let restService: RestServiceProviding

}
