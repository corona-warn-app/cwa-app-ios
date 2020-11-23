//
// 🦠 Corona-Warn-App
//

#if !RELEASE

import Foundation
import UIKit

final class DMWifiClientViewModel {

	// MARK: - Init

	init(wifiClient: WifiOnlyHTTPClient) {
		self.wifiClient = wifiClient
	}

	// MARK: - Overrides

	// MARK: - Public

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
				isOn: { [wifiClient] in
					wifiClient.disableHourlyDownload
				}, toggle: { [wifiClient] in
					wifiClient.disableHourlyDownload = !wifiClient.disableHourlyDownload
					Log.info("Hourly packages download: \(wifiClient.disableHourlyDownload ? "disabled" :"enabled")")
				})

		case .disableClient:
			return DMSwitchCellViewModel(
				labelText: "Hourly packages over WiFi only",
				isOn: { [wifiClient] in
					return wifiClient.isWifiOnlyActive
				},
				toggle: { [wifiClient] in
					let newState = !wifiClient.isWifiOnlyActive
					wifiClient.updateSession(wifiOnly: newState)
					Log.info("HTTP Client mode changed to: \(wifiClient.isWifiOnlyActive ? "wifi only" : "all networks")")
				}
			)
		}
	}

	// MARK: - Private

	private let wifiClient: WifiOnlyHTTPClient

	private enum menuItems: Int, CaseIterable {
		case wifiMode
		case disableClient
	}

}

#endif
