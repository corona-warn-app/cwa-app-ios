////
// 🦠 Corona-Warn-App
//

import FMDB

final class ContactDiaryMigration1To2: Migration {

	private let database: FMDatabase

	init(database: FMDatabase) {
		self.database = database
	}

	func execute() throws {
		let tableNames = ["ContactPerson", "Location"]
		
		for tableName in tableNames {
			let queryResult = database.prepare("PRAGMA table_info(" + tableName + ")" )
			var finalSQL: String?
			
			while queryResult.next() {
				let name = queryResult.string(forColumn: "name")
				let type = queryResult.string(forColumn: "type")

				// do migration for contact diary tables if the type of the Column "name" is "STRING"
				if name == "name" && type == "STRING" {
					finalSQL = """
					CREATE TABLE tmp (
					id INTEGER PRIMARY KEY,
					name TEXT NOT NULL CHECK (LENGTH(name) <= 250)
					);
					INSERT INTO tmp (id, name)
					SELECT id, name
					FROM \(tableName);
					DROP TABLE \(tableName);
					ALTER TABLE tmp RENAME TO \(tableName) ;
					"""

					break
				}
			}
			
			queryResult.close()
			
			guard let sql = finalSQL, database.executeStatements(sql) else {
				throw MigrationError.general(description: "(\(database.lastErrorCode())) \(database.lastErrorMessage())")
			}
		}
	}
}
