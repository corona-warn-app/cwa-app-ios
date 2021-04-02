////
// 🦠 Corona-Warn-App
//

#if !RELEASE

import Foundation

struct DMRecentTraceLocationCheckedInto: Codable {
	let description: String
	let id: Data?
	let date: Date
}

#endif
