//
// 🦠 Corona-Warn-App
//

import Foundation

extension String {
	var localized: String {
		self.localized(tableName: nil)
	}

	func localized(tableName: String? = nil) -> String {
		NSLocalizedString(self, tableName: tableName, comment: "")
	}
}
