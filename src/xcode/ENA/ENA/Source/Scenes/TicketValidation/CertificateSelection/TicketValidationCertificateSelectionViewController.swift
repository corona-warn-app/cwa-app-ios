//
// 🦠 Corona-Warn-App
//

import UIKit

class TicketValidationCertificateSelectionViewController: DynamicTableViewController, DismissHandling {

	// MARK: - Init

	init(
		viewModel: TicketValidationCertificateSelectionViewModel,
		onDismiss: @escaping () -> Void
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

		navigationItem.rightBarButtonItem = CloseBarButtonItem(
			onTap: { [weak self] in
				self?.onDismiss()
			}
		)
		navigationItem.title = AppStrings.TicketValidation.CertificateSelection.title

		setupTableView()

		view.backgroundColor = .enaColor(for: .background)
	}

	// MARK: - Private

	private let onDismiss: () -> Void
	private let viewModel: TicketValidationCertificateSelectionViewModel

	private func setupTableView() {
		tableView.separatorStyle = .none
		dynamicTableViewModel = viewModel.dynamicTableViewModel

		tableView.register(
			HealthCertificateCell.self,
			forCellReuseIdentifier: CustomCellReuseIdentifiers.healthCertificateCell.rawValue
		)
		
		tableView.register(
			TicketValidationNoSupportedCertificateCell.self,
			forCellReuseIdentifier: CustomCellReuseIdentifiers.noSupportedCertificateCell.rawValue
		)
	}

}

// MARK: - Cell reuse identifiers.

extension TicketValidationCertificateSelectionViewController {
	enum CustomCellReuseIdentifiers: String, TableViewCellReuseIdentifiers {
		case healthCertificateCell
		case noSupportedCertificateCell
	}
}

enum TicketValidationCertificateSelectionState: Equatable {
	case supportedHealthCertificates
	case noSupportedHealthCertificate
}
