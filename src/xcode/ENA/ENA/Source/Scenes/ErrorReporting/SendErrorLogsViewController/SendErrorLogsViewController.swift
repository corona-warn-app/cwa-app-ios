////
// 🦠 Corona-Warn-App
//

import UIKit

class SendErrorLogsViewController: DynamicTableViewController, ENANavigationControllerWithFooterChild {
	
	// MARK: - Init

	init(model: SendErrorLogsViewModel) {
		viewModel = model

		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupTableView()

		navigationController?.navigationBar.prefersLargeTitles = true
		title = AppStrings.ErrorReport.sendReportsTitle

		view.backgroundColor = .enaColor(for: .background)

		dynamicTableViewModel = viewModel.sendErrorLogsDynamicViewModel
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = super.tableView(tableView, cellForRowAt: indexPath)
		cell.backgroundColor = .clear
		return cell
	}

	// MARK: - Internal

	enum ReuseIdentifiers: String, TableViewCellReuseIdentifiers {
		case link = "linkCell"
		case legalExtended = "DynamicLegalExtendedCell"
		
	}

	// MARK: - Private
	
	private func setupTableView() {
		tableView.separatorStyle = .none
		tableView.register(
			UINib(nibName: "ExposureDetectionLinkCell", bundle: nil),
			forCellReuseIdentifier: ReuseIdentifiers.link.rawValue
		)
		tableView.register(
			UINib(nibName: String(describing: DynamicLegalExtendedCell.self), bundle: nil),
			forCellReuseIdentifier: ReuseIdentifiers.legalExtended.rawValue
		)
	}
	
	private let viewModel: SendErrorLogsViewModel
}
