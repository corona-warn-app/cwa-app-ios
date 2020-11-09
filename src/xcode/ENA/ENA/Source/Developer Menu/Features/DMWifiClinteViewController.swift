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
	}

	// MARK: - Protocol <#Name#>

	// MARK: - Public

	// MARK: - Internal

	// MARK: - Private

	private let wifiSwitch = UISwitch()
	private let wifiClient: WifiOnlyHTTPClient

	private func setupView() {
		view.backgroundColor = .systemBackground

		let label = UILabel(frame: .zero)
		label.translatesAutoresizingMaskIntoConstraints = false
		label.text = "turn wifi hourly keys download on"
		label.numberOfLines = 1
		label.textAlignment = .center

		wifiSwitch.translatesAutoresizingMaskIntoConstraints = false
		let stackView = UIStackView(arrangedSubviews: [label, wifiSwitch])
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.alignment = .center
		stackView.distribution = .fillProportionally
		stackView.axis = .horizontal
		stackView.spacing = 4.0

		view.addSubview(stackView)

		NSLayoutConstraint.activate([
			view.layoutMarginsGuide.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
			view.layoutMarginsGuide.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
			view.layoutMarginsGuide.topAnchor.constraint(equalTo: stackView.topAnchor),
			stackView.heightAnchor.constraint(equalToConstant: 100.0)
		])
	}

	@objc
	private func didToggleSwitch() {
//		clien
	}

}

#endif
