//
// 🦠 Corona-Warn-App
//

#if !RELEASE

import UIKit

final class DMDSCListsController: UITableViewController {

	// MARK: - Init

	init(store: Store) {
		self.viewModel = DMDSCListsViewModel(store: store)
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
		setupAlert()
		title = "DSC List Magic 🪄"
	}

	// MARK: - Protocol UITableViewDataSource

	override func numberOfSections(in tableView: UITableView) -> Int {
		return viewModel.numberOfSections
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		viewModel.itemsCount
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let section = DMDSCListsViewModel.Sections(rawValue: indexPath.section) else {
			fatalError("unknown tableview section")
		}

		let cellViewModel = viewModel.cellViewModel(for: indexPath)
		switch section {

		case .notice:
			let cell = tableView.dequeueReusableCell(cellType: DMStaticTextTableViewCell.self, for: indexPath)
			cell.configure(cellViewModel: cellViewModel)
			return cell

		case .refresh:
			let cell = tableView.dequeueReusableCell(cellType: DMButtonTableViewCell.self, for: indexPath)
			cell.configure(cellViewModel: cellViewModel)
			return cell

		case .reset:
			let cell = tableView.dequeueReusableCell(cellType: DMButtonTableViewCell.self, for: indexPath)
			cell.configure(cellViewModel: cellViewModel)
			return cell
		}

	}

	// MARK: - Private

	private let viewModel: DMDSCListsViewModel

	private func setupTableView() {
		tableView.estimatedRowHeight = 45.0
		tableView.rowHeight = UITableView.automaticDimension

		tableView.register(DMButtonTableViewCell.self, forCellReuseIdentifier: DMButtonTableViewCell.reuseIdentifier)
		tableView.register(DMStaticTextTableViewCell.self, forCellReuseIdentifier: DMStaticTextTableViewCell.reuseIdentifier)
	}

	private func setupAlert() {
		viewModel.presentResetAlert = { [weak self] accept, decline in
			let alert = UIAlertController(title: "Reset DSC List?", message: "This will clean the whole list of DSCs.", preferredStyle: .alert)
			alert.addAction(accept)
			alert.addAction(decline)
			self?.present(alert, animated: true)
		}

		viewModel.presentRefreshAlert = { [weak self] accept, decline in
			let alert = UIAlertController(title: "Override refresh?", message: "This will override the timestamp of the last refresh. You may move the app to the background and foreground to trigger the next refresh.", preferredStyle: .alert)
			alert.addAction(accept)
			alert.addAction(decline)
			self?.present(alert, animated: true)
		}

	}

}

#endif
