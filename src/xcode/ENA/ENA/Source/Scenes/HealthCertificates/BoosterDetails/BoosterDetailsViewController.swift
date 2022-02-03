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
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		if let dismissHandlingNC = navigationController as? DismissHandlingNavigationController {
			dismissHandlingNC.restoreOriginalNavigationBar()
		}
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		viewModel.markBoosterRuleAsSeen()
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		if let dismissHandlingNC = navigationController as? DismissHandlingNavigationController {
			dismissHandlingNC.setupTransparentNavigationBar()
		}
		
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
		
		tableView.register(
			UINib(nibName: "ExposureDetectionLinkCell", bundle: nil),
			forCellReuseIdentifier: ExposureDetectionViewController.ReusableCellIdentifier.link.rawValue
		)
		
		dynamicTableViewModel = viewModel.dynamicTableViewModel
	}
}
