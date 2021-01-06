//
// 🦠 Corona-Warn-App
//

#if !RELEASE

import UIKit

final class DMWifiClientViewController: UITableViewController {

	// MARK: - Init

	init(wifiClient: WifiOnlyHTTPClient) {
		self.viewModel = DMWifiClientViewModel(wifiClient: wifiClient)
		if #available(iOS 13.0, *) {
			super.init(style: .insetGrouped)
		} else {
			super.init(style: .grouped)
		}
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
		guard let cell = tableView.dequeueReusableCell(withIdentifier: "DMSwitchTableViewCell") as? DMSwitchTableViewCell else {
			let dummy = UITableViewCell(style: .default, reuseIdentifier: "DummyFallBackCell")
			dummy.textLabel?.text = "Fallback cell"
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
