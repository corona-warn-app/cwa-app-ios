////
// 🦠 Corona-Warn-App
//

import FMDB

class DeleteCheckinsQuery: StoreQueryProtocol {

	// MARK: - Protocol StoreQueryProtocol

	func execute(in database: FMDatabase) -> Bool {
		let sql = """
			DELETE FROM Checkin;
		"""

		do {
			try database.executeUpdate(sql, values: [])
			return true
		} catch {
			return false
		}
	}

}
