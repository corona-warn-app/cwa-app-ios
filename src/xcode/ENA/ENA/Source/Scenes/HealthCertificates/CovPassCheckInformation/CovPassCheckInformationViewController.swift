//
// 🦠 Corona-Warn-App
//

import UIKit

class CovPassCheckInformationViewController: DynamicTableViewController, DismissHandling {

	// MARK: - Init

	init(
		onDismiss: @escaping () -> Void
	) {
		self.onDismiss = onDismiss

		self.viewModel = CovPassCheckInformationViewModel()
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()

		parent?.navigationItem.rightBarButtonItems = [dismissHandlingCloseBarButton(.normal)]
		parent?.navigationItem.title = AppStrings.HealthCertificate.Validation.title

		setupTableView()

		view.backgroundColor = .enaColor(for: .background)
	}

	// MARK: - Protocol DismissHandling

	func wasAttemptedToBeDismissed() {
		onDismiss()
	}

	// MARK: - Public

	// MARK: - Internal

	// MARK: - Private

	private let onDismiss: () -> Void
	private let viewModel: CovPassCheckInformationViewModel

	private func setupTableView() {
		tableView.separatorStyle = .none
		dynamicTableViewModel = viewModel.dynamicTableViewModel

		tableView.register(
			CountrySelectionCell.self,
			forCellReuseIdentifier: HealthCertificateValidationViewModel.CellIdentifiers.countrySelectionCell.rawValue
		)

		tableView.register(
			ValidationDateSelectionCell.self,
			forCellReuseIdentifier: HealthCertificateValidationViewModel.CellIdentifiers.validationDateSelectionCell.rawValue
		)

		tableView.register(
			UINib(nibName: String(describing: DynamicLegalCell.self), bundle: nil),
			forCellReuseIdentifier: HealthCertificateValidationViewModel.CellIdentifiers.legalDetails.rawValue
		)
	}

}
