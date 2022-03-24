//
// 🦠 Corona-Warn-App
//

import UIKit

class ExposureSubmissionTestOwnerSelectionViewController: DynamicTableViewController, DismissHandling {

	// MARK: - Init

	init(
		viewModel: ExposureSubmissionTestOwnerSelectionViewModel,
		onDismiss: @escaping () -> Void
	) {
		self.onDismiss = onDismiss
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
				
		setupView()
	}
	
	// MARK: - DismissHandling

	func wasAttemptedToBeDismissed() {
		onDismiss()
	}

	// MARK: - Private

	private let onDismiss: () -> Void
	private let viewModel: ExposureSubmissionTestOwnerSelectionViewModel

	private func setupView() {
		navigationItem.title = AppStrings.ExposureSubmission.TestOwnerSelection.title
		navigationItem.rightBarButtonItem = dismissHandlingCloseBarButton
		navigationItem.hidesBackButton = true
		
		view.backgroundColor = .enaColor(for: .background)
		
		tableView.register(
			UINib(nibName: String(describing: ExposureSubmissionTestOwnerCell.self), bundle: nil),
			forCellReuseIdentifier: String(describing: ExposureSubmissionTestOwnerCell.self)
		)

		dynamicTableViewModel = viewModel.dynamicTableViewModel
		tableView.separatorStyle = .none
	}
}

