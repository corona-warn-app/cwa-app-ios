////
// 🦠 Corona-Warn-App
//

#if !RELEASE

import UIKit

class DMInstallationDateViewController: UITableViewController {

	// MARK: - Init

	init(store: Store) {
		self.viewModel = DMInstallationDateViewModel(store: store)
		self.store = store

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
		let cellViewModel = viewModel.cellViewModel(for: indexPath)

		if cellViewModel is DMDatePickerCellViewModel {
			let cell = tableView.dequeueReusableCell(cellType: DMDatePickerTableViewCell.self, for: indexPath)
			cell.configure(cellViewModel: cellViewModel)
			
			cell.didSelectDate = { [weak self] date in
				self?.store.appFirstStartDate = date
			}
			return cell
		} else {
			fatalError("unsopported cellViewModel - can't find a matching cell")
		}
	}

	override func numberOfSections(in tableView: UITableView) -> Int {
		viewModel.numberOfSections
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		viewModel.numberOfRows(in: section)
	}

	// MARK: - Internal

	// MARK: - Private

	private let store: Store
	private let viewModel: DMInstallationDateViewModel

	private func setupTableView() {
		tableView.estimatedRowHeight = 45.0
		tableView.rowHeight = UITableView.automaticDimension

		tableView.register(DMDatePickerTableViewCell.self, forCellReuseIdentifier: DMDatePickerTableViewCell.reuseIdentifier)
	}

	private func setupNavigationBar() {
		title = "Installation Date 💾"
	}

}
#endif
