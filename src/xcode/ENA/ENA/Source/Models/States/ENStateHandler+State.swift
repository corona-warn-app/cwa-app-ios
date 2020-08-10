//
// Created by Hu, Hao on 08.06.20.
// Copyright (c) 2020 SAP SE. All rights reserved.
//

import Foundation
extension ENStateHandler {
	enum State {
		/// Exposure Notification is enabled.
		case enabled
		/// Exposure Notification is disabled.
		case disabled
		/// Bluetooth is off.
		case bluetoothOff
		/// Restricted Mode due to parental controls.
		case restricted
		///Not authorized. The user declined consent in onboarding.
		case notAuthorized
		///The user was never asked the consent before, that's why unknown.
		case unknown
	}
}
