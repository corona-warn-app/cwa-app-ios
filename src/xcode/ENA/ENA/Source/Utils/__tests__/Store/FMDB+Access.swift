////
// 🦠 Corona-Warn-App
//

import FMDB

extension FMDatabaseQueue {

	func fetchAll(from table: String) -> FMResultSet {
		var _result: FMResultSet?
		inDatabase { database in
			let sql = """
				SELECT * FROM \(table);
			"""

			_result = database.executeQuery(sql, withArgumentsIn: [])
		}

		guard let result = _result else {
			return FMResultSet()
		}

		return result
	}

	func fetchItem(from table: String, with id: Int) -> FMResultSet {
		var _result: FMResultSet?
		inDatabase { database in
			let sql =
			"""
				SELECT
					*
				FROM
					\(table)
				WHERE
					id = '\(id)'
			;
			"""

			guard let queryResult = database.executeQuery(sql, withParameterDictionary: nil) else {
				return
			}

			guard queryResult.next() else {
				return
			}

			_result = queryResult
		}

		guard let result = _result else {
			return FMResultSet()
		}

		return result
	}
}
