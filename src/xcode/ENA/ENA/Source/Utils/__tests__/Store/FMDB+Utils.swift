////
// 🦠 Corona-Warn-App
//

import FMDB

extension FMDatabase {

	var numberOfTables: Int {
		guard let schema = getSchema() else {
			return 0
		}
		var tableCount = 0
		while schema.next() {
			tableCount += 1
		}
		return tableCount
	}
}
