////
// 🦠 Corona-Warn-App
//

import FMDB

class UpdateTraceLocationQuery: StoreQueryProtocol {

	// MARK: - Init

	init(
		traceLocation: TraceLocation,
		maxTextLength: Int
	) {
		self.traceLocation = traceLocation
		self.maxTextLength = maxTextLength
	}

	// MARK: - Protocol StoreQuery

	func execute(in database: FMDatabase) -> Bool {
		let sql = """
			UPDATE TraceLocation SET
			version = ?,
			type = ?,
			description = SUBSTR(?, 1, \(maxTextLength)),
			address = SUBSTR(?, 1, \(maxTextLength)),
			startDate = ?,
			endDate = ?,
			defaultCheckInLengthInMinutes = ?,
			byteRepresentation = ?,
			signature = ?
			WHERE guid = ?;
		"""

		var startDateInterval: Int?
		if let startDate = traceLocation.startDate {
			startDateInterval = Int(startDate.timeIntervalSince1970)
		}

		var endDateInterval: Int?
		if let endDate = traceLocation.endDate {
			endDateInterval = Int(endDate.timeIntervalSince1970)
		}

		do {
			try database.executeUpdate(
				sql,
				values: [
					traceLocation.version,
					traceLocation.type.rawValue,
					traceLocation.description,
					traceLocation.address,
					startDateInterval as Any,
					endDateInterval as Any,
					traceLocation.defaultCheckInLengthInMinutes as Any,
					traceLocation.byteRepresentation,
					traceLocation.signature,
					traceLocation.guid
				]
			)
			return true
		} catch {
			return false
		}
	}

	// MARK: - Private

	private let traceLocation: TraceLocation
	private let maxTextLength: Int

}
