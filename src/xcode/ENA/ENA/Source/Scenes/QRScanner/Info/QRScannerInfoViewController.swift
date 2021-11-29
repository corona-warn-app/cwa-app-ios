//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

class QRScannerInfoViewController: DynamicTableViewController, DismissHandling {
	
	// MARK: - Init
	
	init(
		onDataPrivacyTap: @escaping () -> Void,
		onDismiss: @escaping () -> Void
	) {
		self.viewModel = QRScannerInfoViewModel(onDataPrivacyTap: onDataPrivacyTap)
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

		setupView()
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
	
	// MARK: - Private

	private let viewModel: QRScannerInfoViewModel
	private let onDismiss: () -> Void

	private func setupView() {
		tableView.backgroundColor = .enaColor(for: .background)
		tableView.separatorStyle = .none
		tableView.contentInsetAdjustmentBehavior = .never

		dynamicTableViewModel = viewModel.dynamicTableViewModel
	}

}
