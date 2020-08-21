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

import UIKit

final class HomeActivateCellConfigurator: CollectionViewCellConfigurator {

	private var state: ENStateHandler.State

	init(state: ENStateHandler.State) {
		self.state = state
	}

	// MARK: Configuring a Cell

	func configure(cell: ActivateCollectionViewCell) {
		switch state {
		case .enabled:
			cell.configure(
				title: AppStrings.Home.activateCardOnTitle,
				icon: UIImage(named: "Icons_Risikoermittlung_25"),
				animationImages: (0...60).compactMap({ UIImage(named: String(format: "Icons_Risikoermittlung_%02d", $0)) }),
				accessibilityIdentifier: AccessibilityIdentifiers.Home.activateCardOnTitle
			)

		case .disabled, .restricted, .notAuthorized, .unknown:
			cell.configure(
				title: AppStrings.Home.activateCardOffTitle,
				icon: UIImage(named: "Icons_Risikoermittlung_gestoppt"),
				accessibilityIdentifier: AccessibilityIdentifiers.Home.activateCardOffTitle
			)

		case .bluetoothOff:
			cell.configure(
				title: AppStrings.Home.activateCardBluetoothOffTitle,
				icon: UIImage(named: "Icons_Bluetooth_aus"),
				accessibilityIdentifier: AccessibilityIdentifiers.Home.activateCardBluetoothOffTitle
			)
		}
	}

	// MARK: Hashable
	
	func hash(into hasher: inout Swift.Hasher) {
		hasher.combine(state)
	}

	static func == (lhs: HomeActivateCellConfigurator, rhs: HomeActivateCellConfigurator) -> Bool {
		lhs.state == rhs.state
	}

}

extension HomeActivateCellConfigurator: ENStateHandlerUpdating {
	func updateEnState(_ state: ENStateHandler.State) {
		self.state = state
	}
}
