////
// 🦠 Corona-Warn-App
//

import FMDB

protocol StoreQueryProtocol {
	func execute(in database: FMDatabase) -> Bool
}
