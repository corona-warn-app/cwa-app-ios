////
// 🦠 Corona-Warn-App
//

import UIKit

class HealthCertificateValidationResultViewController: DynamicTableViewController, DismissHandling, FooterViewHandling {

	// MARK: - Init

	init(
		viewModel: HealthCertificateValidationResultViewModel,
		onPrimaryButtonTap: @escaping () -> Void,
		onDismiss: @escaping () -> Void
	) {
		self.viewModel = viewModel
		self.onPrimaryButtonTap = onPrimaryButtonTap
		self.onDismiss = onDismiss

		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()

		if let parent = parent, !parent.isKind(of: UINavigationController.self) {
			parent.navigationItem.rightBarButtonItem = dismissHandlingCloseBarButton
			parent.navigationItem.hidesBackButton = true
		} else {
			navigationItem.rightBarButtonItem = dismissHandlingCloseBarButton
			navigationItem.hidesBackButton = true
		}

		setupTableView()
	}

	// MARK: - DismissHandling

	func wasAttemptedToBeDismissed() {
		onDismiss()
	}

	// MARK: - Protocol FooterViewHandling

	func didTapFooterViewButton(_ type: FooterViewModel.ButtonType) {
		guard type == .primary else {
			return
		}

		onPrimaryButtonTap()
	}

	// MARK: - Private

	private let viewModel: HealthCertificateValidationResultViewModel
	private let onPrimaryButtonTap: () -> Void
	private let onDismiss: () -> Void

	private func setupTableView() {
		tableView.separatorStyle = .none
		tableView.allowsSelection = false
		tableView.backgroundColor = .enaColor(for: .background)
		tableView.contentInsetAdjustmentBehavior = .never

		tableView.register(
			TechnicalValidationFailedRulesTableViewCell.self,
			forCellReuseIdentifier: TechnicalValidationFailedRulesTableViewCell.reuseIdentifier
		)

		dynamicTableViewModel = viewModel.dynamicTableViewModel
	}

}
