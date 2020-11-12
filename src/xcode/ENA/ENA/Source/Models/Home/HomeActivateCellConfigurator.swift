//
// 🦠 Corona-Warn-App
//

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

		case .disabled, .restricted, .notAuthorized, .unknown, .notActiveApp:
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
