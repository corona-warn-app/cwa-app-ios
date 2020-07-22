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

import Foundation
import FMDB

protocol DownloadedPackagesStore: AnyObject {
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

/// Convenience additions to `DownloadedPackagesStore`.
extension DownloadedPackagesStore {
	func allPackages(
		for day: String,
		onlyHours: Bool
	) -> [SAPDownloadedPackage] {
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
