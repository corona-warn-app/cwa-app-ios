//
// 🦠 Corona-Warn-App
//

import Foundation
extension ENStateHandler {
	enum State: Equatable {
		/// Exposure Notification is enabled.
		case enabled
		/// Exposure Notification is disabled.
		case disabled
		/// Bluetooth is off.
		case bluetoothOff
		/// Restricted Mode due to parental controls.
		case restricted
		/// Not authorized. The user declined consent in onboarding.
		case notAuthorized
		/// ENStatus is restricted but ENAuthorization Status is authorized. App was not set as active for the region.
		case notActiveApp
		/// The user was never asked the consent before, that's why unknown.
		case unknown
	}
}
