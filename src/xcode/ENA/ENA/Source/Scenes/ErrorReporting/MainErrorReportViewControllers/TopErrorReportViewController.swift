////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class TopErrorReportViewController: DynamicTableViewController {
	
	// MARK: - Init

	init(viewModel: TopErrorReportViewModel) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupUI()
		setupTableView()
		viewModel.$dynamicTableViewModel
			.sink { [weak self] dynamicTableViewModel in
				self?.dynamicTableViewModel = dynamicTableViewModel
				self?.tableView.reloadData()
			}
			.store(in: &subscriptions)
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = super.tableView(tableView, cellForRowAt: indexPath)
		cell.backgroundColor = .clear
		return cell
	}
	
	// MARK: - Internal

	enum ReuseIdentifiers: String, TableViewCellReuseIdentifiers {
		case historyCell = "historyCell"
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
		tableView.register(
			UINib(nibName: String(describing: ErrorReportHistoryCell.self), bundle: nil),
			forCellReuseIdentifier: ReuseIdentifiers.historyCell.rawValue
		)
	}
	
	private func setupUI() {
		title = AppStrings.ErrorReport.title
		navigationController?.navigationBar.prefersLargeTitles = true
		view.backgroundColor = .enaColor(for: .background)
	}
	
	private var viewModel: TopErrorReportViewModel
	private var subscriptions = Set<AnyCancellable>()
}
