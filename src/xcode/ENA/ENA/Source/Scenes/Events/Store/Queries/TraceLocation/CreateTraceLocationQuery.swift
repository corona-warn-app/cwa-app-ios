////
// 🦠 Corona-Warn-App
//

import FMDB

class CreateTraceLocationQuery: StoreQueryProtocol {

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
			INSERT INTO TraceLocation (
				guid,
				version,
				type,
				description,
				address,
				startDate,
				endDate,
				defaultCheckInLengthInMinutes,
				signature
			)
			VALUES (
				:guid,
				:version,
				:type,
				SUBSTR(:description, 1, \(maxTextLength)),
				SUBSTR(:address, 1, \(maxTextLength)),
				:startDate,
				:endDate,
				:defaultCheckInLengthInMinutes,
				:signature
			);
		"""

		var startDateInterval: Int?
		if let startDate = traceLocation.startDate {
			startDateInterval = Int(startDate.timeIntervalSince1970)
		}

		var endDateInterval: Int?
		if let endDate = traceLocation.endDate {
			endDateInterval = Int(endDate.timeIntervalSince1970)
		}

		let parameters: [String: Any] = [
			"guid": traceLocation.guid,
			"version": traceLocation.version,
			"type": traceLocation.type.rawValue,
			"description": traceLocation.description,
			"address": traceLocation.address,
			"startDate": startDateInterval as Any,
			"endDate": endDateInterval as Any,
			"defaultCheckInLengthInMinutes": traceLocation.defaultCheckInLengthInMinutes as Any,
			"signature": traceLocation.signature
		]

		return database.executeUpdate(sql, withParameterDictionary: parameters)
	}

	// MARK: - Private

	private let traceLocation: TraceLocation
	private let maxTextLength: Int

}
