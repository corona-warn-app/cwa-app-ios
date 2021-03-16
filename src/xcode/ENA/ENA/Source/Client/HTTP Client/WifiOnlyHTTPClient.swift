//
// 🦠 Corona-Warn-App
//

import ExposureNotification
import Foundation
import ZIPFoundation

final class WifiOnlyHTTPClient: ClientWifiOnly {

	// MARK: - Init

	init(
		serverEnvironmentProvider: ServerEnvironmentProviding,
		session: URLSession = URLSession(configuration: .coronaWarnSessionConfigurationWifiOnly())
	) {
		self.serverEnvironmentProvider = serverEnvironmentProvider
		self.session = session
		self.disableHourlyDownload = false
	}

	// MARK: - Overrides

	// MARK: - Protocol ClientWifiOnly

	func availableHours(
		day: String,
		country: String,
		completion completeWith: @escaping AvailableHoursCompletionHandler
	) {
		let url = configuration.availableHoursURL(day: day, country: country)

		session.GET(url) { [weak self] result in
			self?.queue.async {
				switch result {
				case let .success(response):
					// We accept 404 responses since this can happen in case there
					// have not been any new cases reported on that day.
					// We don't report this as an error to simplify things for the consumer.
					guard response.statusCode != 404 else {
						completeWith(.success([]))
						return
					}

					guard let data = response.body else {
						completeWith(.failure(.invalidResponse))
						return
					}

					do {
						let decoder = JSONDecoder()
						let hours = try decoder.decode([Int].self, from: data)
						completeWith(.success(hours))
					} catch {
						completeWith(.failure(.invalidResponse))
						return
					}
				case let .failure(error):
					if case .noResponse = error {
						Log.error("failed to get availableHours: \(error). This error occurs when fetching availableHours was triggered without WIFI connection.", log: .api)
					} else {
						Log.error("failed to get availableHours: \(error)", log: .api)
					}

					completeWith(.failure(error))
				}
			}
		}
	}

	func fetchHour(
		_ hour: Int,
		day: String,
		country: String,
		completion completeWith: @escaping HourCompletionHandler
	) {
		let url = configuration.diagnosisKeysURL(day: day, hour: hour, forCountry: country)
		var responseError: Client.Failure?

		session.GET(url) { [weak self] result in
			self?.queue.async {
				guard let self = self else {
					completeWith(.failure(.noResponse))
					return
				}

				defer {
					// no guard in defer!
					if let error = responseError {
						let retryCount = self.retries[url] ?? 0
						if retryCount > 2 {
							completeWith(.failure(error))
						} else {
							self.retries[url] = retryCount.advanced(by: 1)
							Log.debug("\(url) received: \(error) – retry (\(retryCount.advanced(by: 1)) of 3)", log: .api)
							self.fetchHour(hour, day: day, country: country, completion: completeWith)
						}
					} else {
						// no error, no retry - clean up
						self.retries[url] = nil
					}
				}

				#if !RELEASE
				guard !self.disableHourlyDownload else {
					responseError = .noResponse
					return
				}
				#endif

				switch result {
				case let .success(response):
					guard let hourData = response.body else {
						responseError = .invalidResponse
						return
					}
					Log.debug("got hour: \(hourData.count)", log: .api)
					guard let package = SAPDownloadedPackage(compressedData: hourData) else {
						Log.error("Failed to create signed package. For URL: \(url)", log: .api)
						responseError = .invalidResponse
						return
					}
					let etag = response.httpResponse.value(forCaseInsensitiveHeaderField: "ETag")
					let payload = PackageDownloadResponse(package: package, etag: etag, isEmpty: false)
					completeWith(.success(payload))
				case let .failure(error):
					responseError = error

					if case .noResponse = error {
						Log.error("failed to get hour: \(error). This error occurs when download of hour packages was triggered without WIFI connection.", log: .api)
					} else {
						Log.error("failed to get hour: \(error)", log: .api)
					}
				}
			}
		}
	}

	// MARK: - Public

	// MARK: - Internal

	var disableHourlyDownload: Bool

	var isWifiOnlyActive: Bool {
		let wifiOnlyConfiguration = URLSessionConfiguration.coronaWarnSessionConfigurationWifiOnly()
		if #available(iOS 13.0, *) {
			return session.configuration.allowsCellularAccess == wifiOnlyConfiguration.allowsCellularAccess &&
				session.configuration.allowsExpensiveNetworkAccess == wifiOnlyConfiguration.allowsExpensiveNetworkAccess &&
				session.configuration.allowsConstrainedNetworkAccess == wifiOnlyConfiguration.allowsConstrainedNetworkAccess
		} else {
			return session.configuration.allowsCellularAccess == wifiOnlyConfiguration.allowsCellularAccess
		}
	}

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
			fetchHour(hour, day: day, country: country) { result in
				switch result {
				case let .success(hourBucket):
					buckets[hour] = hourBucket
				case let .failure(error):
					errors.append(error)
				}
				group.leave()
			}
		}

		group.notify(queue: .main) {
			completeWith(
				HoursResult(errors: errors, bucketsByHour: buckets, day: day)
			)
		}
	}

	// MARK: - Private
	private let serverEnvironmentProvider: ServerEnvironmentProviding
	private var configuration: HTTPClient.Configuration {
		HTTPClient.Configuration.makeDefaultConfiguration(
			serverEnvironmentProvider: serverEnvironmentProvider
		)
	}
	private var session: URLSession
	private var retries: [URL: Int] = [:]

	private let queue = DispatchQueue(label: "com.sap.WifiOnlyHTTPClient")

}

#if !RELEASE
extension WifiOnlyHTTPClient {

	func updateSession(wifiOnly: Bool) {
		let sessionConfiguration: URLSessionConfiguration = wifiOnly ?
			.coronaWarnSessionConfigurationWifiOnly() :
			.coronaWarnSessionConfiguration()
		session.invalidateAndCancel()
		session = URLSession(configuration: sessionConfiguration)
	}

}
#endif
