////
// 🦠 Corona-Warn-App
//

import FMDB

class CreateTraceWarningPackageMetadataQuery: StoreQueryProtocol {

	// MARK: - Init

	init(
		metadata: TraceWarningPackageMetadata
	) {
		self.metadata = metadata
	}

	// MARK: - Protocol StoreQuery

	func execute(in database: FMDatabase) -> Bool {
		let sql = """
			INSERT INTO TraceWarningPackageMetadata (
				id,
				region,
				eTag
			)
			VALUES (
				:id,
				:region,
				:eTag
			);
		"""
		let parameters: [String: Any] = [
			"id": metadata.id,
			"region": metadata.region,
			"eTag": metadata.eTag
		]

		return database.executeUpdate(sql, withParameterDictionary: parameters)
	}

	// MARK: - Private

	private let metadata: TraceWarningPackageMetadata

}
