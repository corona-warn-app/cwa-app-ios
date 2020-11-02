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
	case unavailableServerData
	case noDiskSpace
	case unableToWriteDiagnosisKeys
}

final class KeyPackageDownload: KeyPackageDownloadProtocol {

	private let downloadedPackagesStore: DownloadedPackagesStore
	private let client: Client
	private let store: Store & AppConfigCaching

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

		let countryIds = ["EUR"]

		let dispatchGroup = DispatchGroup()
		var errors = [KeyPackageDownloadError]()

		for countryId in countryIds {
			dispatchGroup.enter()

			downloadKeyPackages(for: countryId) { result in
				switch result {
				case .success:
					break
				case .failure(let error):
					errors.append(error)
				}
				dispatchGroup.leave()
			}
		}

		dispatchGroup.notify(queue: .main) {
			if let error = errors.first {
				completion(.failure(error))
			} else {
				completion(.success(()))
			}
		}
	}

	private func downloadKeyPackages(
		for countryId: String,
		completion: @escaping (Result<Void, KeyPackageDownloadError>) -> Void
	) {
		availableServerData(country: countryId) { [weak self] result in
			guard let self = self else { return }

			switch result {
			case .success(let daysAndHours):
				Log.info("KeyPackageDownload: Download available server data successful.", log: .riskDetection)

				let _serverDelta = self.serverDelta(
					country: countryId,
					for: daysAndHours
				)

				self.downloadAndStore(
					country: countryId,
					delta: _serverDelta,
					completion: completion
				)
			case .failure(let error):
				Log.info("KeyPackageDownload: Failed to download server data.", log: .riskDetection)

				completion(.failure(error))
			}
		}
	}

	private func availableServerData(
		country: Country.ID,
		completion: @escaping (Result<DaysAndHours, KeyPackageDownloadError>) -> Void
	) {
		let group = DispatchGroup()

		var daysAndHours = DaysAndHours(days: [], hours: [])
		var errors = [Error]()

		group.enter()

		client.availableHours(day: .formattedToday(), country: country) { result in
			switch result {
			case let .success(hours):
				daysAndHours.hours = hours
			case let .failure(error):
				errors.append(error)
			}
			group.leave()
		}

		group.enter()

		client.availableDays(forCountry: country) { result in
			switch result {
			case let .success(days):
				daysAndHours.days = days
			case let .failure(error):
				errors.append(error)
			}
			group.leave()
		}

		group.notify(queue: .main) {
			guard errors.isEmpty else {
				let errorMessage = "Unable to determine available server data due to errors:\n \(errors.map { $0.localizedDescription }.joined(separator: "\n"))"
				Log.error(errorMessage, log: .api)
				completion(.failure(.unavailableServerData))
				return
			}
			completion(.success(daysAndHours))
		}
	}

	private func serverDelta(
		country: Country.ID,
		for remote: DaysAndHours
	) -> DaysAndHours {
		let localDays = Set(downloadedPackagesStore.allDays(country: country))
		let localHours = Set(downloadedPackagesStore.hours(for: .formattedToday(), country: country))

		let delta = DeltaCalculationResult(
			remoteDays: Set(remote.days),
			remoteHours: Set(remote.hours),
			localDays: localDays,
			localHours: localHours
		)

		return DaysAndHours(
			days: Array(delta.missingDays),
			hours: Array(delta.missingHours)
		)
	}

	private func downloadAndStore(
		country: Country.ID,
		delta: DaysAndHours,
		completion: @escaping (Result<Void, KeyPackageDownloadError>) -> Void
	) {
		func storeDaysAndHours(_ fetchedDaysAndHours: FetchedDaysAndHours) {
			guard fetchedDaysAndHours.days.errors.isEmpty else {
				Log.info("KeyPackageDownload: Failed to download day packages.", log: .riskDetection)

				completion(.failure(.uncompletedDayPackages))
				return
			}

			// Risk detection should be executed regardles of failed hour packages.
			// Because of that, this error is not propagated and the KeyPackageDownload
			// is successful also with failed hour package download.
			if !fetchedDaysAndHours.hours.errors.isEmpty {
				Log.error("KeyPackageDownload: Failed to download hour packages.", log: .riskDetection)
			}

			Log.info("KeyPackageDownload: Download of key packages successful.", log: .riskDetection)

			let daysResult = downloadedPackagesStore.addFetchedDays(
				fetchedDaysAndHours.days,
				country: country
			)
			
			_ = downloadedPackagesStore.addFetchedHours(
				fetchedDaysAndHours.hours,
				country: country
			)
			
			switch daysResult {
			case .success:
				Log.info("KeyPackageDownload: Persistence of key packages successful.", log: .riskDetection)
				completion(.success(()))
			case .failure(let error):
				Log.error("KeyPackageDownload: Persistence of key packages failed.", log: .riskDetection, error: error)
				switch error {
				case .sqlite_full:
					completion(.failure(.noDiskSpace))
				case .unknown:
					completion(.failure(.unableToWriteDiagnosisKeys))
				}
			}
		}
		
		client.fetchDays(
			delta.days,
			hours: delta.hours,
			of: .formattedToday(),
			country: country,
			completion: storeDaysAndHours
		)
	}

}
