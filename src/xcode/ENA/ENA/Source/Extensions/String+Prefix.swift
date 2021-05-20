//
// 🦠 Corona-Warn-App
//

import Foundation

extension String {
	func remove(prefix: String) -> String {
		guard self.hasPrefix(prefix) else { return self }
		return String(self.dropFirst(prefix.count))
	}
}
