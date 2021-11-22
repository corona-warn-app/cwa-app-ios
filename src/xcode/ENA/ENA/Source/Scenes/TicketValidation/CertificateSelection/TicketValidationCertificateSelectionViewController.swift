//
// 🦠 Corona-Warn-App
//

import UIKit

class TicketValidationCertificateSelectionViewController: DynamicTableViewController {

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

		setupView()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		navigationController?.navigationBar.backgroundColor = .enaColor(for: .background)
		navigationController?.navigationBar.prefersLargeTitles = false
	}

	// MARK: - Private

	private let onDismiss: () -> Void
	private let viewModel: TicketValidationCertificateSelectionViewModel

	private func setupView() {
		navigationItem.rightBarButtonItem = CloseBarButtonItem(
			onTap: { [weak self] in
				self?.onDismiss()
			}
		)

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
