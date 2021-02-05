//
// 🦠 Corona-Warn-App
//

import Foundation

private func _withPrefix(_ name: String) -> Notification.Name {
	Notification.Name("com.sap.ena.\(name)")
}

extension Notification.Name {
	static let isOnboardedDidChange = _withPrefix("isOnboardedDidChange")
	static let riskStatusLowerd = _withPrefix("risKStatusLowerd")
}
