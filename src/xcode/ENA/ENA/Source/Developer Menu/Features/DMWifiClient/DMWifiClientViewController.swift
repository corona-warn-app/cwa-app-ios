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

final class DMWifiClientViewController: UITableViewController {

	// MARK: - Init

	init(wifiClient: WifiOnlyHTTPClient) {
		self.viewModel = DMWifiClientViewModel(wifiClient: wifiClient)
		super.init(style: .insetGrouped)
	}

	required init?(coder: NSCoder) {
		fatalError("not supported")
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()
		setupTableView()
		title = "Wifi mode 🎛"
	}

	// MARK: - Protocol UITableViewDataSource

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return viewModel.itemsCount
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: "DMSwicthTableViewCell") as? DMSwitchTableViewCell else {
			let dummy = UITableViewCell(style: .default, reuseIdentifier: "DummyFallBackCell")
			dummy.textLabel?.text = "Dummyfallbacl cell"
			return dummy
		}
		cell.configure(cellViewModel: viewModel.cellViewModel(for: indexPath))
		return cell
	}

	// MARK: - Public

	// MARK: - Internal

	// MARK: - Private

	private let viewModel: DMWifiClientViewModel

	private func setupTableView() {
		tableView.register(UINib(nibName: "DMSwitchTableViewCell", bundle: nil), forCellReuseIdentifier: "DMSwitchTableViewCell")
	}
}

#endif
