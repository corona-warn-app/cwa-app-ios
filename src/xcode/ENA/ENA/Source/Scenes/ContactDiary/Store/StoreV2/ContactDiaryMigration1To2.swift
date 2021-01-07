////
// 🦠 Corona-Warn-App
//

import FMDB

final class EmptyMigration: Migration {
	func execute() throws {}
}

final class ContactDiaryMigration1To2: Migration {

	private let databaseQueue: FMDatabaseQueue
	private var database: FMDatabase?
	
	init(databaseQueue: FMDatabaseQueue) {
		self.databaseQueue = databaseQueue
	}

	func execute() throws {
		
		var finalSQL: String?
		databaseQueue.inDatabase { database in
			let tableNames = ["ContactPerson", "Location"]
			self.database = database
			for tableName in tableNames {
				let queryResult = database.prepare("PRAGMA table_info(" + tableName + ")" )
				
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
				

			}
		}
		
		if let database = database {
			guard let sql = finalSQL, database.executeStatements(sql) else {
				throw MigrationError.general(description: "(\(database.lastErrorCode())) \(database.lastErrorMessage())")
			}
		} else {
			throw MigrationError.general(description: "Database is Nil")
		}
	}
}
