////
// 🦠 Corona-Warn-App
//

// This implementation is based on the following technical specification.
// For more details please see: https://github.com/corona-warn-app/cwa-app-tech-spec/blob/e87ef2851c91141573d5714fd24485219280543e/docs/spec/event-registration-client.md

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
