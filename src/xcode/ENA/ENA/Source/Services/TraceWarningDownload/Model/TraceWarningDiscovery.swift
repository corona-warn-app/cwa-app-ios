////
// 🦠 Corona-Warn-App
//

import Foundation

struct TraceWarningDiscovery: Decodable {
	let oldest: Int
	let latest: Int
	let eTag: String?
	
	var availablePackagesOnCDN: [Int] {
		return latest < oldest ? [] : Array(oldest...latest)
	}
}
