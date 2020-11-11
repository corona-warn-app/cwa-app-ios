//
// Created by Hu, Hao on 06.06.20.
// Copyright (c) 2020 SAP SE. All rights reserved.
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
		let rootDir = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
		do {
			try fileManager.createDirectory(at: rootDir, withIntermediateDirectories: true, attributes: nil)
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

	func exposureDetection(
			_ detection: ExposureDetection,
			detectSummaryWithConfiguration configuration: ENExposureConfiguration,
			writtenPackages: WrittenPackages,
			completion: @escaping (Result<ENExposureDetectionSummary, Error>) -> Void
	) -> Progress {

		// Clear the key packages and app config on ENError = 2 = .badParameter
		// For more details, see: https://jira.itc.sap.com/browse/EXPOSUREAPP-3297
		func clearCacheOnErrorBadParameter(error: Error) {
			if let enError = error as? ENError, enError.code == .badParameter {
				// Clear the key packages
				downloadedPackagesStore.reset()
				downloadedPackagesStore.open()

				// Clear the app config
				store.appConfigMetadata = nil
			}
		}

		func withResultFrom(
				summary: ENExposureDetectionSummary?,
				error: Error?
		) -> Result<ENExposureDetectionSummary, Error> {
			if let error = error {
				clearCacheOnErrorBadParameter(error: error)
				return .failure(error)
			}
			if let summary = summary {
				return .success(summary)
			}
			fatalError("invalid state")
		}
		return exposureDetector.detectExposures(
				configuration: configuration,
				diagnosisKeyURLs: writtenPackages.urls
		) { summary, error in
			completion(withResultFrom(summary: summary, error: error))
		}
	}
}
