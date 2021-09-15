//
// 🦠 Corona-Warn-App
//

#if !RELEASE

import UIKit

final class DMBoosterChoosePersonViewController: UITableViewController {

	// MARK: - Init

	init(store: Store, healthCertificateService: HealthCertificateService) {
		self.viewModel = DMBoosterChoosePersonViewModel(healthCertificateService: healthCertificateService, store: store)
		if #available(iOS 13.0, *) {
			super.init(style: .insetGrouped)
		} else {
			super.init(style: .grouped)
		}
		self.viewModel.showViewController = { viewController in
			DispatchQueue.main.async { [weak self] in
				self?.present(viewController, animated: true)
			}
		}
	}

	required init?(coder: NSCoder) {
		fatalError("not supported")
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()
		setupTableView()
		title = "Choose certified Person 🧖🏻 "
	}

	// MARK: - Protocol UITableViewDataSource

	override func numberOfSections(in tableView: UITableView) -> Int {
		return viewModel.numberOfSections
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		viewModel.items(section: section)
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cellViewModel = viewModel.cellViewModel(for: indexPath)
		let cell = tableView.dequeueReusableCell(cellType: DMButtonTableViewCell.self, for: indexPath)
		cell.configure(cellViewModel: cellViewModel)
		return cell
	}

	// MARK: - Private

	private let viewModel: DMBoosterChoosePersonViewModel

	private func setupTableView() {
		tableView.estimatedRowHeight = 45.0
		tableView.rowHeight = UITableView.automaticDimension

		tableView.register(DMButtonTableViewCell.self, forCellReuseIdentifier: DMButtonTableViewCell.reuseIdentifier)
		tableView.register(DMStaticTextTableViewCell.self, forCellReuseIdentifier: DMStaticTextTableViewCell.reuseIdentifier)
	}

}

#endif
