//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class HomeExposureLoggingCellModel {

	// MARK: - Init

	init(state: HomeState) {
		state.$enState
			.sink { [weak self] enState in
				self?.update(for: enState)
			}
			.store(in: &subscriptions)
	}

	// MARK: - Internal

	@OpenCombine.Published var title: String?
	@OpenCombine.Published var icon: UIImage?
	@OpenCombine.Published var animationImages: [UIImage]?
	@OpenCombine.Published var accessibilityIdentifier: String?

	// MARK: - Private

	private var subscriptions = Set<AnyCancellable>()

	private func update(for state: ENStateHandler.State) {
		switch state {
		case .enabled:
			title = AppStrings.Home.activateCardOnTitle
			icon = UIImage(named: "Icons_Risikoermittlung_25")
			animationImages = (0...60).compactMap({ UIImage(named: String(format: "Icons_Risikoermittlung_%02d", $0)) })
			accessibilityIdentifier = AccessibilityIdentifiers.Home.activateCardOnTitle

		case .disabled, .restricted, .notAuthorized, .unknown, .notActiveApp:
			title = AppStrings.Home.activateCardOffTitle
			icon = UIImage(named: "Icons_Risikoermittlung_gestoppt")
			animationImages = nil
			accessibilityIdentifier = AccessibilityIdentifiers.Home.activateCardOffTitle

		case .bluetoothOff:
			title = AppStrings.Home.activateCardBluetoothOffTitle
			icon = UIImage(named: "Icons_Bluetooth_aus")
			animationImages = nil
			accessibilityIdentifier = AccessibilityIdentifiers.Home.activateCardBluetoothOffTitle
		}
	}

}
