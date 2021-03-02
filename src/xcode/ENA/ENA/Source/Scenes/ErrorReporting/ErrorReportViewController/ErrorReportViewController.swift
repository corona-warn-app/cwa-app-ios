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
	
	// MARK: - Private
	
	private func setupTableView() {
		tableView.separatorStyle = .none
		
		tableView.register(
			UINib(nibName: "ExposureDetectionLinkCell", bundle: nil),
			forCellReuseIdentifier: ExposureDetectionViewController.ReusableCellIdentifier.link.rawValue
		)
	}
}
