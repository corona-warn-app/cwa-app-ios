////
// 🦠 Corona-Warn-App
//

#if !RELEASE

import UIKit

class DMBoosterRulesViewController: UITableViewController {

	// MARK: - Init

	init(
		store: Store,
		healthCertificateService: HealthCertificateService,
		healthCertifiedPerson: HealthCertifiedPerson
	) {
		self.viewModel = DMBoosterRulesViewModel(
			store: store,
			service: healthCertificateService,
			healthCertifiedPerson: healthCertifiedPerson
		)

		if #available(iOS 13.0, *) {
			super.init(style: .insetGrouped)
		} else {
			super.init(style: .grouped)
		}
		
		self.viewModel.showAlert = { alert in
			DispatchQueue.main.async { [weak self] in
				self?.present(alert, animated: true)
			}
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
		guard let section = DMBoosterRulesViewModel.TableViewSections(rawValue: indexPath.section) else {
			fatalError("unknown tableview section")
		}
		let cellViewModel = viewModel.cellViewModel(by: indexPath)
		switch section {
		case .lastDownloadDate:
			let cell = tableView.dequeueReusableCell(cellType: DMKeyValueTableViewCell.self, for: indexPath)
			cell.configure(cellViewModel: cellViewModel)
			return cell
			
		case .clearLastDownloadDate:
			let cell = tableView.dequeueReusableCell(cellType: DMButtonTableViewCell.self, for: indexPath)
			cell.configure(cellViewModel: cellViewModel)
			return cell

		case .cachedPassedBoosterRule:
			let cell = tableView.dequeueReusableCell(cellType: DMKeyValueTableViewCell.self, for: indexPath)
			cell.configure(cellViewModel: cellViewModel)
			return cell
			
		case .clearCurrentPersonBoosterRule:
			let cell = tableView.dequeueReusableCell(cellType: DMButtonTableViewCell.self, for: indexPath)
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

	private let viewModel: DMBoosterRulesViewModel

	private func setupTableView() {
		tableView.estimatedRowHeight = 45.0
		tableView.rowHeight = UITableView.automaticDimension

		tableView.register(DMKeyValueTableViewCell.self, forCellReuseIdentifier: DMKeyValueTableViewCell.reuseIdentifier)
		tableView.register(DMButtonTableViewCell.self, forCellReuseIdentifier: DMButtonTableViewCell.reuseIdentifier)

		// wire up tableview with the viewModel
		viewModel.refreshTableView = { indexSet in
			DispatchQueue.main.async { [weak self] in
				self?.tableView.reloadSections(indexSet, with: .fade)
			}
		}
	}

	private func setupNavigationBar() {
		title = "Booster rules actions 🎩"
	}
}
#endif
