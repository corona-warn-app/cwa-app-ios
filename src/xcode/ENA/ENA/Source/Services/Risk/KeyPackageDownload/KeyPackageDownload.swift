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
	func startDayPackagesDownload(completion: @escaping (Result<Void, KeyPackageDownloadError>) -> Void)
	func startHourPackagesDownload(completion: @escaping (Result<Void, KeyPackageDownloadError>) -> Void)
}

enum KeyPackageDownloadError: Error {
	case uncompletedPackages
	case noDiskSpace
	case unableToWriteDiagnosisKeys
	case downloadIsRunning
}

class KeyPackageDownload: KeyPackageDownloadProtocol {

	enum DownloadMode {
		case daily
		// Associated type: Key of the corresponding day.
		case hourly(String)
	}

	private let countryIds: [Country.ID]
	private let downloadedPackagesStore: DownloadedPackagesStore
	private let client: Client
	private let store: Store & AppConfigCaching
	private var isKeyDownloadRunning = false

	init(
		downloadedPackagesStore: DownloadedPackagesStore,
		client: Client,
		store: Store & AppConfigCaching,
		countryIds: [Country.ID] = ["EUR"]
	) {
		self.downloadedPackagesStore = downloadedPackagesStore
		self.client = client
		self.store = store
		self.countryIds = countryIds
	}

	func startDayPackagesDownload(completion: @escaping (Result<Void, KeyPackageDownloadError>) -> Void) {
		Log.info("KeyPackageDownload: Start downloading day packages.", log: .riskDetection)

		guard !isKeyDownloadRunning else {
			Log.info("KeyPackageDownload: Failed downloading. A download is already running.", log: .riskDetection)
			completion(.failure(.downloadIsRunning))
			return
		}
		isKeyDownloadRunning = true

		startDownloadCountryPackages(countryIds: countryIds, downloadMode: .daily) { result in
			switch result {
			case .success:
				Log.info("KeyPackageDownload: Completed downloading day packages to cache.", log: .riskDetection)
				completion(.success(()))
			case .failure(let error):
				Log.error("KeyPackageDownload: Failed downloading day packages with error: \(error).", log: .riskDetection)
				completion(.failure(error))
			}

			self.isKeyDownloadRunning = false
		}
	}

	func startHourPackagesDownload(completion: @escaping (Result<Void, KeyPackageDownloadError>) -> Void) {
		Log.info("KeyPackageDownload: Start downloading hour packages.", log: .riskDetection)

		guard !isKeyDownloadRunning else {
			Log.info("KeyPackageDownload: Failed downloading. A download is already running.", log: .riskDetection)
			completion(.failure(.downloadIsRunning))
			return
		}
		isKeyDownloadRunning = true

		startDownloadCountryPackages(countryIds: countryIds, downloadMode: .hourly(.formattedToday())) {result in
			switch result {
			case .success:
				Log.info("KeyPackageDownload: Completed downloading hour packages.", log: .riskDetection)
				completion(.success(()))
			case .failure(let error):
				Log.error("KeyPackageDownload: Completed downloading hour packages with error: \(error).", log: .riskDetection)
				completion(.failure(error))
			}
		}
	}

	// MARK: - Private

	private func startDownloadCountryPackages(countryIds: [Country.ID], downloadMode: DownloadMode, completion: @escaping (Result<Void, KeyPackageDownloadError>) -> Void) {

		let dispatchGroup = DispatchGroup()
		var errors = [KeyPackageDownloadError]()

		for countryId in countryIds {
			Log.info("KeyPackageDownload: Start downloading key package with country id: \(countryId).", log: .riskDetection)

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
						Log.info("KeyPackageDownload: Succeded downloading key packages for country id: \(countryId).", log: .riskDetection)
					case .failure(let error):
						Log.info("KeyPackageDownload: Failed downloading key packages for country id: \(countryId).", log: .riskDetection)
						errors.append(error)
					}

					dispatchGroup.leave()
				}
			}
		}

		dispatchGroup.notify(queue: .main) {
			if let error = errors.first {
				Log.error("KeyPackageDownload: Failed downloading key packages with errors: \(errors).", log: .riskDetection)

				self.updateRecentKeyDownloadFlags(to: false, downloadMode: downloadMode)
				completion(.failure(error))
			} else {
				Log.info("KeyPackageDownload: Completed downloading key packages to cache.", log: .riskDetection)

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
			case .success(let availablePackages):
				self.cleanupPackages(for: countryId, serverPackages: availablePackages, downloadMode: downloadMode)
				let deltaPackages = self.serverDelta(country: countryId, for: Set(availablePackages), downloadMode: downloadMode)

				self.downloadPackages(for: Array(deltaPackages), downloadMode: downloadMode, country: countryId) { [weak self] result in
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

	private func cleanupPackages(for countryId: Country.ID, serverPackages: [String], downloadMode: DownloadMode) {
		
		let localDeltaPackages = self.localDelta(country: countryId, for: Set(serverPackages), downloadMode: downloadMode)
		
		for package in localDeltaPackages {
			switch downloadMode {
			case .daily:
				downloadedPackagesStore.deleteDayPackage(for: package, country: countryId)
			case .hourly(let keyDay):
				// hourly packages for a day are deleted when the day package is stored. See func
				// DownloadedPackagesSQLLiteStoreV1.set(  country: Country.ID,	day: String, package: SAPDownloadedPackage )
				downloadedPackagesStore.deleteHourPackage(for: keyDay, hour: Int(package) ?? -1, country: countryId)
			}
		}
	}

	private func expectNewDayPackages(for country: Country.ID) -> Bool {
		guard let yesterdayDate = Calendar.utcCalendar.date(byAdding: .day, value: -1, to: Date()) else {
			fatalError("Could not create yesterdays date.")
		}
		let yesterdayKeyString = DateFormatter.packagesDateFormatter.string(from: yesterdayDate)
		let yesterdayDayPackageExists = downloadedPackagesStore.allDays(country: country).contains(yesterdayKeyString)

		return !yesterdayDayPackageExists || !store.wasRecentDayKeyDownloadSuccessful
	}

	private func expectNewHourPackages(for dayKey: String, counrtyId: Country.ID) -> Bool {
		guard let lastHourDate = Calendar.utcCalendar.date(byAdding: .hour, value: -1, to: Date()) else {
			fatalError("Could not create last hour date.")
		}
		let lastHourKey = Int(DateFormatter.packagesDateFormatter.string(from: lastHourDate)) ?? -1
		let lastHourPackageExists = downloadedPackagesStore.hours(for: dayKey, country: counrtyId).contains(lastHourKey)

		return !lastHourPackageExists || !store.wasRecentHourKeyDownloadSuccessful
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
					completion(.failure(.uncompletedPackages))
				}
			}
		case .hourly(let dayKey):
			client.availableHours(day: dayKey, country: country) { result in
				switch result {
				case .success(let hours):
					let packageKeys = hours.map { String($0) }
					completion(.success(packageKeys))
				case .failure:
					completion(.failure(.uncompletedPackages))
				}
			}
		}
	}

	private func serverDelta(
		country: Country.ID,
		for serverPackages: Set<String>,
		downloadMode: DownloadMode
	) -> Set<String> {

		switch downloadMode {
		case .daily:
			let localDays = Set(downloadedPackagesStore.allDays(country: country))
			let deltaDays = serverPackages.subtracting(localDays)
			return deltaDays
		case .hourly(let dayKey):
			let localHours = Set(downloadedPackagesStore.hours(for: dayKey, country: country).map { String($0) })
			let deltaHours = serverPackages.subtracting(localHours)
			return deltaHours
		}
	}
	
	private func localDelta(
		country: Country.ID,
		for serverPackages: Set<String>,
		downloadMode: DownloadMode
	) -> Set<String> {
		
		switch downloadMode {
		case .daily:
			let localDays = Set(downloadedPackagesStore.allDays(country: country))
			let deltaDays = localDays.subtracting(serverPackages)
			return deltaDays
		case .hourly(let dayKey):
			let localHours = Set(downloadedPackagesStore.hours(for: dayKey, country: country).map { String($0) })
			let deltaHours = localHours.subtracting(serverPackages)
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
						completion(.failure(.uncompletedPackages))
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
					completion(.failure(.uncompletedPackages))
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
