//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

class AppClosureNoticeDetailsViewController: DynamicTableViewController, DismissHandling {

	// MARK: - Init

	init(
		viewModel: AppClosureNoticeDetailsViewModel,
		dismiss: @escaping () -> Void
	) {
		self.viewModel = viewModel
		self.dismiss = dismiss

		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()
		
		navigationItem.rightBarButtonItem = dismissHandlingCloseBarButton

		setupTableView()
	}
	
	// MARK: - Protocol DismissHandling

	func wasAttemptedToBeDismissed() {
		dismiss()
	}
	
	// MARK: - Private

	private let dismiss: () -> Void
	private let viewModel: AppClosureNoticeDetailsViewModel

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
