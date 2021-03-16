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
				traceLocationVersion,
				traceLocationType,
				traceLocationDescription,
				traceLocationAddress,
				traceLocationStartDate,
				traceLocationEndDate,
				traceLocationDefaultCheckInLengthInMinutes,
				traceLocationSignature,
				checkinStartDate,
				targetCheckinEndDate,
				checkinEndDate,
				createJournalEntry
			)
			VALUES (
				:traceLocationGUID,
				:traceLocationVersion,
				:traceLocationType,
				SUBSTR(:traceLocationDescription, 1, \(maxTextLength)),
				SUBSTR(:traceLocationAddress, 1, \(maxTextLength)),
				:traceLocationStartDate,
				:traceLocationEndDate,
				:traceLocationDefaultCheckInLengthInMinutes,
				:traceLocationSignature,
				:checkinStartDate,
				:targetCheckinEndDate,
				:checkinEndDate,
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

		var checkinEndDateInterval: Int?
		if let checkinEndDate = checkin.checkinEndDate {
			checkinEndDateInterval = Int(checkinEndDate.timeIntervalSince1970)
		}

		var targetCheckinEndDateInterval: Int?
		if let targetCheckinEndDate = checkin.targetCheckinEndDate {
			targetCheckinEndDateInterval = Int(targetCheckinEndDate.timeIntervalSince1970)
		}

		let parameters: [String: Any] = [
			"traceLocationGUID": checkin.traceLocationGUID,
			"traceLocationVersion": checkin.traceLocationVersion,
			"traceLocationType": checkin.traceLocationType.rawValue,
			"traceLocationDescription": checkin.traceLocationDescription,
			"traceLocationAddress": checkin.traceLocationAddress,
			"traceLocationStartDate": traceLocationStartDateInterval as Any,
			"traceLocationEndDate": traceLocationEndDateInterval as Any,
			"traceLocationDefaultCheckInLengthInMinutes": checkin.traceLocationDefaultCheckInLengthInMinutes as Any,
			"traceLocationSignature": checkin.traceLocationSignature,
			"checkinStartDate": Int(checkin.checkinStartDate.timeIntervalSince1970),
			"targetCheckinEndDate": targetCheckinEndDateInterval as Any,
			"checkinEndDate": checkinEndDateInterval as Any,
			"createJournalEntry": checkin.createJournalEntry
		]

		return database.executeUpdate(sql, withParameterDictionary: parameters)
	}

	// MARK: - Private

	private let checkin: Checkin
	private let maxTextLength: Int

}
