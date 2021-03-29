////
// 🦠 Corona-Warn-App
//

import FMDB

class DeleteTraceLocationQuery: StoreQueryProtocol {

	// MARK: - Init

	init(id: Data) {
		self.id = id
	}

	// MARK: - Protocol StoreQueryProtocol

	func execute(in database: FMDatabase) -> Bool {
		let sql = """
			DELETE FROM TraceLocation
			WHERE id = ?;
		"""

		do {
			try database.executeUpdate(sql, values: [id])
		} catch {
			return false
		}

		return true
	}

	// MARK: - Private

	private let id: Data

}
