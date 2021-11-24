//
// 🦠 Corona-Warn-App
//

import UIKit

class TicketValidationResultViewController: DynamicTableViewController, DismissHandling {

	// MARK: - Init

	init(
		viewModel: TicketValidationResultViewModel,
		onDismiss: @escaping () -> Void
	) {
		self.viewModel = viewModel
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

	// MARK: - DismissHandling

	func wasAttemptedToBeDismissed() {
		onDismiss()
	}

	// MARK: - Private

	private let viewModel: TicketValidationResultViewModel
	private let onDismiss: () -> Void

	private func setupTableView() {
		tableView.separatorStyle = .none
		tableView.allowsSelection = false
		tableView.backgroundColor = .enaColor(for: .background)
		tableView.contentInsetAdjustmentBehavior = .never

		tableView.register(
			TicketValidationResultTableViewCell.self,
			forCellReuseIdentifier: TicketValidationResultTableViewCell.reuseIdentifier
		)

		tableView.register(
			DynamicTableViewHtmlCell.self,
			forCellReuseIdentifier: AppInformationDetailViewController.CellReuseIdentifier.html.rawValue
		)

		dynamicTableViewModel = viewModel.dynamicTableViewModel
	}

}
