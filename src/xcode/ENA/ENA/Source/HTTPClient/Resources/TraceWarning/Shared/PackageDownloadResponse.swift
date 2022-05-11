//
// 🦠 Corona-Warn-App
//

import Foundation

/// A container for a downloaded `SAPDownloadedPackage` and its corresponding `ETag`, if given.
struct PackageDownloadResponse: MetaDataProviding {

	let package: SAPDownloadedPackage?

	/// The response ETag
	///
	/// This is used to identify and revoke packages.
	var etag: String? {
		return metaData.headers.value(caseInsensitiveKey: "ETag")
	}

	var isEmpty: Bool {
		return package == nil
	}

	// MARK: - MetaDataProviding

	var metaData: MetaData = MetaData()

}
