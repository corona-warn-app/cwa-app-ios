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

	let identifier = UUID()
	
	private var state: ENStateHandler.State

	init(state: ENStateHandler.State) {
		self.state = state
	}

	// MARK: Configuring a Cell

	func configure(cell: ActivateCollectionViewCell) {
		var iconImage: UIImage?
		cell.iconImageView.image?.withRenderingMode(.alwaysTemplate)

		switch state {
		case .enabled:
			iconImage = UIImage(named: "Icons_Risikoermittlung")
			cell.titleLabel.text = AppStrings.Home.activateCardOnTitle
			cell.accessibilityIdentifier = AccessibilityIdentifiers.Home.activateCardOnTitle
		case .disabled, .restricted, .notAuthorized, .unknown:
			iconImage = UIImage(named: "Icons_Risikoermittlung_gestoppt")
			cell.titleLabel.text = AppStrings.Home.activateCardOffTitle
			cell.accessibilityIdentifier = AccessibilityIdentifiers.Home.activateCardOffTitle
		case .bluetoothOff:
			iconImage = UIImage(named: "Icons_Bluetooth_aus")
			cell.titleLabel.text = AppStrings.Home.activateCardBluetoothOffTitle
			cell.accessibilityIdentifier = AccessibilityIdentifiers.Home.activateCardBluetoothOffTitle
		case .internetOff:
			iconImage = UIImage(named: "Icons_Internet_aus")
			cell.titleLabel.text = AppStrings.Home.activateCardInternetOffTitle
			cell.accessibilityIdentifier = AccessibilityIdentifiers.Home.activateCardInternetOffTitle
		}

		cell.iconImageView.image = iconImage

		cell.accessibilityLabel = cell.titleLabel.text ?? ""
	}
}

extension HomeActivateCellConfigurator: ENStateHandlerUpdating {
	func updateEnState(_ state: ENStateHandler.State) {
		self.state = state
	}
}
