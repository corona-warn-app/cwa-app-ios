//
// 🦠 Corona-Warn-App
//

import Foundation

private func withPrefix(_ name: String) -> Notification.Name {
	Notification.Name("com.sap.ena.\(name)")
}

extension Notification.Name {
	static let isOnboardedDidChange = withPrefix("isOnboardedDidChange")
	static let showExportCertificatesTooltipIfNeeded = withPrefix("showExportCertificatesTooltipIfNeeded")
}
