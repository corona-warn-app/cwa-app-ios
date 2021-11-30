//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

class FirstTicketValidationConsentViewController: DynamicTableViewController, DismissHandling, FooterViewHandling {
	
	// MARK: - Init
	
	init(
		viewModel: FirstTicketValidationConsentViewModel,
		onPrimaryButtonTap: @escaping (@escaping (Bool) -> Void) -> Void,
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

		setupView()
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
		switch type {
		case .primary:
			onPrimaryButtonTap { [weak self] isLoading in
				guard let self = self else { return }

				self.footerView?.setLoadingIndicator(isLoading, disable: isLoading, button: .primary)
				self.footerView?.setLoadingIndicator(false, disable: isLoading, button: .secondary)
			}
		case .secondary:
			onDismiss()
		}
	}
	
	// MARK: - Internal
	
	enum ReuseIdentifiers: String, TableViewCellReuseIdentifiers {
		case legal = "DynamicLegalCell"
	}
	
	// MARK: - Private

	private let viewModel: FirstTicketValidationConsentViewModel
	private let onPrimaryButtonTap: (@escaping (Bool) -> Void) -> Void
	private let onDismiss: () -> Void

	private func setupView() {
		tableView.backgroundColor = .enaColor(for: .background)
		tableView.separatorStyle = .none
		tableView.contentInsetAdjustmentBehavior = .never
		
		tableView.register(
			UINib(nibName: String(describing: DynamicLegalCell.self), bundle: nil),
			forCellReuseIdentifier: ReuseIdentifiers.legal.rawValue
		)

		dynamicTableViewModel = viewModel.dynamicTableViewModel
	}

}
