//
// 🦠 Corona-Warn-App
//

import Foundation
import ExposureNotification

final class ExposureDetectionExecutor: ExposureDetectionDelegate {

	private let client: Client

	private let downloadedPackagesStore: DownloadedPackagesStore
	private let store: Store
	private let exposureDetector: ExposureDetector

	init(
		client: Client,
		downloadedPackagesStore: DownloadedPackagesStore,
		store: Store,
		exposureDetector: ExposureDetector
	) {
		self.client = client
		self.downloadedPackagesStore = downloadedPackagesStore
		self.store = store
		self.exposureDetector = exposureDetector
	}

	func exposureDetectionWriteDownloadedPackages(
		country: Country.ID
	) -> WrittenPackages? {

		let fileManager = FileManager()
		do {
			let rootDir = try fileManager.createKeyPackageDirectory()
			let writer = AppleFilesWriter(rootDir: rootDir)

			let allHourlyPackages = downloadedPackagesStore.hourlyPackages(for: .formattedToday(), country: country)
			for hourlyKeyPackage in allHourlyPackages {
				let success = writer.writePackage(hourlyKeyPackage)
				if !success {
					return nil
				}
			}

			let allDayKeyPackages = downloadedPackagesStore.allDays(country: country)
			for dayKeyPackage in allDayKeyPackages {
				let _keyPackage = autoreleasepool(invoking: { downloadedPackagesStore.package(for: dayKeyPackage, country: country) })

				if let keyPackage = _keyPackage {
					let success = writer.writePackage(keyPackage)
					if !success {
						return nil
					}
				}
			}
			return writer.writtenPackages
		} catch {
			return nil
		}
	}

	func detectExposureWindows(
		_ detection: ExposureDetection,
		detectSummaryWithConfiguration configuration: ENExposureConfiguration,
		writtenPackages: WrittenPackages,
		completion: @escaping (Result<[ENExposureWindow], Error>) -> Void
	) -> Progress {
		let progress = Progress(totalUnitCount: Int64.max)

		let detectExposuresProgress = exposureDetector.detectExposures(
			configuration: configuration,
			diagnosisKeyURLs: writtenPackages.urls
		) { [weak self] summary, error in
			guard let self = self else { return }

			if let summary = summary {
				let exposureWindowsProgress = self.exposureDetector.getExposureWindows(summary: summary) { exposureWindows, error in
					if let exposureWindows = exposureWindows {
						completion(.success(exposureWindows))
					} else if let error = error {
						self.clearCacheOnErrorBadParameter(error: error)
						completion(.failure(error))
					}
				}
				
				// Prevent adding a child which is perhaps already finished or cancelled because this would crash the app.
				guard !exposureWindowsProgress.isFinished, !exposureWindowsProgress.isCancelled else {
					Log.info("Not adding a child due to already finished or cancelled exposureWindowsProgress", log: .riskDetection)
					completion(.failure(ExposureDetectionError.isAlreadyRunning))
					return
				}
				
				Log.info("2nd child added to progress", log: .riskDetection)
				progress.addChild(exposureWindowsProgress, withPendingUnitCount: 1)
			} else if let error = error {
				self.clearCacheOnErrorBadParameter(error: error)
				completion(.failure(error))
			}
		}
		
		// Prevent adding a child which is perhaps already finish or cancelled because this would crash the app.
		guard !detectExposuresProgress.isFinished, !detectExposuresProgress.isCancelled else {
			Log.info("Not adding a child due to already finished or cancelled detectExposuresProgress", log: .riskDetection)
			return progress
		}

		Log.info("1st child added to progress", log: .riskDetection)
		progress.addChild(detectExposuresProgress, withPendingUnitCount: 1)

		return progress
	}

	// Clear the key packages and app config on ENError = 2 = .badParameter
	// For more details, see: https://jira.itc.sap.com/browse/EXPOSUREAPP-3297
	private func clearCacheOnErrorBadParameter(error: Error) {
		if let enError = error as? ENError, enError.code == .badParameter {
			// Clear the key packages
			downloadedPackagesStore.reset()
			downloadedPackagesStore.open()

            // Clear the app config
            store.appConfigMetadata = nil
		}
	}

}
