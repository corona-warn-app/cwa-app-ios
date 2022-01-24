//
// 🦠 Corona-Warn-App
//

import Foundation

struct CacheData: Codable {
	let data: Data
	let eTag: String
	let date: Date
}
