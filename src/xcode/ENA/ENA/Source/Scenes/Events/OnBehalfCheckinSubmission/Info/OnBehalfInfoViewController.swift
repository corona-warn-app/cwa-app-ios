//
// 🦠 Corona-Warn-App
//

import UIKit

class OnBehalfInfoViewController: DynamicTableViewController, DismissHandling, FooterViewHandling {

	// MARK: - Init

	init(
		onPrimaryButtonTap: @escaping () -> Void,
		onDismiss: @escaping () -> Void
	) {
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

		navigationItem.rightBarButtonItem = dismissHandlingCloseBarButton
		navigationItem.hidesBackButton = true
		navigationItem.largeTitleDisplayMode = .never

		setupTableView()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		if let dismissHandlingNC = navigationController as? DismissHandlingNavigationController {
			dismissHandlingNC.setupTransparentNavigationBar()
		}
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		if let dismissHandlingNC = navigationController as? DismissHandlingNavigationController {
			dismissHandlingNC.restoreOriginalNavigationBar()
		}
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

	private let viewModel = OnBehalfInfoViewModel()

	private let onPrimaryButtonTap: () -> Void
	private let onDismiss: () -> Void

	private func setupTableView() {
		tableView.separatorStyle = .none
		tableView.allowsSelection = false
		tableView.backgroundColor = .enaColor(for: .background)
		tableView.contentInsetAdjustmentBehavior = .never

		dynamicTableViewModel = viewModel.dynamicTableViewModel
	}

}
