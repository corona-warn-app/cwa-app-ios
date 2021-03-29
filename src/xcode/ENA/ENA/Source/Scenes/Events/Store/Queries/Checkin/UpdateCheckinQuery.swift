////
// 🦠 Corona-Warn-App
//

import FMDB

class UpdateCheckinQuery: StoreQueryProtocol {

	// MARK: - Init

	init(
		checkin: Checkin,
		maxTextLength: Int
	) {
		self.checkin = checkin
		self.maxTextLength = maxTextLength
	}

	// MARK: - Protocol StoreQuery

	func execute(in database: FMDatabase) -> Bool {
		let sql = """
			UPDATE Checkin SET
			traceLocationId = ?,
			traceLocationIdHash = ?,
			traceLocationVersion = ?,
			traceLocationType = ?,
			traceLocationDescription = SUBSTR(?, 1, \(maxTextLength)),
			traceLocationAddress = SUBSTR(?, 1, \(maxTextLength)),
			traceLocationStartDate = ?,
			traceLocationEndDate = ?,
			traceLocationDefaultCheckInLengthInMinutes = ?,
			cryptographicSeed = ?,
			cnMainPublicKey = ?,
			checkinStartDate = ?,
			checkinEndDate = ?,
			checkinCompleted = ?,
			createJournalEntry = ?
			WHERE id = ?;
		"""

		var traceLocationStartDateInterval: Int?
		if let traceLocationStart = checkin.traceLocationStartDate {
			traceLocationStartDateInterval = Int(traceLocationStart.timeIntervalSince1970)
		}

		var traceLocationEndDateInterval: Int?
		if let traceLocationEnd = checkin.traceLocationEndDate {
			traceLocationEndDateInterval = Int(traceLocationEnd.timeIntervalSince1970)
		}

		do {
			try database.executeUpdate(
				sql,
				values: [
					checkin.traceLocationId,
					checkin.traceLocationIdHash,
					checkin.traceLocationVersion,
					checkin.traceLocationType.rawValue,
					checkin.traceLocationDescription,
					checkin.traceLocationAddress,
					traceLocationStartDateInterval as Any,
					traceLocationEndDateInterval as Any,
					checkin.traceLocationDefaultCheckInLengthInMinutes as Any,
					checkin.cryptographicSeed,
					checkin.cnMainPublicKey,
					Int(checkin.checkinStartDate.timeIntervalSince1970),
					Int(checkin.checkinEndDate.timeIntervalSince1970),
					checkin.checkinCompleted,
					checkin.createJournalEntry,
					checkin.id
				]
			)
			return true
		} catch {
			return false
		}

	}

	// MARK: - Private

	private let checkin: Checkin
	private let maxTextLength: Int
}
