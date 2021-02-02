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

	override func numberOfSections(in tableView: UITableView) -> Int {
		return viewModel.numberOfSections
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		viewModel.itemsCount
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let section = DMDeviceTimeCheckViewModel.Sections(rawValue: indexPath.section) else {
			fatalError("unknonw tableview section")
		}

		let cellViewModel = viewModel.cellViewModel(for: indexPath)
		switch section {

		case .deviceTimeCheckState, .timestampLastChange:
			guard let cell = tableView.dequeueReusableCell(withIdentifier: DMKeyValueTableViewCell.reuseIdentifier) as? DMKeyValueTableViewCell else {
				fatalError("Failed to deque cell")
			}
			cell.configure(cellViewModel: cellViewModel)
			return cell

		case .killDeviceTimeCheck:
			guard let cell = tableView.dequeueReusableCell(withIdentifier: "DMSwitchTableViewCell") as? DMSwitchTableViewCell else {
				let dummy = UITableViewCell(style: .default, reuseIdentifier: "DummyFallBackCell")
				dummy.textLabel?.text = "Fallback cell"
				return dummy
			}
			cell.configure(cellViewModel: cellViewModel)
			return cell
		}

	}

	// MARK: - Private

	private let viewModel: DMDeviceTimeCheckViewModel

	private func setupTableView() {
		tableView.estimatedRowHeight = 45.0
		tableView.rowHeight = UITableView.automaticDimension

		tableView.register(UINib(nibName: "DMSwitchTableViewCell", bundle: nil), forCellReuseIdentifier: "DMSwitchTableViewCell")
		tableView.register(DMKeyValueTableViewCell.self, forCellReuseIdentifier: DMKeyValueTableViewCell.reuseIdentifier)
	}
}

#endif
