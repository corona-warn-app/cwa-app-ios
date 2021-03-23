////
// 🦠 Corona-Warn-App
//

import FMDB

class DeleteAllTraceWarningPackageMetadataQuery: StoreQueryProtocol {

	// MARK: - Protocol StoreQueryProtocol

	func execute(in database: FMDatabase) -> Bool {
		let sql = """
			DELETE FROM TraceWarningPackageMetadata;
		"""

		do {
			try database.executeUpdate(sql, values: [])
			return true
		} catch {
			return false
		}
	}

}
