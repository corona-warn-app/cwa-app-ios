// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.
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
				isEnabled: { [wifiClient] in
					wifiClient.disableHourlyDownload
				}, toggle: { [wifiClient] in
					wifiClient.disableHourlyDownload = !wifiClient.disableHourlyDownload
					Log.info("Hourly packages download: \(wifiClient.disableHourlyDownload ? "disabled" :"enabled")")
				})

		case .disableClient:
			return DMSwitchCellViewModel(
				labelText: "Hourly packages over WiFi only",
				isEnabled: { [wifiClient] in
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
