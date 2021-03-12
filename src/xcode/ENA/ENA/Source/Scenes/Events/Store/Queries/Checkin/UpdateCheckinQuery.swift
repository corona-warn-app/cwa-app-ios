////
// 🦠 Corona-Warn-App
//

import FMDB

class UpdateCheckinQuery: StoreQueryProtocol {

	// MARK: - Init

	init(
		id: Int,
		endDate: Date
	) {
		self.id = id
		self.endDate = endDate
	}

	// MARK: - Protocol StoreQuery

	func execute(in database: FMDatabase) -> Bool {
		let sql = """
			UPDATE Checkin
			SET checkinEndDate = ?
			WHERE id = ?
		"""

		do {
			try database.executeUpdate(
				sql,
				values: [
					Int(endDate.timeIntervalSince1970),
					id
				]
			)
			return true
		} catch {
			return false
		}

	}

	// MARK: - Private

	private let id: Int
	private let endDate: Date
}
