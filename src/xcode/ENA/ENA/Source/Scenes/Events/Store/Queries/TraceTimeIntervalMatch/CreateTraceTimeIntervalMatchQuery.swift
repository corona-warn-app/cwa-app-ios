////
// 🦠 Corona-Warn-App
//

import FMDB

class CreateTraceTimeIntervalMatchQuery: StoreQueryProtocol {

	// MARK: - Init

	init(
		match: TraceTimeIntervalMatch
	) {
		self.match = match
	}

	// MARK: - Protocol StoreQuery

	func execute(in database: FMDatabase) -> Bool {
		let sql = """
			INSERT INTO TraceTimeIntervalMatch (
				checkinId,
				traceWarningPackageId,
				traceLocationId,
				transmissionRiskLevel,
				startIntervalNumber,
				endIntervalNumber
			)
			VALUES (
				:checkinId,
				:traceWarningPackageId,
				:traceLocationId,
				:transmissionRiskLevel,
				:startIntervalNumber,
				:endIntervalNumber
			);
		"""
		let parameters: [String: Any] = [
			"checkinId": match.checkinId,
			"traceWarningPackageId": match.traceWarningPackageId,
			"traceLocationId": match.traceLocationId,
			"transmissionRiskLevel": match.transmissionRiskLevel,
			"startIntervalNumber": match.startIntervalNumber,
			"endIntervalNumber": match.endIntervalNumber
		]

		return database.executeUpdate(sql, withParameterDictionary: parameters)
	}

	// MARK: - Private

	private let match: TraceTimeIntervalMatch

}
