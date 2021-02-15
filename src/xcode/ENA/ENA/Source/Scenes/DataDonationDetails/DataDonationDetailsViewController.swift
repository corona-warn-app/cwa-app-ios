////
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

class DataDonationDetailsViewController: DynamicTableViewController {
	
	// MARK: - Init
	init() {
		self.viewModel = DataDonationDetailsViewModel()
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
	
	private let viewModel: DataDonationDetailsViewModel
	
	private func setupTableView() {
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

extension DataDonationDetailsViewController {
	enum CustomCellReuseIdentifiers: String, TableViewCellReuseIdentifiers {
		case roundedCell
	}
}
