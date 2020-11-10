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

#if !RELEASE

import UIKit

class DMWifiClinteViewController: UIViewController {

	// MARK: - Init

	init(wifiClient: WifiOnlyHTTPClient) {
		self.wifiClient = wifiClient
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("not supported")
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()

		setupView()
		setupSwitches()

		title = "Wifi mode 🎛"
	}

	// MARK: - Public

	// MARK: - Internal

	// MARK: - Private

	private let wifiSwitch = UISwitch()
	private let disableSwitch = UISwitch()
	private let wifiClient: WifiOnlyHTTPClient

	private func setupView() {
		view.backgroundColor = .systemBackground

		let wifiOnlyLabel = UILabel(frame: .zero)
		wifiOnlyLabel.translatesAutoresizingMaskIntoConstraints = false
		wifiOnlyLabel.text = "Hourly packages over WiFi only"
		wifiOnlyLabel.numberOfLines = 1
		wifiOnlyLabel.textAlignment = .left

		wifiSwitch.translatesAutoresizingMaskIntoConstraints = false

		let wifiOnlyStackView = UIStackView(arrangedSubviews: [wifiOnlyLabel, wifiSwitch])
		wifiOnlyStackView.translatesAutoresizingMaskIntoConstraints = false
		wifiOnlyStackView.alignment = .center
		wifiOnlyStackView.distribution = .fillProportionally
		wifiOnlyStackView.axis = .horizontal
		wifiOnlyStackView.spacing = 4.0

		let disableDownloadLabel = UILabel(frame: .zero)
		disableDownloadLabel.translatesAutoresizingMaskIntoConstraints = false
		disableDownloadLabel.text = "Disable hourly packages download"
		disableDownloadLabel.numberOfLines = 1
		disableDownloadLabel.textAlignment = .left

		disableSwitch.translatesAutoresizingMaskIntoConstraints = false
		let disableStackView = UIStackView(arrangedSubviews: [disableDownloadLabel, disableSwitch])
		disableStackView.translatesAutoresizingMaskIntoConstraints = false
		disableStackView.alignment = .center
		disableStackView.distribution = .fill
		disableStackView.axis = .horizontal
		disableStackView.spacing = 4.0

		let containerStackView = UIStackView(arrangedSubviews: [wifiOnlyStackView, disableStackView])
		containerStackView.translatesAutoresizingMaskIntoConstraints = false
		containerStackView.alignment = .top
		containerStackView.distribution = .equalSpacing
		containerStackView.axis = .vertical
		containerStackView.spacing = 4.0
		containerStackView.isLayoutMarginsRelativeArrangement = true

		view.addSubview(containerStackView)
		NSLayoutConstraint.activate([
			view.layoutMarginsGuide.leadingAnchor.constraint(equalTo: containerStackView.leadingAnchor),
			view.layoutMarginsGuide.trailingAnchor.constraint(equalTo: containerStackView.trailingAnchor),
			view.layoutMarginsGuide.topAnchor.constraint(equalTo: containerStackView.topAnchor),
			view.layoutMarginsGuide.bottomAnchor.constraint(greaterThanOrEqualTo: containerStackView.bottomAnchor)
		])
	}

	private func setupSwitches() {
		wifiSwitch.addTarget(self, action: #selector(didToggleSwitch(sender:)), for: .valueChanged)
		wifiSwitch.isOn = wifiClient.isWifiOnlyActive
		disableSwitch.addTarget(self, action: #selector(didToggleDisableSwicth(sender:)), for: .valueChanged)
		disableSwitch.isOn = wifiClient.disableHourlyDownload
	}

	@objc
	private func didToggleSwitch(sender: UISwitch) {
		wifiClient.updateSession(wifiOnly: sender.isOn)
		Log.info("HTTP Client mode changed to: \(wifiClient.isWifiOnlyActive ? "wifi only" : "all networks")")
	}

	@objc
	private func didToggleDisableSwicth(sender: UISwitch) {
		wifiClient.disableHourlyDownload = sender.isOn
		Log.info("Hourly packages download: \(wifiClient.disableHourlyDownload ? "disabled" :"enabled")")
	}
}

#endif
