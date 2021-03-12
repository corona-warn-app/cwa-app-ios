////
// 🦠 Corona-Warn-App
//

import Foundation

struct TraceWarningDiscovery: Decodable {
	let oldest: Int
	let latest: Int
	let availablePackagesOnCDN: [Int]
	let eTag: String?
}
