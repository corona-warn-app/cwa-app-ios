////
// 🦠 Corona-Warn-App
//

import UIKit

class CheckinsTableViewController: UITableViewController {

	// MARK: - Init

	init(
		showQRCodeScanner: @escaping () -> Void,
		showSettings: @escaping () -> Void
	) {
		self.showQRCodeScanner = showQRCodeScanner
		self.showSettings = showSettings
		self.viewModel = CheckinsViewModel()
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

	// MARK: - UITableViewDataSource

	override func numberOfSections(in tableView: UITableView) -> Int {
		viewModel.numberOfSections
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return viewModel.numberOfItem(in: section)
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch CheckinsViewModel.Sections(rawValue: indexPath.section) {
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

	// MARK: - UITableViewDelegate

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard let section = CheckinsViewModel.Sections(rawValue: indexPath.section) else {
			return
		}
		switch section {
		case .state:
			if viewModel.statusCellViewModel.authorizationStatus == .authorized {
				showQRCodeScanner()
			} else {
				showSettings()
			}
		case .checkIns:
			Log.debug("NYD")
		}
	}


	// MARK: - Private

	private let showQRCodeScanner: () -> Void
	private let showSettings: () -> Void

	private let viewModel: CheckinsViewModel

	private func setupTableView() {
		tableView.separatorStyle = .none
		tableView.backgroundColor = .enaColor(for: .background)

		tableView.register(CheckinTableViewCell.self, forCellReuseIdentifier: CheckinTableViewCell.reuseIdentifier)
		tableView.register(MissingRightsTableViewCell.self, forCellReuseIdentifier: MissingRightsTableViewCell.reuseIdentifier)
		tableView.register(ScanQRCodeTableViewCell.self, forCellReuseIdentifier: ScanQRCodeTableViewCell.reuseIdentifier)
	}

}
