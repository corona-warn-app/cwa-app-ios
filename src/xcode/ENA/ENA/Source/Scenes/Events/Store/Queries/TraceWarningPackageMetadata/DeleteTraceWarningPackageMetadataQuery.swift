////
// 🦠 Corona-Warn-App
//

import FMDB

class DeleteTraceWarningPackageMetadataQuery: StoreQueryProtocol {

	// MARK: - Init

	init(id: Int) {
		self.id = id
	}

	// MARK: - Protocol StoreQueryProtocol

	func execute(in database: FMDatabase) -> Bool {
		let sql = """
			DELETE FROM TraceWarningPackageMetadata
			WHERE id = ?;
		"""

		do {
			try database.executeUpdate(sql, values: [id])
			return true
		} catch {
			return false
		}
	}

	// MARK: - Private

	private let id: Int

}
