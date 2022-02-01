////
// 🦠 Corona-Warn-App
//

#if !RELEASE

import UIKit

class DMCCLConfigurationViewController: UITableViewController {

	// MARK: - Init

	init(
		restServiceProvider: RestServiceProviding
	) {
		self.viewModel = DMCCLConfigurationViewModel()

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
		} else if cellViewModel is DMSwitchCellViewModel {
			guard let cell = tableView.dequeueReusableCell(withIdentifier: DMSwitchTableViewCell.reuseIdentifier) as? DMSwitchTableViewCell else {
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

	private let viewModel: DMCCLConfigurationViewModel

	private func setupTableView() {
		tableView.estimatedRowHeight = 45.0
		tableView.rowHeight = UITableView.automaticDimension

		tableView.register(DMStaticTextTableViewCell.self, forCellReuseIdentifier: DMStaticTextTableViewCell.reuseIdentifier)
		tableView.register(DMSwitchTableViewCell.self, forCellReuseIdentifier: DMSwitchTableViewCell.reuseIdentifier)
		
		// wire up tableview with the viewModel
		viewModel.refreshTableView = { indexSet in
			DispatchQueue.main.async { [weak self] in
				self?.tableView.reloadSections(indexSet, with: .fade)
			}
		}
		viewModel.viewController = self
	}

	private func setupNavigationBar() {
		title = "CLLConfiguration"
	}
}
#endif
