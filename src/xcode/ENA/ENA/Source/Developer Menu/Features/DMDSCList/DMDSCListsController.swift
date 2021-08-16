//
// 🦠 Corona-Warn-App
//

#if !RELEASE

import UIKit

final class DMDSCListsController: UITableViewController {

	// MARK: - Init

	init(store: Store) {
		self.viewModel = DMAppFeaturesViewModel(store: store)
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
		title = "App Features 🪄⚙️"
	}

	// MARK: - Protocol UITableViewDataSource

	override func numberOfSections(in tableView: UITableView) -> Int {
		return viewModel.numberOfSections
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		viewModel.itemsCount
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let section = DMAppFeaturesViewModel.Sections(rawValue: indexPath.section) else {
			fatalError("unknown tableview section")
		}

		let cellViewModel = viewModel.cellViewModel(for: indexPath)
		switch section {

		case .notice:
			let cell = tableView.dequeueReusableCell(cellType: DMStaticTextTableViewCell.self, for: indexPath)
			cell.configure(cellViewModel: cellViewModel)
			return cell

		case .unencryptedEvents:
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

	private let viewModel: DMAppFeaturesViewModel

	private func setupTableView() {
		tableView.estimatedRowHeight = 45.0
		tableView.rowHeight = UITableView.automaticDimension

		tableView.register(UINib(nibName: "DMSwitchTableViewCell", bundle: nil), forCellReuseIdentifier: "DMSwitchTableViewCell")
		tableView.register(DMKeyValueTableViewCell.self, forCellReuseIdentifier: DMKeyValueTableViewCell.reuseIdentifier)
		tableView.register(DMStaticTextTableViewCell.self, forCellReuseIdentifier: DMStaticTextTableViewCell.reuseIdentifier)
	}
}

#endif
