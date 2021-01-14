//
// 🦠 Corona-Warn-App
//

import Foundation
import FMDB

protocol DownloadedPackagesStoreV2: AnyObject {

	func open()
	func close()

	func set(country: Country.ID, hour: Int, day: String, etag: String?, package: SAPDownloadedPackage) throws
	func set(country: Country.ID, day: String, etag: String?, package: SAPDownloadedPackage) throws

	/// Fetch key packages with a given ETag
	/// - Parameter etag: The ETag to match or `nil` to fetch all packages that do not contain an ETag
	/// - Returns: A list of matching key packages or `nil` if no matching packages were found
	func packages(with etag: String?) -> [SAPDownloadedPackage]?

	/// Fetch key packages with a given list of ETags
	/// - Parameter etags: The ETag list to match
	/// - Returns: A list of matching key packages or `nil` if no matching packages were found
	func packages(with etags: [String]) -> [SAPDownloadedPackage]?

	func package(for day: String, country: Country.ID) -> SAPDownloadedPackage?
	func hourlyPackages(for day: String, country: Country.ID) -> [SAPDownloadedPackage]
	func allDays(country: Country.ID) -> [String] // 2020-05-30
	func hours(for day: String, country: Country.ID) -> [Int]

	func reset()
	
	func deleteHourPackage(for day: String, hour: Int, country: Country.ID)
	func deleteDayPackage(for day: String, country: Country.ID)

	/// Deletes a given `SAPDownloadedPackage`.
	/// - Parameter package: The package to remove from the store
	/// - Throws: An error of type `SQLiteStoreError`
	func delete(package: SAPDownloadedPackage) throws

	/// Deletes a given list of `SAPDownloadedPackage`.
	/// - Parameter packages: A list of packages to remove from the store
	/// - Throws: An error of type `SQLiteStoreError`
	func delete(packages: [SAPDownloadedPackage]) throws

	// MARK: - Package Invalidation

	/// A list of invalid ETags to be removed/ignored. Defined in the AppConfiguration.
	var revokationList: [String] { get set }

	/// Validates currently stored key packages with a given list of ETags to be revoked. Keys matching this etag will be removed.
	/// - Parameter etags: The list of Etags to check for
	func validateCachedKeyPackages(revokationList etags: [String]) throws

	var keyValueStore: Store? { get set }
}

extension DownloadedPackagesStoreV2 {

	func addFetchedDays(_ dayPackages: [String: PackageDownloadResponse], country: Country.ID) throws {
		var revokedPackageError: Error?
		try dayPackages.forEach { day, bucket in
			do {
				try self.set(country: country, day: day, etag: bucket.etag, package: bucket.package)
			} catch DownloadedPackagesSQLLiteStore.StoreError.revokedPackage {
				revokedPackageError = DownloadedPackagesSQLLiteStore.StoreError.revokedPackage
			}
		}
		if let revokedPackageError = revokedPackageError {
			throw revokedPackageError
		}
	}

	func addFetchedHours(_ hourPackages: [Int: PackageDownloadResponse], day: String, country: Country.ID) throws {
		var revokedPackageError: Error?
		try hourPackages.forEach { hour, bucket in
			do {
				try self.set(country: country, hour: hour, day: day, etag: bucket.etag, package: bucket.package)
			} catch DownloadedPackagesSQLLiteStore.StoreError.revokedPackage {
				revokedPackageError = DownloadedPackagesSQLLiteStore.StoreError.revokedPackage
			}
		}

		if let revokedPackageError = revokedPackageError {
			throw revokedPackageError
		}
	}

	func validateCachedKeyPackages(revokationList etags: [String]) throws {
		Log.info("Validate cached key packages based on revokation list (etags): \(etags)", log: .localData)

		guard
			!etags.isEmpty,
			let packagesToRemove = packages(with: etags)
		else {
			Log.info("No package found to revoke.", log: .localData)
			return
		}

		try delete(packages: packagesToRemove)
	}
}
