////
// 🦠 Corona-Warn-App
//

import FMDB

class CreateCheckinQuery: StoreQueryProtocol {

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
			INSERT INTO Checkin (
				traceLocationGUID,
				traceLocationGUIDHash,
				traceLocationVersion,
				traceLocationType,
				traceLocationDescription,
				traceLocationAddress,
				traceLocationStartDate,
				traceLocationEndDate,
				traceLocationDefaultCheckInLengthInMinutes,
				traceLocationSignature,
				checkinStartDate,
				checkinEndDate,
				checkinCompleted,
				createJournalEntry
			)
			VALUES (
				:traceLocationGUID,
				:traceLocationGUIDHash,
				:traceLocationVersion,
				:traceLocationType,
				SUBSTR(:traceLocationDescription, 1, \(maxTextLength)),
				SUBSTR(:traceLocationAddress, 1, \(maxTextLength)),
				:traceLocationStartDate,
				:traceLocationEndDate,
				:traceLocationDefaultCheckInLengthInMinutes,
				:traceLocationSignature,
				:checkinStartDate,
				:checkinEndDate,
				:checkinCompleted,
				:createJournalEntry
			);
		"""

		var traceLocationStartDateInterval: Int?
		if let traceLocationStart = checkin.traceLocationStartDate {
			traceLocationStartDateInterval = Int(traceLocationStart.timeIntervalSince1970)
		}

		var traceLocationEndDateInterval: Int?
		if let traceLocationEnd = checkin.traceLocationEndDate {
			traceLocationEndDateInterval = Int(traceLocationEnd.timeIntervalSince1970)
		}

		let parameters: [String: Any] = [
			"traceLocationGUID": checkin.traceLocationGUID,
			"traceLocationGUIDHash": checkin.traceLocationGUIDHash,
			"traceLocationVersion": checkin.traceLocationVersion,
			"traceLocationType": checkin.traceLocationType.rawValue,
			"traceLocationDescription": checkin.traceLocationDescription,
			"traceLocationAddress": checkin.traceLocationAddress,
			"traceLocationStartDate": traceLocationStartDateInterval as Any,
			"traceLocationEndDate": traceLocationEndDateInterval as Any,
			"traceLocationDefaultCheckInLengthInMinutes": checkin.traceLocationDefaultCheckInLengthInMinutes as Any,
			"traceLocationSignature": checkin.traceLocationSignature,
			"checkinStartDate": Int(checkin.checkinStartDate.timeIntervalSince1970),
			"checkinEndDate": Int(checkin.checkinEndDate.timeIntervalSince1970),
			"checkinCompleted": checkin.checkinCompleted,
			"createJournalEntry": checkin.createJournalEntry
		]

		return database.executeUpdate(sql, withParameterDictionary: parameters)
	}

	// MARK: - Private

	private let checkin: Checkin
	private let maxTextLength: Int

}
