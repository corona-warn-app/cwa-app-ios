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
	var statusDidChange: ((KeyPackageDownloadStatus) -> Void)? { get set }

	func startDayPackagesDownload(completion: @escaping (Result<Void, KeyPackageDownloadError>) -> Void)
	func startHourPackagesDownload(completion: @escaping (Result<Void, KeyPackageDownloadError>) -> Void)
}

enum KeyPackageDownloadError: Error {
	case uncompletedPackages
	case noDiskSpace
	case unableToWriteDiagnosisKeys
	case downloadIsRunning

	var description: String {
		switch self {
		case .noDiskSpace:
			return AppStrings.ExposureDetectionError.errorAlertFullDistSpaceMessage
		default:
			return AppStrings.ExposureDetectionError.errorAlertMessage + " Code: KeyPackageDownloadError"
		}
	}
}

enum KeyPackageDownloadStatus {
	case idle
	case checkingForNewPackages
	case downloading
}

class KeyPackageDownload: KeyPackageDownloadProtocol {

	/// Download modes per day or hour of a given day
	enum DownloadMode {
		case daily
		// Associated type: Key of the corresponding day.
		case hourly(String)
	}

	// MARK: - Init

	init(
		downloadedPackagesStore: DownloadedPackagesStore,
		client: Client,
		wifiClient: ClientWifiOnly,
		store: Store & AppConfigCaching,
		countryIds: [Country.ID] = ["EUR"]
	) {
		self.downloadedPackagesStore = downloadedPackagesStore
		self.client = client
		self.wifiClient = wifiClient
		self.store = store
		self.countryIds = countryIds
	}

	// MARK: - Protocol KeyPackageDownloadProtocol

	func startDayPackagesDownload(completion: @escaping (Result<Void, KeyPackageDownloadError>) -> Void) {
		Log.info("KeyPackageDownload: Start downloading day packages.", log: .riskDetection)

		guard status == .idle else {
			Log.info("KeyPackageDownload: Failed downloading. A download is already running.", log: .riskDetection)
			completion(.failure(.downloadIsRunning))
			return
		}

		status = .checkingForNewPackages

		startDownloadAllCountryPackages(countryIds: countryIds, downloadMode: .daily) { [weak self] result in
			self?.status = .idle

			switch result {
			case .success:
				Log.info("KeyPackageDownload: Completed downloading day packages to cache.", log: .riskDetection)
				completion(.success(()))
			case .failure(let error):
				Log.error("KeyPackageDownload: Failed downloading day packages with error: \(error).", log: .riskDetection)
				completion(.failure(error))
			}
		}
	}

	func startHourPackagesDownload(completion: @escaping (Result<Void, KeyPackageDownloadError>) -> Void) {
		Log.info("KeyPackageDownload: Start downloading hour packages.", log: .riskDetection)

		guard status == .idle else {
			Log.info("KeyPackageDownload: Failed downloading. A download is already running.", log: .riskDetection)
			completion(.failure(.downloadIsRunning))
			return
		}

		status = .checkingForNewPackages

		startDownloadAllCountryPackages(countryIds: countryIds, downloadMode: .hourly(.formattedToday())) { [weak self] result in
			self?.status = .idle

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

	// MARK: - Internal

	var statusDidChange: ((KeyPackageDownloadStatus) -> Void)?

	// MARK: - Private

	private let countryIds: [Country.ID]
	private let downloadedPackagesStore: DownloadedPackagesStore
	private let client: Client
	private let wifiClient: ClientWifiOnly
	private let store: Store & AppConfigCaching

	private var status: KeyPackageDownloadStatus = .idle {
		didSet {
			statusDidChange?(status)
		}
	}

	private func startDownloadAllCountryPackages(countryIds: [Country.ID], downloadMode: DownloadMode, completion: @escaping (Result<Void, KeyPackageDownloadError>) -> Void) {

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

			Log.debug("KeyPackageDownload: shouldStartPackageDownload: \(shouldStartPackageDownload)", log: .riskDetection)

			if shouldStartPackageDownload {
				dispatchGroup.enter()

				status = .downloading

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

	private func startDownloadPackages(for countryId: Country.ID, downloadMode: DownloadMode, completion: @escaping (Result<Void, KeyPackageDownloadError>) -> Void) {
		availableServerData(country: countryId, downloadMode: downloadMode) { [weak self] result in
			guard let self = self else { return }

			switch result {
			case .success(let availablePackages):
				self.cleanupPackages(for: countryId, serverPackages: availablePackages, downloadMode: downloadMode)

				let deltaPackages = self.serverDelta(country: countryId, for: Set(availablePackages), downloadMode: downloadMode)

				guard !deltaPackages.isEmpty else {
					Log.info("KeyPackageDownload: Key packages are up to date. No download is triggered.", log: .riskDetection)
					completion(.success(()))
					return
				}

				self.downloadPackages(for: Array(deltaPackages), downloadMode: downloadMode, country: countryId) { [weak self] result in
					guard let self = self else { return }

					switch result {
					case .success(let hourPackages):
						let result = self.persistPackages(hourPackages, downloadMode: downloadMode, country: countryId)

						switch result {
						case .success:
							Log.info("KeyPackageDownload: Downloaded key packages from server.", log: .riskDetection)
							self.store.lastKeyPackageDownloadDate = Date()

							completion(.success(()))
						case .failure(let error):
							Log.info("KeyPackageDownload: Failed downloading key packages from server.", log: .riskDetection)
							completion(.failure(error))
						}
					case .failure(let error):
						Log.error("KeyPackageDownload: Failed to download key packages.", log: .riskDetection, error: error)
						completion(.failure(error))
					}
				}
			case .failure(let error):
				Log.error("KeyPackageDownload: Failed to check for available server data.", log: .riskDetection, error: error)
				completion(.failure(error))
			}
		}
	}

	private func downloadPackages(
		for packageKeys: [String],
		downloadMode: DownloadMode,
		country: Country.ID,
		completion: @escaping (Result<[String: PackageDownloadResponse], KeyPackageDownloadError>) -> Void) {

		switch downloadMode {
		case .daily:
			Log.info("KeyPackageDownload: Fetch day packages from server.", log: .riskDetection)

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
			Log.info("KeyPackageDownload: Fetch hour packages from server.", log: .riskDetection)

			let hourKeys = packageKeys.compactMap { Int($0) }

			wifiClient.fetchHours(hourKeys, day: dayKey, country: country) { hoursResult in
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

	private func persistPackages(_ keyPackages: [String: PackageDownloadResponse], downloadMode: DownloadMode, country: Country.ID) -> Result<Void, KeyPackageDownloadError> {
		do {
			switch downloadMode {
			case .daily:
				try downloadedPackagesStore.addFetchedDays(
					keyPackages,
					country: country
				)
			case .hourly(let dayKey):
				let keyPackages = Dictionary(
					uniqueKeysWithValues: keyPackages.map { key, value in (Int(key) ?? -1, value) }
				)

				try downloadedPackagesStore.addFetchedHours(
					keyPackages,
					day: dayKey,
					country: country
				)
			}
		} catch SQLiteErrorCode.generalError {
			Log.error("KeyPackageDownload: Persistence of key packages failed.", log: .riskDetection, error: SQLiteErrorCode.generalError)
			assertionFailure("This is most likely a developer error. Check the logs!")
			return .failure(.unableToWriteDiagnosisKeys)
		} catch SQLiteErrorCode.sqlite_full {
			Log.error("KeyPackageDownload: Persistence of key packages failed. Storage full", log: .riskDetection, error: SQLiteErrorCode.sqlite_full)
			return .failure(.noDiskSpace)
		} catch SQLiteErrorCode.unknown {
			Log.error("KeyPackageDownload: Persistence of key packages failed. Unknown reason.", log: .riskDetection, error: SQLiteErrorCode.unknown)
			return .failure(.unableToWriteDiagnosisKeys)
		} catch {
			Log.error("KeyPackageDownload: Persistence of key packages failed.", log: .riskDetection, error: error)
			assertionFailure("Expected error of type SQLiteErrorCode.")
			return .failure(.unableToWriteDiagnosisKeys)
		}

		Log.info("KeyPackageDownload: Persistence of key packages successful.", log: .riskDetection)
		return .success(())
	}

	private func cleanupPackages(for countryId: Country.ID, serverPackages: [String], downloadMode: DownloadMode) {
		Log.info("KeyPackageDownload: Start cleanup key packages.", log: .riskDetection)

		let localDeltaPackages = self.localDelta(country: countryId, for: Set(serverPackages), downloadMode: downloadMode)

		guard !localDeltaPackages.isEmpty else {
			Log.info("KeyPackageDownload: No key packages removed during cleanup.", log: .riskDetection)
			return
		}

		for package in localDeltaPackages {
			Log.info("KeyPackageDownload: Key package removed during cleanup.", log: .riskDetection)
			switch downloadMode {
			case .daily:
				downloadedPackagesStore.deleteDayPackage(for: package, country: countryId)
			case .hourly(let keyDay):
				// Hourly packages for the last day are deleted when the last day package is stored. See func
				// DownloadedPackagesSQLLiteStore.set(country: Country.ID, day: String, package: SAPDownloadedPackage)
				downloadedPackagesStore.deleteHourPackage(for: keyDay, hour: Int(package) ?? -1, country: countryId)
			}
		}
	}

	private func availableServerData(
		country: Country.ID,
		downloadMode: DownloadMode,
		completion: @escaping (Result<[String], KeyPackageDownloadError>) -> Void
	) {
		Log.info("KeyPackageDownload: Check for available server data.", log: .riskDetection)

		switch downloadMode {
		case .daily:
			client.availableDays(forCountry: country) { result in
				switch result {
				case let .success(days):
					Log.info("KeyPackageDownload: Server data is available for day packages.", log: .riskDetection)
					completion(.success(days))
				case .failure:
					completion(.failure(.uncompletedPackages))
				}
			}
		case .hourly(let dayKey):
			client.availableHours(day: dayKey, country: country) { result in
				switch result {
				case .success(let hours):
					Log.info("KeyPackageDownload: Server data is available for hour packages.", log: .riskDetection)
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
			Log.info("KeyPackageDownload: Calculate serverDelta for day packages.", log: .riskDetection)

			let localDays = Set(downloadedPackagesStore.allDays(country: country))
			Log.debug("KeyPackageDownload: localDays: \(localDays)", log: .riskDetection)
			Log.debug("KeyPackageDownload: serverPackages: \(serverPackages)", log: .riskDetection)
			let deltaDays = serverPackages.subtracting(localDays)
			Log.debug("KeyPackageDownload: deltaDays: \(deltaDays)", log: .riskDetection)
			return deltaDays
		case .hourly(let dayKey):
			Log.info("KeyPackageDownload: Calculate serverDelta for hour packages.", log: .riskDetection)

			let localHours = Set(downloadedPackagesStore.hours(for: dayKey, country: country).map { String($0) })
			Log.debug("KeyPackageDownload: localHours: \(localHours)", log: .riskDetection)
			Log.debug("KeyPackageDownload: serverPackages: \(serverPackages)", log: .riskDetection)
			let deltaHours = serverPackages.subtracting(localHours)
			Log.debug("KeyPackageDownload: deltaHours: \(deltaHours)", log: .riskDetection)
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

	private func expectNewDayPackages(for country: Country.ID) -> Bool {
		guard let yesterdayDate = Calendar.utcCalendar.date(byAdding: .day, value: -1, to: Date()) else {
			Log.error("Could not create yesterdays date.", log: .riskDetection)
			fatalError("Could not create yesterdays date.")
		}
		Log.debug("KeyPackageDownload: yesterdayDate: \(yesterdayDate)", log: .riskDetection)

		let yesterdayKeyString = DateFormatter.packagesDayDateFormatter.string(from: yesterdayDate)
		Log.debug("KeyPackageDownload: yesterdayKeyString: \(yesterdayKeyString)", log: .riskDetection)

		let cachedKeyPackages = downloadedPackagesStore.allDays(country: country)
		Log.debug("KeyPackageDownload: cachedKeyPackages: \(cachedKeyPackages)", log: .riskDetection)

		let yesterdayDayPackageExists = cachedKeyPackages.contains(yesterdayKeyString)

		Log.info("KeyPackageDownload: Check for last day package. yesterdayDayPackageExists: \(yesterdayDayPackageExists)", log: .riskDetection)
		Log.info("KeyPackageDownload: Check for success of last day package download. store.wasRecentDayKeyDownloadSuccessful: \(store.wasRecentDayKeyDownloadSuccessful)", log: .riskDetection)

		return !yesterdayDayPackageExists || !store.wasRecentDayKeyDownloadSuccessful
	}

	private func expectNewHourPackages(for dayKey: String, counrtyId: Country.ID) -> Bool {
		guard let lastHourDate = Calendar.utcCalendar.date(byAdding: .hour, value: -1, to: Date()) else {
			Log.error("Could not create last hour date.", log: .riskDetection)
			fatalError("Could not create last hour date.")
		}
		Log.debug("KeyPackageDownload: lastHourDate: \(lastHourDate)", log: .riskDetection)

		guard let lastHourKey = Int(DateFormatter.packagesHourDateFormatter.string(from: lastHourDate)) else {
			Log.error("Could not create hour key from date: \(lastHourDate)", log: .riskDetection)
			fatalError("Could not create hour key from date.")
		}
		Log.debug("KeyPackageDownload: lastHourKey: \(lastHourKey)", log: .riskDetection)

		let cachedKeyPackages = downloadedPackagesStore.hours(for: dayKey, country: counrtyId)
		Log.debug("KeyPackageDownload: cachedKeyPackages: \(cachedKeyPackages)", log: .riskDetection)

		let lastHourPackageExists = cachedKeyPackages.contains(lastHourKey)

		Log.info("KeyPackageDownload: Check for last hour package. lastHourPackageExists: \(lastHourPackageExists)", log: .riskDetection)
		Log.info("KeyPackageDownload: Check for success of last hour package download. store.wasRecentHourKeyDownloadSuccessful: \(store.wasRecentHourKeyDownloadSuccessful)", log: .riskDetection)

		return !lastHourPackageExists || !store.wasRecentHourKeyDownloadSuccessful
	}

	private func updateRecentKeyDownloadFlags(to newValue: Bool, downloadMode: DownloadMode) {
		switch downloadMode {
		case .daily:
			self.store.wasRecentDayKeyDownloadSuccessful = newValue
		case .hourly:
			self.store.wasRecentHourKeyDownloadSuccessful = newValue
		}
	}
}
