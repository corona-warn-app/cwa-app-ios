//
// 🦠 Corona-Warn-App
//

#if !RELEASE

import UIKit

final class DMLocalNotificationsViewController: UITableViewController {

	// MARK: - Init

	init() {
		self.viewModel = DMLocalNotificationsViewModel()
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
		title = "Notifications 🪄"
	}

	// MARK: - Protocol UITableViewDataSource

	override func numberOfSections(in tableView: UITableView) -> Int {
		return viewModel.numberOfSections
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		viewModel.itemsCount
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let section = DMLocalNotificationsViewModel.Sections(rawValue: indexPath.section) else {
			fatalError("unknown tableview section")
		}

		let cellViewModel = viewModel.cellViewModel(for: indexPath)
		switch section {

		case .expired:
			let cell = tableView.dequeueReusableCell(cellType: DMButtonTableViewCell.self, for: indexPath)
			cell.configure(cellViewModel: cellViewModel)
			return cell
		}

	}

	// MARK: - Private

	private let viewModel: DMLocalNotificationsViewModel

	private func setupTableView() {
		tableView.estimatedRowHeight = 45.0
		tableView.rowHeight = UITableView.automaticDimension

		tableView.register(DMButtonTableViewCell.self, forCellReuseIdentifier: DMButtonTableViewCell.reuseIdentifier)
		tableView.register(DMStaticTextTableViewCell.self, forCellReuseIdentifier: DMStaticTextTableViewCell.reuseIdentifier)
	}

}

#endif
