////
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

class ErrorReportDetailInformationViewController: DynamicTableViewController, DismissHandling {

	// MARK: - Init

	init() {
		self.viewModel = ErrorReportDetailInformationViewModel()
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
	
	private let viewModel: ErrorReportDetailInformationViewModel
	
	private func setupTableView() {
		navigationItem.largeTitleDisplayMode = .never
		view.backgroundColor = .enaColor(for: .background)
		tableView.separatorStyle = .none
		
		tableView.register(
			DynamicTableViewRoundedCell.self,
			forCellReuseIdentifier: CustomCellReuseIdentifiers.roundedCell.rawValue
		)
		
		dynamicTableViewModel = viewModel.dynamicTableViewModel
	}
	
}

// MARK: - Cell reuse identifiers.

extension ErrorReportDetailInformationViewController {
	enum CustomCellReuseIdentifiers: String, TableViewCellReuseIdentifiers {
		case roundedCell
	}
}
