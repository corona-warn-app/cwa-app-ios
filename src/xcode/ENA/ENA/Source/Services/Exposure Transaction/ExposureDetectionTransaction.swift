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

import ExposureNotification
import Foundation

/// Every time the user wants to know the own risk the app creates an `ExposureDetectionTransaction`.
///
/// The main objective of an `ExposureDetectionTransaction` is to ensure that the
/// exposure detection/risk assesment is done as accurately as possible. An `ExposureDetectionTransaction`
/// requires a delegate to work. The delegate has several high-level tasks:
///
/// - **Provide Information:** Some methods simply provide information/objects that are required by the transaction to do the actual work.
/// - **Consume Results:** At some point the transaction generates results. The delegate is informed about them so that it can consume them.
/// - **React to Errors:** A transaction has several preconditions. If not all of them are met the transaction ends prematurely. In that case the delegate is notified along with a reason that specify details about why the transaction did end prematurely.
///
/// Under the hood the transaction execute the following steps:
///
/// ----
///
/// 1. Determine diagnosis keys that have to be downloaded.
/// 2. Download the missing keys (hours + days).
/// 3. Validate the downloaded data: Check the signatures, decode payloads, …
/// 4. Store everything that is valid and evict invalid/stale data from the local cache.
/// 5. Prepare the actual exposure detection:
///     - Transform keys into a format that can be understood by Apple.
///     - Write transformed data to disk.
///     - Get an `ExposureManager`.
/// 6. Ask for user consent if required.
/// 7. Provide everything to the Exposure Notification framework.
/// 8. Wipe everything and inform the delegate.
final class ExposureDetectionTransaction {
	// MARK: Properties
	
	private weak var delegate: ExposureDetectionTransactionDelegate?
	private let client: Client
	private let downloadedPackagesStore: DownloadedPackagesStore

	// MARK: Creating a Transaction
	
	init(
		delegate: ExposureDetectionTransactionDelegate,
		client: Client,
		downloadedPackagesStore: DownloadedPackagesStore
	) {
		self.delegate = delegate
		self.client = client
		self.downloadedPackagesStore = downloadedPackagesStore
	}
	
	// MARK: Starting the Transaction
	
	func start() {
		client.availableDaysAndHoursUpUntil(formattedToday()) { [weak self] result in
			guard let self = self else { return }
			switch result {
			case let .success(daysAndHours):
				self.continueWith(remoteDaysAndHours: daysAndHours)
			case .failure:
				self.endPrematurely(reason: .noDaysAndHours)
			}
		}
	}
	
	// MARK: Working with the Delegate
	
	// Ends the transaction prematurely with a given reason.
	private func endPrematurely(reason: DidEndPrematurelyReason) {
		delegate?.exposureDetectionTransaction(self, didEndPrematurely: reason)
	}
	
	// Informs the delegate about a summary.
	private func didDetectSummary(_ summary: ENExposureDetectionSummary) {
		delegate?.exposureDetectionTransaction(self, didDetectSummary: summary)
	}
	
	// Get the exposure manager from the delegate
	private func exposureManager() -> ExposureManager {
		guard let delegate = delegate else {
			fatalError("ExposureDetectionTransaction requires a delegate to work.")
		}
		return delegate.exposureDetectionTransactionRequiresExposureManager(self)
	}
	
	// Gets today formatted as required by the backend.
	private func formattedToday() -> String {
		guard let delegate = delegate else {
			fatalError("ExposureDetectionTransaction requires a delegate to work.")
		}
		return delegate.exposureDetectionTransactionRequiresFormattedToday(self)
	}
	
	// MARK: Steps of a Transaction
	
	// 1. Step: Download available Days & Hours
	private func continueWith(remoteDaysAndHours: Client.DaysAndHours) {
		fetchAndStoreMissingDaysAndHours(remoteDaysAndHours: remoteDaysAndHours) { [weak self] in
			guard let self = self else { return }
			self.remoteExposureConfiguration { [weak self] configuration in
				guard let self = self else { return }
				do {
					let writer = try self.createAppleFilesWriter()
					self.detectExposures(writer: writer, configuration: configuration)
				} catch {
					self.endPrematurely(reason: .unableToDiagnosisKeys)
				}
			}
		}
	}
	
	// 2. Step: Determine and fetch what is missing
	private func fetchAndStoreMissingDaysAndHours(
		remoteDaysAndHours _: Client.DaysAndHours,
		completion: @escaping () -> Void
	) {
		client.availableDaysAndHoursUpUntil(.formattedToday()) { [weak self] result in
			guard let self = self else { return }
			switch result {
			case .success(let (remoteDays, remoteHours)):
				let delta = DeltaCalculationResult(
					remoteDays: Set(remoteDays),
					remoteHours: Set(remoteHours),
					localDays: Set(self.downloadedPackagesStore.allDays()),
					localHours: Set(self.downloadedPackagesStore.hours(for: .formattedToday()))
				)
				self.client.fetchDays(
					Array(delta.missingDays),
					hours: Array(delta.missingHours),
					of: .formattedToday()
				) { fetchedDaysAndHours in
					self.downloadedPackagesStore.addFetchedDaysAndHours(fetchedDaysAndHours)
					completion()
				}
			case .failure:
				self.endPrematurely(reason: .noDaysAndHours)
			}
		}
	}
	
	// 3. Fetch the Configuration
	private func remoteExposureConfiguration(
		continueWith: @escaping (ENExposureConfiguration) -> Void
	) {
		client.exposureConfiguration { configuration in
			guard let configuration = configuration else {
				self.endPrematurely(reason: .noExposureConfiguration)
				return
			}
			
			continueWith(configuration)
		}
	}
	
	// 4. Transform
	private func createAppleFilesWriter() throws -> AppleFilesWriter {
		// 1. Create temp dir
		let fm = FileManager()
		let rootDir = fm.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
		try fm.createDirectory(at: rootDir, withIntermediateDirectories: true, attributes: nil)

		let packages = downloadedPackagesStore.allPackages(for: .formattedToday())

		return AppleFilesWriter(rootDir: rootDir, keyPackages: packages)
	}
	
	// 5. Execute the actual exposure detection
	private func detectExposures(
		writer: AppleFilesWriter,
		configuration: ENExposureConfiguration
	) {
		writer.with { [weak self] diagnosisURLs, done in
			guard let self = self else { return }
			self._detectExposures(
				diagnosisKeyURLs: diagnosisURLs,
				configuration: configuration,
				completion: done
			)
		}
	}
	
	private func _detectExposures(
		diagnosisKeyURLs: [URL],
		configuration: ENExposureConfiguration,
		completion: @escaping () -> Void
	) {
		let manager = exposureManager()
		_ = manager.detectExposures(
			configuration: configuration,
			diagnosisKeyURLs: diagnosisKeyURLs
		) { [weak self] summary, error in
			guard let self = self else {
				return
			}
			if let error = error {
				self.endPrematurely(reason: .noSummary(error))
				return
			}
			
			guard let summary = summary else {
				completion()
				self.endPrematurely(reason: .noSummary(nil))
				return
			}
			self.didDetectSummary(summary)
			completion()
		}
	}
}

private extension DownloadedPackagesStore {
	func allPackages(for day: String) -> [SAPDownloadedPackage] {
		let fullDays = allDays()
		var packages = [SAPDownloadedPackage]()
		packages.append(
			contentsOf: fullDays.map { package(for: $0) }.compactMap { $0 }
		)
		packages.append(
			contentsOf: hourlyPackages(for: day)
		)
		return packages
	}
}

private extension DownloadedPackagesStore {
	func addFetchedDaysAndHours(_ daysAndHours: FetchedDaysAndHours) {
		let days = daysAndHours.days
		days.bucketsByDay.forEach { day, bucket in
			self.set(day: day, package: bucket)
		}
		
		let hours = daysAndHours.hours
		hours.bucketsByHour.forEach { hour, bucket in
			self.set(hour: hour, day: hours.day, package: bucket)
		}
	}
	
	//    func missingDaysAndHours(from remote: Client.DaysAndHours, today: String) -> Client.DaysAndHours {
	//        let days = missingDays(remoteDays: Set(remote.days))
	//        let hours = missingHours(
	//            day: today,
	//            remoteHours: Set(remote.hours)
	//        )
	//        return Client.DaysAndHours(days: Array(days), hours: Array(hours))
	//    }
	//
	//    func allKeys(today: String) -> [SAPDownloadedPackage] {
	//        let days = allDailyKeyPackages()
	//        let hours = hourlyPackages(for: today)
	//        return days + hours
	//    }
	//
	//    func allVerifiedBuckets(today: String) -> [SAPDownloadedPackage] {
	//        allKeys(today: today)
	//            .compactMap { $0 }
	//    }
}

extension SAP_TemporaryExposureKey {
	func toAppleKey() -> Apple_TemporaryExposureKey {
		Apple_TemporaryExposureKey.with {
			$0.keyData = self.keyData
			$0.rollingStartIntervalNumber = self.rollingStartIntervalNumber
			$0.rollingPeriod = self.rollingPeriod
			$0.transmissionRiskLevel = self.transmissionRiskLevel
		}
	}
}

private extension ENExposureConfiguration {
	var needsTemporaryFixUntilAppleFixedZeroWeightIssue: Bool {
		attenuationWeight.isNearZero ||
			durationWeight.isNearZero ||
			transmissionRiskWeight.isNearZero ||
			daysSinceLastExposureWeight.isNearZero
	}
	
	func fixed() -> ENExposureConfiguration {
		.mock()
	}
}

private extension Double {
	var isNearZero: Bool { magnitude < 0.1 }
}
