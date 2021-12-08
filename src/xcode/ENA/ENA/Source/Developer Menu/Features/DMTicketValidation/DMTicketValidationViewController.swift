//
// 🦠 Corona-Warn-App
//
#if !RELEASE

import UIKit

class DMTicketValidationViewController: UITableViewController {

	// MARK: - Init

	init(
		store: Store
	) {
		self.viewModel = DMTicketValidationViewModel(
			store: store
		)

		if #available(iOS 13.0, *) {
			super.init(style: .insetGrouped)
		} else {
			super.init(style: .grouped)
		}
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()

		setupNavigationBar()
		setupTableView()
	}

	// MARK: - Protocol UITableViewDataSource

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let section = DMTicketValidationViewModel.TableViewSections(rawValue: indexPath.section) else {
			fatalError("Unknown section")
		}

		switch section {
		case .toggleAllowList:
			guard let cellViewModel = viewModel.cellViewModel(by: indexPath) as? DMSwitchCellViewModel else {
				fatalError("failed to find matching cell view model")
			}
			let cell = tableView.dequeueReusableCell(cellType: DMSwitchTableViewCell.self, for: indexPath)
			cell.configure(cellViewModel: cellViewModel)
			return cell
		}
	}

	override func numberOfSections(in tableView: UITableView) -> Int {
		viewModel.numberOfSections
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		viewModel.numberOfRows(in: section)
	}

	// MARK: - Private

	private let viewModel: DMTicketValidationViewModel

	private func setupTableView() {
		tableView.rowHeight = UITableView.automaticDimension

		tableView.register(DMSwitchTableViewCell.self, forCellReuseIdentifier: DMSwitchTableViewCell.reuseIdentifier)
	}

	private func setupNavigationBar() {
		title = "Ticket validation settings"
	}
}

#endif
