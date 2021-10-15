//
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

	override var navigationController: DismissHandlingNavigationController? {
		return super.navigationController as? DismissHandlingNavigationController
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		navigationItem.rightBarButtonItem = dismissHandlingCloseBarButton
		navigationItem.hidesBackButton = true
		navigationItem.largeTitleDisplayMode = .never

		setupTableView()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationController?.setupTransparentNavigationBar()
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		navigationController?.restoreOriginalNavigationBar()
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
			ValidationResultTableViewCell.self,
			forCellReuseIdentifier: ValidationResultTableViewCell.reuseIdentifier
		)

		tableView.register(
			TechnicalValidationFailedRulesTableViewCell.self,
			forCellReuseIdentifier: TechnicalValidationFailedRulesTableViewCell.reuseIdentifier
		)

		tableView.register(
			DynamicTableViewHtmlCell.self,
			forCellReuseIdentifier: AppInformationDetailViewController.CellReuseIdentifier.html.rawValue
		)

		dynamicTableViewModel = viewModel.dynamicTableViewModel
	}

}
