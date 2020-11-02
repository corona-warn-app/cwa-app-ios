//
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
//

import Foundation

protocol KeyPackageDownloadProtocol {
	func start(completion: @escaping (Result<Void, KeyPackageDownloadError>) -> Void)
}

enum KeyPackageDownloadError: Error {
	case uncompletedDayPackages
	case uncompletedHourPackages
	case noDiskSpace
	case unableToWriteDiagnosisKeys
	case downloadIsRunning
}

final class KeyPackageDownload: KeyPackageDownloadProtocol {

	enum DownloadMode {
		case daily
		case hourly(String)
	}

	private let downloadedPackagesStore: DownloadedPackagesStore
	private let client: Client
	private let store: Store & AppConfigCaching
	private var isKeyDownloadRunning = false

	init(
		downloadedPackagesStore: DownloadedPackagesStore,
		client: Client,
		store: Store & AppConfigCaching
	) {
		self.downloadedPackagesStore = downloadedPackagesStore
		self.client = client
		self.store = store
	}

	func start(completion: @escaping (Result<Void, KeyPackageDownloadError>) -> Void) {
		Log.info("KeyPackageDownload: Start downloading packages to cache.", log: .riskDetection)

		guard isKeyDownloadRunning else {
			Log.info("KeyPackageDownload: Download is already running.", log: .riskDetection)
			completion(.failure(.downloadIsRunning))
			return
		}

		isKeyDownloadRunning = true

		let countryIds = ["EUR"]

		let dispatchGroup = DispatchGroup()
		var errors = [KeyPackageDownloadError]()

		dispatchGroup.enter()
		startProcessingPackages(countryIds: countryIds, downloadMode: .daily) { result in
			switch result {
			case .success:
				break
			case .failure(let error):
				errors.append(error)
			}

			dispatchGroup.leave()
		}

		dispatchGroup.enter()
		startProcessingPackages(countryIds: countryIds, downloadMode: .hourly(.formattedToday())) {result in
			switch result {
			case .success:
				break
			case .failure(let error):
				errors.append(error)
			}

			dispatchGroup.leave()
		}

		dispatchGroup.notify(queue: .main) {
			if let error = errors.first {
				Log.error("KeyPackageDownload: Completed downloading packages with errors: \(errors).", log: .riskDetection)
				completion(.failure(error))
			} else {
				Log.info("KeyPackageDownload: Completed downloading packages to cache.", log: .riskDetection)
				completion(.success(()))
			}

			self.isKeyDownloadRunning = false
		}
	}

	func startProcessingPackages(countryIds: [Country.ID], downloadMode: DownloadMode, completion: @escaping (Result<Void, KeyPackageDownloadError>) -> Void) {
		Log.info("KeyPackageDownload: Start downloading hour packages to cache.", log: .riskDetection)

		let dispatchGroup = DispatchGroup()
		var errors = [KeyPackageDownloadError]()

		for countryId in countryIds {
			Log.info("KeyPackageDownload: Start downloading hour package with country id: \(countryId).", log: .riskDetection)

			var shouldStartPackageDownload: Bool
			switch downloadMode {
			case .daily:
				shouldStartPackageDownload = expectNewDayPackages(for: countryId)
			case .hourly(let dayKey):
				shouldStartPackageDownload = expectNewHourPackages(for: dayKey, counrtyId: countryId)
			}

			if shouldStartPackageDownload {
				dispatchGroup.enter()

				startDownloadPackages(for: countryId, downloadMode: downloadMode) { result in
					switch result {
					case .success:
						Log.info("KeyPackageDownload: Succeded downloading hour packages for country id: \(countryId).", log: .riskDetection)
					case .failure(let error):
						Log.info("KeyPackageDownload: Failed downloading hour packages for country id: \(countryId).", log: .riskDetection)
						errors.append(error)
					}

					dispatchGroup.leave()
				}
			}
		}

		dispatchGroup.notify(queue: .main) {
			if let error = errors.first {
				Log.error("KeyPackageDownload: Failed downloading hour packages with errors: \(errors).", log: .riskDetection)

				self.updateRecentKeyDownloadFlags(to: false, downloadMode: downloadMode)
				completion(.failure(error))
			} else {
				Log.info("KeyPackageDownload: Completed downloading hour packages to cache.", log: .riskDetection)

				self.updateRecentKeyDownloadFlags(to: true, downloadMode: downloadMode)
				completion(.success(()))
			}
		}
	}

	private func updateRecentKeyDownloadFlags(to newValue: Bool, downloadMode: DownloadMode) {
		switch downloadMode {
		case .daily:
			self.store.wasRecentDayKeyDownloadSuccessful = newValue
		case .hourly:
			self.store.wasRecentHourKeyDownloadSuccessful = newValue
		}
	}

	private func startDownloadPackages(for countryId: Country.ID, downloadMode: DownloadMode, completion: @escaping (Result<Void, KeyPackageDownloadError>) -> Void) {
		availableServerData(country: countryId, downloadMode: downloadMode) { [weak self] result in
			guard let self = self else { return }

			switch result {
			case .success(let availableHours):
				let hoursDelta = self.serverDelta(country: countryId, for: Set(availableHours), downloadMode: downloadMode)

				self.downloadPackages(for: Array(hoursDelta), downloadMode: downloadMode, country: countryId) { [weak self] result in
					guard let self = self else { return }

					switch result {
					case .success(let hourPackages):
						let result = self.persistPackages(hourPackages, downloadMode: downloadMode, country: countryId)

						switch result {
						case .success:
							completion(.success(()))
						case .failure(let error):
							completion(.failure(error))
						}
					case .failure(let error):
						completion(.failure(error))
					}
				}
			case .failure(let error):
				completion(.failure(error))
			}
		}
	}

	private func expectNewDayPackages(for country: Country.ID) -> Bool {
		guard let yesterdayDate = Calendar.utcCalendar.date(byAdding: .day, value: -1, to: Date()) else {
			fatalError("Could not create yesterdays date.")
		}

		let formatter = DateFormatter()
		formatter.dateFormat = "YYYY-MM-DD"
		formatter.timeZone = TimeZone.utcTimeZone

		let yesterdayKeyString = formatter.string(from: yesterdayDate)
		let dayExists = downloadedPackagesStore.allDays(country: country).contains(yesterdayKeyString)

		let wasRecentDownloadSuccessful = store.wasRecentDayKeyDownloadSuccessful

		return !dayExists || !wasRecentDownloadSuccessful
	}

	private func expectNewHourPackages(for dayKey: String, counrtyId: Country.ID) -> Bool {
		guard let lastHourDate = Calendar.utcCalendar.date(byAdding: .hour, value: -1, to: Date()) else {
			fatalError("Could not create last hour date.")
		}

		let formatter = DateFormatter()
		formatter.dateFormat = "H"
		formatter.timeZone = TimeZone.utcTimeZone

		let lastHourKey = Int(formatter.string(from: lastHourDate)) ?? -1
		let recentHourPackageExists = downloadedPackagesStore.hours(for: dayKey, country: counrtyId).contains(lastHourKey)

		let wasRecentDownloadSuccessful = store.wasRecentHourKeyDownloadSuccessful

		return !recentHourPackageExists || !wasRecentDownloadSuccessful
	}

	private func availableServerData(
		country: Country.ID,
		downloadMode: DownloadMode,
		completion: @escaping (Result<[String], KeyPackageDownloadError>) -> Void
	) {
		switch downloadMode {
		case .daily:
			client.availableDays(forCountry: country) { result in
				switch result {
				case let .success(days):
					completion(.success(days))
				case .failure:
					completion(.failure(.uncompletedDayPackages))
				}
			}
		case .hourly(let dayKey):
			client.availableHours(day: dayKey, country: country) { result in
				switch result {
				case .success(let hours):
					let packageKeys = hours.map { String($0) }
					completion(.success(packageKeys))
				case .failure:
					completion(.failure(.uncompletedHourPackages))
				}
			}
		}
	}

	private func serverDelta(
		country: Country.ID,
		for remotePackages: Set<String>,
		downloadMode: DownloadMode
	) -> Set<String> {

		switch downloadMode {
		case .daily:
			let localDays = Set(downloadedPackagesStore.allDays(country: country))
			let deltaDays = remotePackages.subtracting(localDays)
			return deltaDays
		case .hourly(let dayKey):
			let localHours = Set(downloadedPackagesStore.hours(for: dayKey, country: country).map { String($0) })
			let deltaHours = remotePackages.subtracting(localHours)
			return deltaHours
		}
	}

	private func downloadPackages(
		for packageKeys: [String],
		downloadMode: DownloadMode,
		country: Country.ID,
		completion: @escaping (Result<[String: SAPDownloadedPackage], KeyPackageDownloadError>) -> Void) {

		switch downloadMode {
		case .daily:
			client.fetchDays(
				packageKeys,
				forCountry: country,
				completion: { daysResult in
					if daysResult.errors.isEmpty {
						completion(.success(daysResult.bucketsByDay))
					} else {
						completion(.failure(.uncompletedDayPackages))
					}
				}
			)
		case .hourly(let dayKey):
			let hourKeys = packageKeys.compactMap { Int($0) }
			client.fetchHours(hourKeys, day: dayKey, country: country) { hoursResult in
				if hoursResult.errors.isEmpty {
					let keyPackages = Dictionary(
						uniqueKeysWithValues: hoursResult.bucketsByHour.map { key, value in (String(key), value) }
					)
					completion(.success(keyPackages))
				} else {
					completion(.failure(.uncompletedHourPackages))
				}
			}
		}
	}

	private func persistPackages(_ keyPackages: [String: SAPDownloadedPackage], downloadMode: DownloadMode, country: Country.ID) -> Result<Void, KeyPackageDownloadError> {
		var result: Result<Void, SQLiteErrorCode>

		switch downloadMode {
		case .daily:
			result = downloadedPackagesStore.addFetchedDays(
				keyPackages,
				country: country
			)
		case .hourly(let dayKey):
			let keyPackages = Dictionary(
				uniqueKeysWithValues: keyPackages.map { key, value in (Int(key) ?? -1, value) }
			)

			result = downloadedPackagesStore.addFetchedHours(
				keyPackages,
				day: dayKey,
				country: country
			)
		}

		switch result {
		case .success:
			Log.info("KeyPackageDownload: Persistence of key packages successful.", log: .riskDetection)
			return .success(())
		case .failure(let error):
			Log.error("KeyPackageDownload: Persistence of key packages failed.", log: .riskDetection, error: error)
			switch error {
			case .sqlite_full:
				return .failure(.noDiskSpace)
			case .unknown:
				return .failure(.unableToWriteDiagnosisKeys)
			}
		}
	}

}
