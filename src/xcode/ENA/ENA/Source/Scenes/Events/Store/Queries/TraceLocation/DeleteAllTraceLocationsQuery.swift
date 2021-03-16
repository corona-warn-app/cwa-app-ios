////
// 🦠 Corona-Warn-App
//

import FMDB

class DeleteAllTraceLocationsQuery: StoreQueryProtocol {

	// MARK: - Protocol StoreQueryProtocol

	func execute(in database: FMDatabase) -> Bool {
		let sql = """
			DELETE FROM TraceLocation;
		"""

		do {
			try database.executeUpdate(sql, values: [])
			return true
		} catch {
			return false
		}
	}

}
