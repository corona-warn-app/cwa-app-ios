////
// 🦠 Corona-Warn-App
//

import FMDB

class DeleteTraceLocationQuery: StoreQueryProtocol {

	// MARK: - Init

	init(guid: String) {
		self.guid = guid
	}

	// MARK: - Protocol StoreQueryProtocol

	func execute(in database: FMDatabase) -> Bool {
		let sql = """
			DELETE FROM TraceLocation
			WHERE guid = ?;
		"""

		do {
			try database.executeUpdate(sql, values: [guid])
		} catch {
			return false
		}

		return true
	}

	// MARK: - Private

	private let guid: String

}
