//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

class BoosterDetailsViewController: DynamicTableViewController {

	// MARK: - Init

	init(
		viewModel: BoosterDetailsViewModel
	) {
		self.viewModel = viewModel
		
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
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		navigationController?.navigationBar.tintColor = .white
	}
	
	// MARK: - Overrides

	private let viewModel: BoosterDetailsViewModel

	private func setupTableView() {
		view.backgroundColor = .enaColor(for: .background)
		tableView.separatorStyle = .none

		if traitCollection.userInterfaceStyle == .dark {
			navigationController?.navigationBar.tintColor = .enaColor(for: .textContrast)
		} else {
			navigationController?.navigationBar.tintColor = .enaColor(for: .tint)
		}
		
		dynamicTableViewModel = viewModel.dynamicTableViewModel
	}
}
