//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

class SecondTicketValidationConsentViewController: DynamicTableViewController, DismissHandling, FooterViewHandling {
	
	// MARK: - Init
	
	init(
		viewModel: SecondTicketValidationConsentViewModel,
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

	override func viewDidLoad() {
		super.viewDidLoad()
		setupView()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		navigationController?.navigationBar.prefersLargeTitles = true
	}
	
	// MARK: - Cell reuse identifiers.

	enum CustomCellReuseIdentifiers: String, TableViewCellReuseIdentifiers {
		case healthCertificateCell = "HealthCertificateCell"
		case legalExtended = "DynamicLegalExtendedCell"
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
			}
		case .secondary:
			onDismiss()
		}
	}
	
	// MARK: - Private

	private let viewModel: SecondTicketValidationConsentViewModel
	private let onPrimaryButtonTap: (@escaping (Bool) -> Void) -> Void
	private let onDismiss: () -> Void

	private func setupView() {
		title = AppStrings.TicketValidation.SecondConsent.title
		
		navigationItem.rightBarButtonItem = dismissHandlingCloseBarButton
		navigationItem.largeTitleDisplayMode = .always

		view.backgroundColor = .enaColor(for: .background)
		
		tableView.register(
			HealthCertificateCell.self,
			forCellReuseIdentifier: CustomCellReuseIdentifiers.healthCertificateCell.rawValue
		)
		tableView.register(
			UINib(nibName: String(describing: DynamicLegalExtendedCell.self), bundle: nil),
			forCellReuseIdentifier: CustomCellReuseIdentifiers.legalExtended.rawValue
		)

		dynamicTableViewModel = viewModel.dynamicTableViewModel
		tableView.separatorStyle = .none
		
		viewModel.fetchAllowListServiceProvider { [weak self] in
			guard let self = self else { return }
			self.dynamicTableViewModel = self.viewModel.dynamicTableViewModel
			DispatchQueue.main.async(execute: { [weak self] in
				self?.tableView.reloadData()
			})
		}
	}

}
