////
// 🦠 Corona-Warn-App
//

import UIKit

class ErrorReportViewController: DynamicTableViewController {
	
	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupTableView()
		
		title = AppStrings.ErrorReport.title
		
		navigationController?.navigationBar.prefersLargeTitles = true
		
		view.backgroundColor = .enaColor(for: .background)
		
		dynamicTableViewModel = AppInformationModel.errorReportModel
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = super.tableView(tableView, cellForRowAt: indexPath)
		cell.backgroundColor = .clear
		return cell
	}
	
	// MARK: - Internal

	enum ReuseIdentifiers: String, TableViewCellReuseIdentifiers {
		case legal = "DynamicLegalCell"
		case link = "linkCell"
	}

	// MARK: - Private
	
	private func setupTableView() {
		tableView.separatorStyle = .none
		tableView.register(
			UINib(nibName: "ExposureDetectionLinkCell", bundle: nil),
			forCellReuseIdentifier: ReuseIdentifiers.link.rawValue
		)
		tableView.register(
			UINib(nibName: String(describing: DynamicLegalCell.self), bundle: nil),
			forCellReuseIdentifier: ReuseIdentifiers.legal.rawValue
		)
	}
}
