////
// 🦠 Corona-Warn-App
//

import UIKit

class ValidationInformationViewController: DynamicTableViewController, DismissHandling {

	// MARK: - Init

	init(
		dismiss: @escaping () -> Void
	) {
		self.dismiss = dismiss

		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()

		navigationItem.rightBarButtonItem = dismissHandlingCloseBarButton
		setupView()
	}

	// MARK: - Protocol DismissHandling

	func wasAttemptedToBeDismissed() {
		dismiss()
	}

	// MARK: - Private

	private let viewModel: ValidationInformationViewModel = ValidationInformationViewModel()
	private let dismiss: () -> Void
	
	private func setupView() {
		view.backgroundColor = .enaColor(for: .background)
		dynamicTableViewModel = viewModel.dynamicTableViewModel
		tableView.separatorStyle = .none
		tableView.contentInsetAdjustmentBehavior = .never
	}

}
