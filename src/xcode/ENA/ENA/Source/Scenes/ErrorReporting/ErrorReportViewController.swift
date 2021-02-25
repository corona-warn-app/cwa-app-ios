////
// 🦠 Corona-Warn-App
//

import UIKit

class ErrorReportViewController: DynamicTableViewController {

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()

		setupTableView()

		navigationController?.navigationBar.prefersLargeTitles = true
		navigationItem.title = AppStrings.ErrorReport.title

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
