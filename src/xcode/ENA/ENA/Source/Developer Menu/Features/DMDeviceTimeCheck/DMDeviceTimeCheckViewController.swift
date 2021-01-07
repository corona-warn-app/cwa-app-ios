//
// 🦠 Corona-Warn-App
//

#if !RELEASE

import UIKit

final class DMDeviceTimeCheckViewController: UITableViewController {

	// MARK: - Init

	init(store: Store) {
		self.viewModel = DMDeviceTimeCheckViewModel(store: store)
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
		title = "Device Time Check 📱 🕰"
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

	private let viewModel: DMDeviceTimeCheckViewModel

	private func setupTableView() {
		tableView.register(UINib(nibName: "DMSwitchTableViewCell", bundle: nil), forCellReuseIdentifier: "DMSwitchTableViewCell")
	}
}

#endif
