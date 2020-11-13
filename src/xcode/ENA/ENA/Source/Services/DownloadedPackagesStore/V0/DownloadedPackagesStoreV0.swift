//
// 🦠 Corona-Warn-App
//

import Foundation
import FMDB

protocol DownloadedPackagesStoreV0: AnyObject {
	func open()
	func close()
	func set(day: String, package: SAPDownloadedPackage)
	func set(hour: Int, day: String, package: SAPDownloadedPackage)
	func package(for day: String) -> SAPDownloadedPackage?
	func hourlyPackages(for day: String) -> [SAPDownloadedPackage]
	func allDays() -> [String] // 2020-05-30
	func hours(for day: String) -> [Int]
	func reset()
	func deleteOutdatedDays(now: String) throws
}
