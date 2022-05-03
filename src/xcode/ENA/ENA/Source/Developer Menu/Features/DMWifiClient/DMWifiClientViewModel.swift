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
					return true
//					wifiClient.disableHourlyDownload
				}, toggle: { [restService] in
//					wifiClient.disableHourlyDownload = !wifiClient.disableHourlyDownload
//					Log.info("Hourly packages download: \(wifiClient.disableHourlyDownload ? "disabled" :"enabled")")
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
