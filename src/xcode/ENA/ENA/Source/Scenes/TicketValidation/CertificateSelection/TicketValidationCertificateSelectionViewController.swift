//
// 🦠 Corona-Warn-App
//

import UIKit

class TicketValidationCertificateSelectionViewController: DynamicTableViewController, DismissHandling {

	// MARK: - Init

	init(
		viewModel: TicketValidationCertificateSelectionViewModel,
		onDismiss: @escaping (_ isSupportedCertificatesEmpty: Bool) -> Void
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
		
		title = AppStrings.TicketValidation.CertificateSelection.title
		navigationItem.rightBarButtonItem = dismissHandlingCloseBarButton
		navigationItem.hidesBackButton = true
		navigationItem.largeTitleDisplayMode = .always
		
		setupView()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		navigationController?.navigationBar.prefersLargeTitles = true
	}
	
	// MARK: - DismissHandling

	func wasAttemptedToBeDismissed() {
		onDismiss(viewModel.isSupportedCertificatesEmpty)
	}

	// MARK: - Private

	private let onDismiss: (_ isSupportedCertificatesEmpty: Bool) -> Void
	private let viewModel: TicketValidationCertificateSelectionViewModel

	private func setupView() {
		view.backgroundColor = .enaColor(for: .background)

		tableView.register(
			HealthCertificateCell.self,
			forCellReuseIdentifier: HealthCertificateCell.reuseIdentifier
		)
		
		tableView.register(
			TicketValidationNoSupportedCertificateCell.self,
			forCellReuseIdentifier: TicketValidationNoSupportedCertificateCell.reuseIdentifier
		)
		
		dynamicTableViewModel = viewModel.dynamicTableViewModel
		tableView.separatorStyle = .none
	}
}
