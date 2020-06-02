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
	
	private var state: RiskDetectionState

	init(state: RiskDetectionState) {
		self.state = state
	}

	// MARK: Configuring a Cell

	func configure(cell: ActivateCollectionViewCell) {
		var iconImage: UIImage?
		cell.iconImageView.image?.withRenderingMode(.alwaysTemplate)

		switch state {
		case .enabled:
			iconImage = UIImage(named: "Icons_Risikoermittlung")
			cell.titleTextView.text = AppStrings.Home.activateCardOnTitle
			cell.iconImageView.tintColor = UIColor.preferredColor(for: .tint)
		case .disabled, .restricted:
			iconImage = UIImage(named: "Icons_Risikoermittlung_gestoppt")
			cell.iconImageView.tintColor = UIColor.preferredColor(for: .negativeRisk)
			cell.titleTextView.text = AppStrings.Home.activateCardOffTitle
		case .bluetoothOff:
			iconImage = UIImage(named: "Icons_Bluetooth_aus")
			cell.iconImageView.tintColor = UIColor.preferredColor(for: .negativeRisk)
			cell.titleTextView.text = AppStrings.Home.activateCardBluetoothOffTitle
		case .internetOff:
			iconImage = UIImage(systemName: "wifi.slash")
			cell.iconImageView.tintColor = UIColor.preferredColor(for: .negativeRisk)
			cell.titleTextView.text = AppStrings.Home.activateCardInternetOffTitle
		}

		cell.iconImageView.image = iconImage

		let chevronImage = UIImage(systemName: "chevron.right.circle.fill")
		cell.chevronImageView.image = chevronImage

		setupAccessibility(for: cell)
	}

	func set(newState: RiskDetectionState) {
		state = newState
	}

	func setupAccessibility(for cell: ActivateCollectionViewCell) {
		cell.isAccessibilityElement = true
		cell.accessibilityIdentifier = Accessibility.StaticText.homeActivateTitle
	}
}
