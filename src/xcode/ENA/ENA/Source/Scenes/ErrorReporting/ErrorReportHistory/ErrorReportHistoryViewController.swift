////
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

class ErrorReportHistoryViewController: DynamicTableViewController, DismissHandling {
	
	// MARK: - Init

	init() {
		self.viewModel = ErrorReportHistoryViewModel()
		super.init(nibName: nil, bundle: nil)
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
	
	// MARK: - Private
	
	private let viewModel: ErrorReportHistoryViewModel

	private func setupTableView() {
		navigationItem.largeTitleDisplayMode = .never
		view.backgroundColor = .enaColor(for: .background)
		tableView.separatorStyle = .none
		
		tableView.register(
			UINib(nibName: String(describing: ErrorReportHistoryCell.self), bundle: nil),
			forCellReuseIdentifier: CustomCellReuseIdentifiers.historyCell.rawValue
		)

		dynamicTableViewModel = viewModel.dynamicTableViewModel
	}

}

// MARK: - Cell reuse identifiers.

 extension ErrorReportHistoryViewController {
	enum CustomCellReuseIdentifiers: String, TableViewCellReuseIdentifiers {
		case historyCell = "historyCell"
	}
 }
