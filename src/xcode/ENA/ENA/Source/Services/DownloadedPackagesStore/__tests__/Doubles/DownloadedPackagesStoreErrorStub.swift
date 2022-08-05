//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class DownloadedPackagesStoreErrorStub: DownloadedPackagesStoreV3 {
	
	private let error: DownloadedPackagesSQLLiteStore.StoreError

	init(error: DownloadedPackagesSQLLiteStore.StoreError) {
		self.error = error
	}

	func open() { }

	func close() { }

	func markPackagesAsCheckedForExposures(_ fingerprints: [String]) throws {
	}
	
	func set(country: Country.ID, hour: Int, day: String, etag: String?, package: SAPDownloadedPackage?) throws {
		throw error
	}

	func set(country: Country.ID, day: String, etag: String?, package: SAPDownloadedPackage?) throws {
		throw error
	}

	func packages(with etag: String?) -> [SAPDownloadedPackage]? {
		nil
	}

	func packages(with etags: [String]) -> [SAPDownloadedPackage]? {
		nil
	}

	func package(for day: String, country: Country.ID) -> SAPDownloadedPackage? {
		return nil
	}
	
	func hourlyPackages(for day: String, country: Country.ID) -> [SAPDownloadedPackage] {
		return [SAPDownloadedPackage]()
	}
	
	func hourlyPackagesNotCheckedForExposure(for day: String, country: Country.ID) -> [SAPDownloadedPackage] {
		return [SAPDownloadedPackage]()
	}

	func allDays(country: Country.ID) -> [String] {
		return [String]()
	}
	
	func allDaysNotCheckedForExposure(country: Country.ID) -> [String] {
		return [String]()
	}

	func hours(for day: String, country: Country.ID) -> [Int] {
		return [Int]()
	}

	func reset() { }

	func delete(package: SAPDownloadedPackage) throws { }

	func delete(packages: [SAPDownloadedPackage]) throws { }

	func deleteOldPackages(before referenceDate: String) { }
	
	func deleteHourPackage(for day: String, hour: Int, country: Country.ID) { }

	func deleteDayPackage(for day: String, country: Country.ID) { }

	var keyValueStore: Store?

	var revokationList: [String] = []

}
