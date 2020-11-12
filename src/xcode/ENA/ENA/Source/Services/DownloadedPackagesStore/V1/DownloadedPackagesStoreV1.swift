//
// 🦠 Corona-Warn-App
//

import Foundation
import FMDB

enum SQLiteErrorCode: Int32 {
	case sqlite_full = 13
	case unknown = -1
}

protocol DownloadedPackagesStoreV1: AnyObject {
	func open()
	func close()

	func set(
		country: Country.ID,
		day: String,
		package: SAPDownloadedPackage,
		completion: ((SQLiteErrorCode?) -> Void)?
	)

	func set(country: Country.ID, hour: Int, day: String, package: SAPDownloadedPackage)
	func package(for day: String, country: Country.ID) -> SAPDownloadedPackage?
	func hourlyPackages(for day: String, country: Country.ID) -> [SAPDownloadedPackage]
	func allDays(country: Country.ID) -> [String] // 2020-05-30
	func hours(for day: String, country: Country.ID) -> [Int]
	func reset()
	func deleteOutdatedDays(now: String) throws

	#if !RELEASE

	var keyValueStore: Store? { get set }

	#endif
}
