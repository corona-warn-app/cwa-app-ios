////
// 🦠 Corona-Warn-App
//

#if !RELEASE

import UIKit

class DMHealthCertificateMigrationViewController: UITableViewController {

	// MARK: - Init

	init(
		store: Store
	) {
		self.viewModel = DMHealthCertificateMigrationViewModel(
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
		// by help of a protocol for cellViewModel we might simplyfiy this even more
		let cellViewModel = viewModel.cellViewModel(by: indexPath)
		if cellViewModel is DMStaticTextCellViewModel {
			let cell = tableView.dequeueReusableCell(cellType: DMStaticTextTableViewCell.self, for: indexPath)
			cell.configure(cellViewModel: cellViewModel)
			return cell
		} else if cellViewModel is DMTextFieldCellViewModel {
			guard let cell = tableView.dequeueReusableCell(withIdentifier: DMTextFieldTableViewCell.reuseIdentifier) as? DMTextFieldTableViewCell else {
				fatalError("unsupported cellViewModel - can't find a matching cell")
			}
			cell.configure(cellViewModel: cellViewModel)
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

	// MARK: - Private

	private let viewModel: DMHealthCertificateMigrationViewModel

	private func setupTableView() {
		tableView.estimatedRowHeight = 45.0
		tableView.rowHeight = UITableView.automaticDimension

		tableView.register(DMStaticTextTableViewCell.self, forCellReuseIdentifier: DMStaticTextTableViewCell.reuseIdentifier)
		tableView.register(DMTextFieldTableViewCell.self, forCellReuseIdentifier: DMTextFieldTableViewCell.reuseIdentifier)

		// wire up tableview with the viewModel
		viewModel.refreshTableView = { indexSet in
			DispatchQueue.main.async { [weak self] in
				self?.tableView.reloadSections(indexSet, with: .fade)
			}
		}
		viewModel.viewController = self
	}

	private func setupNavigationBar() {
		title = "HealthCertificate migration"
	}
}
#endif
