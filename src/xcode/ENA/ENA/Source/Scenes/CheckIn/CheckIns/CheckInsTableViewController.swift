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
		setupTableView()
	}

	override func numberOfSections(in tableView: UITableView) -> Int {
		viewModel.numberOfSections
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return viewModel.numerOfItem(in: section)
	}

	// MARK: - Private

	private let viewModel: CheckInsViewModel

	private func setupTableView() {
		tableView.register(CheckInTableViewCell.self, forCellReuseIdentifier: CheckInTableViewCell.reuseIdentifier)
		tableView.register(MissingRightsTableViewCell.self, forCellReuseIdentifier: MissingRightsTableViewCell.reuseIdentifier)
		tableView.register(ScanQRCodeTableViewCell.self, forCellReuseIdentifier: ScanQRCodeTableViewCell.reuseIdentifier)
	}

}
