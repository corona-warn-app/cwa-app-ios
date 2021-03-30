////
// 🦠 Corona-Warn-App
//

// This implementation is based on the following technical specification.
// For more details please see: https://github.com/corona-warn-app/cwa-app-tech-spec/blob/e87ef2851c91141573d5714fd24485219280543e/docs/spec/event-registration-client.md

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
				id,
				version,
				type,
				description,
				address,
				startDate,
				endDate,
				defaultCheckInLengthInMinutes,
				cryptographicSeed,
				cnPublicKey
			)
			VALUES (
				:id,
				:version,
				:type,
				SUBSTR(:description, 1, \(maxTextLength)),
				SUBSTR(:address, 1, \(maxTextLength)),
				:startDate,
				:endDate,
				:defaultCheckInLengthInMinutes,
				:cryptographicSeed,
				:cnPublicKey
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
			"id": traceLocation.id,
			"version": traceLocation.version,
			"type": traceLocation.type.rawValue,
			"description": traceLocation.description,
			"address": traceLocation.address,
			"startDate": startDateInterval as Any,
			"endDate": endDateInterval as Any,
			"defaultCheckInLengthInMinutes": traceLocation.defaultCheckInLengthInMinutes as Any,
			"cryptographicSeed": traceLocation.cryptographicSeed,
			"cnPublicKey": traceLocation.cnPublicKey
		]

		return database.executeUpdate(sql, withParameterDictionary: parameters)
	}

	// MARK: - Private

	private let traceLocation: TraceLocation
	private let maxTextLength: Int

}
