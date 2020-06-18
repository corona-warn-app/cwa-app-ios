//
// Corona-Warn-App
//
// SAP SE and all other contributors
// copyright owners license this file to you under the Apache
// License, Version 2.0 (the "License"); you may not use this
// file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.
//

import UIKit

extension ENStateHandler.State {
	var homeActivateCellIconName: String {
		switch self {
		case .enabled:
			return "Icons_Risikoermittlung"
		case .disabled, .restricted, .notAuthorized, .unknown:
			return "Icons_Risikoermittlung_gestoppt"
		case .bluetoothOff:
			return "Icons_Bluetooth_aus"
		case .internetOff:
			return "Icons_Internet_aus"
		}
	}
	
	var homeActivateCellIcon: UIImage {
		// swiftlint:disable:next force_unwrapping
		UIImage(named: homeActivateCellIconName)!
	}

	var homeActivateTitle: String {
		switch self {
		case .enabled:
			return AppStrings.Home.activateCardOnTitle
		case .disabled, .restricted, .notAuthorized, .unknown:
			return AppStrings.Home.activateCardOffTitle
		case .bluetoothOff:
			return AppStrings.Home.activateCardBluetoothOffTitle
		case .internetOff:
			return AppStrings.Home.activateCardInternetOffTitle
		}
	}

	var homeActivateAccessibilityIdentifier: String {
		switch self {
		case .enabled:
			return AccessibilityIdentifiers.Home.activateCardOnTitle
		case .disabled, .restricted, .notAuthorized, .unknown:
			return AccessibilityIdentifiers.Home.activateCardOffTitle
		case .bluetoothOff:
			return AccessibilityIdentifiers.Home.activateCardBluetoothOffTitle
		case .internetOff:
			return AccessibilityIdentifiers.Home.activateCardInternetOffTitle
		}
	}
}
