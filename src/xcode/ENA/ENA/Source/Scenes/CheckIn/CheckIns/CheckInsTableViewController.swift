////
// 🦠 Corona-Warn-App
//

import UIKit

class CheckInsTableViewController: UITableViewController {

	// MARK: - Init

	init() {
		viewModel = CheckInsViewModel()
		super.init(style: .grouped)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides
	override func viewDidLoad() {
		super.viewDidLoad()
		navigationController?.navigationBar.prefersLargeTitles = true
		navigationItem.title = "Meine Check-ins"
		setupTableView()
	}

	override func numberOfSections(in tableView: UITableView) -> Int {
		viewModel.numberOfSections
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return viewModel.numberOfItem(in: section)
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch CheckInsViewModel.Sections(rawValue: indexPath.section) {
		case .none:
			fatalError("Unknown section to dequeue cell - stop")
		case .some(let section):
			switch section {
			case .state:
				let cellViewModel = viewModel.statusCellViewModel
				let cell = tableView.dequeueReusableCell(cellType: cellViewModel.tableViewCell, for: indexPath)
				return cell
			case .checkIns:
				fatalError("NYD")
			}
		}

	}

	// MARK: - Private

	private let viewModel: CheckInsViewModel

	private func setupTableView() {
		tableView.separatorStyle = .none
		tableView.backgroundColor = .enaColor(for: .background)

		tableView.register(CheckInTableViewCell.self, forCellReuseIdentifier: CheckInTableViewCell.reuseIdentifier)
		tableView.register(MissingRightsTableViewCell.self, forCellReuseIdentifier: MissingRightsTableViewCell.reuseIdentifier)
		tableView.register(ScanQRCodeTableViewCell.self, forCellReuseIdentifier: ScanQRCodeTableViewCell.reuseIdentifier)
	}

}
