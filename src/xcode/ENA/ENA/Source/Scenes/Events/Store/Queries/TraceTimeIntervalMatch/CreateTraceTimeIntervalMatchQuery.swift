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
				traceLocationGUID,
				transmissionRiskLevel,
				startIntervalNumber,
				endIntervalNumber
			)
			VALUES (
				:checkinId,
				:traceWarningPackageId,
				:traceLocationGUID,
				:transmissionRiskLevel,
				:startIntervalNumber,
				:endIntervalNumber
			);
		"""
		let parameters: [String: Any] = [
			"checkinId": match.checkinId,
			"traceWarningPackageId": match.traceWarningPackageId,
			"traceLocationGUID": match.traceLocationGUID,
			"transmissionRiskLevel": match.transmissionRiskLevel,
			"startIntervalNumber": match.startIntervalNumber,
			"endIntervalNumber": match.endIntervalNumber
		]

		return database.executeUpdate(sql, withParameterDictionary: parameters)
	}

	// MARK: - Private

	private let match: TraceTimeIntervalMatch

}
