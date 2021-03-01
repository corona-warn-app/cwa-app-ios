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
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		let nibName = String(describing: ErrorReportFooterView.self)
		let nib = UINib(nibName: nibName, bundle: .main)
		if let logStatusView = nib.instantiate(withOwner: self, options: nil).first as? ErrorReportFooterView {
			logStatusView.configure(status: .active)
			logStatusView.bounds = CGRect(origin: .zero, size: CGSize(width: logStatusView.bounds.width, height: 318))
			self.logStatusView = logStatusView
			tableView.tableFooterView = logStatusView
		}
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

	private var logStatusView: ErrorReportFooterView?
}
