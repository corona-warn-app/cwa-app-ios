//
// 🦠 Corona-Warn-App
//

#if !RELEASE

import Foundation
import UIKit

final class DMWifiClientViewModel {

	// MARK: - Init

	init(
		restService: RestServiceProviding
	) {
		self.restService = restService
	}

	// MARK: - Internal

	var itemsCount: Int {
		return menuItems.allCases.count
	}

	func cellViewModel(for indexPath: IndexPath) -> DMSwitchCellViewModel {
		guard let item = menuItems(rawValue: indexPath.row) else {
			fatalError("failed to create cellViewModel")
		}
		switch item {

		case .wifiMode:
			return DMSwitchCellViewModel(
				labelText: "Disable hourly packages download",
				isOn: { [restService] in
					restService.isDisabled(FetchHourResource.identifier)
				}, toggle: { [restService] in
					let identifier = FetchHourResource.identifier
					if restService.isDisabled(FetchHourResource.identifier) {
						restService.enable(identifier)
						Log.info("Hourly packages download: enabled")
					} else {
						restService.disable(identifier)
						Log.info("Hourly packages download: disabled")
					}
				})

		case .disableClient:
			return DMSwitchCellViewModel(
				labelText: "Hourly packages over WiFi only",
				isOn: { [restService] in
					return restService.isWifiOnlyActive
				},
				toggle: { [restService] in
					let newState = !restService.isWifiOnlyActive
					restService.updateWiFiSession(wifiOnly: newState)
					Log.info("HTTP Client mode changed to: \(restService.isWifiOnlyActive ? "wifi only" : "all networks")")
				}
			)
		}
	}

	// MARK: - Private

	private let restService: RestServiceProviding

	private enum menuItems: Int, CaseIterable {
		case wifiMode
		case disableClient
	}

}

#endif
