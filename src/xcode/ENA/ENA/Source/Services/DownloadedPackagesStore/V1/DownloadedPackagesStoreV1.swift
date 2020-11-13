//
// 🦠 Corona-Warn-App
//

import Foundation
import FMDB

protocol DownloadedPackagesStoreV1: AnyObject {
	func open()
	func close()

	@discardableResult
	func set(
		country: Country.ID,
		day: String,
		package: SAPDownloadedPackage
	) -> Result<Void, SQLiteErrorCode>

	@discardableResult
	func set(
		country: Country.ID,
		hour: Int,
		day: String,
		package: SAPDownloadedPackage
	) -> Result<Void, SQLiteErrorCode>
	
	func package(for day: String, country: Country.ID) -> SAPDownloadedPackage?
	func hourlyPackages(for day: String, country: Country.ID) -> [SAPDownloadedPackage]
	func allDays(country: Country.ID) -> [String] // 2020-05-30
	func hours(for day: String, country: Country.ID) -> [Int]
	func reset()
	func deleteHourPackage(for day: String, hour: Int, country: Country.ID)
	func deleteDayPackage(for day: String, country: Country.ID)
	
	#if !RELEASE

	var keyValueStore: Store? { get set }

	#endif
}
