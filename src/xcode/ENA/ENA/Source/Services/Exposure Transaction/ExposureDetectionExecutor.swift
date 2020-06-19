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

	func exposureDetection(
		_ detection: ExposureDetection,
		determineAvailableData completion: @escaping (DaysAndHours?) -> Void
	) {
		client.availableDays { result in
			switch result {
			case let .success(days):
				completion((days: days, hours: []))
			case .failure:
				completion(nil)
			}
		}
	}

	func exposureDetection(_ detection: ExposureDetection, downloadDeltaFor remote: DaysAndHours) -> DaysAndHours {
		// prune the store
		try? downloadedPackagesStore.deleteOutdatedDays(now: .formattedToday())
		
		let delta = DeltaCalculationResult(
			remoteDays: Set(remote.days),
			remoteHours: Set(remote.hours),
			localDays: Set(downloadedPackagesStore.allDays()),
			localHours: Set(downloadedPackagesStore.hours(for: .formattedToday()))
		)
		return (
			days: Array(delta.missingDays),
			hours: Array(delta.missingHours)
		)
	}

	func exposureDetection(_ detection: ExposureDetection, downloadAndStore delta: DaysAndHours, completion: @escaping (Error?) -> Void) {
		func storeDaysAndHours(_ fetchedDaysAndHours: FetchedDaysAndHours) {
			downloadedPackagesStore.addFetchedDaysAndHours(fetchedDaysAndHours)
			completion(nil)
		}
		client.fetchDays(
				delta.days,
				hours: delta.hours,
				of: .formattedToday(),
				completion: storeDaysAndHours
		)
	}

	func exposureDetection(_ detection: ExposureDetection, downloadConfiguration completion: @escaping (ENExposureConfiguration?) -> Void) {
		client.exposureConfiguration(completion: completion)
	}

	func exposureDetectionWriteDownloadedPackages(_ detection: ExposureDetection) -> WrittenPackages? {
		let fileManager = FileManager()
		let rootDir = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
		do {
			try fileManager.createDirectory(at: rootDir, withIntermediateDirectories: true, attributes: nil)
			let packages = downloadedPackagesStore.allPackages(for: .formattedToday(), onlyHours: store.hourlyFetchingEnabled)
			let writer = AppleFilesWriter(rootDir: rootDir, keyPackages: packages)
			return writer.writeAllPackages()
		} catch {
			return nil
		}
	}

	func exposureDetection(
			_ detection: ExposureDetection,
			detectSummaryWithConfiguration
			configuration: ENExposureConfiguration,
			writtenPackages: WrittenPackages,
			completion: @escaping (Result<ENExposureDetectionSummary, Error>) -> Void
	) {
		func withResultFrom(
				summary: ENExposureDetectionSummary?,
				error: Error?
		) -> Result<ENExposureDetectionSummary, Error> {
			if let error = error {
				return .failure(error)
			}
			if let summary = summary {
				return .success(summary)
			}
			fatalError("invalid state")
		}
		_ = exposureDetector.detectExposures(
				configuration: configuration,
				diagnosisKeyURLs: writtenPackages.urls
		) { summary, error in
			completion(withResultFrom(summary: summary, error: error))
		}
	}

}

extension DownloadedPackagesStore {
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
}

private extension DownloadedPackagesStore {
	func allPackages(for day: String, onlyHours: Bool) -> [SAPDownloadedPackage] {
		var packages = [SAPDownloadedPackage]()

		if onlyHours {  // Testing only: Feed last three hours into framework
			let allHoursForToday = hourlyPackages(for: .formattedToday())
			packages.append(contentsOf: Array(allHoursForToday.prefix(3)))
		} else {
			let fullDays = allDays()
			packages.append(
				contentsOf: fullDays.map { package(for: $0) }.compactMap { $0 }
			)
		}

		return packages
	}
}
