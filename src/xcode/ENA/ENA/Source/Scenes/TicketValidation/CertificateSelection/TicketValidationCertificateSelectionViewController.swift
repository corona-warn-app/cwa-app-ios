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
		
		setupView()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		navigationController?.navigationBar.backgroundColor = .enaColor(for: .background)
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
			forCellReuseIdentifier: CustomCellReuseIdentifiers.healthCertificateCell.rawValue
		)
		
		tableView.register(
			TicketValidationNoSupportedCertificateCell.self,
			forCellReuseIdentifier: CustomCellReuseIdentifiers.noSupportedCertificateCell.rawValue
		)
		
		dynamicTableViewModel = viewModel.dynamicTableViewModel
		tableView.separatorStyle = .none
	}
}

// MARK: - Cell reuse identifiers.

extension TicketValidationCertificateSelectionViewController {
	enum CustomCellReuseIdentifiers: String, TableViewCellReuseIdentifiers {
		case healthCertificateCell
		case noSupportedCertificateCell
	}
}
