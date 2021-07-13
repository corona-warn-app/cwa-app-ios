//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class HealthCertificateValidationViewController: DynamicTableViewController, FooterViewHandling, DismissHandling {

	// MARK: - Init

	init(
		healthCertificate: HealthCertificate,
		countries: [Country],
		store: HealthCertificateStoring,
		onValidationButtonTap: @escaping (Country, Date) -> Void,
		onDisclaimerButtonTap: @escaping () -> Void,
		onInfoButtonTap: @escaping () -> Void,
		onDismiss: @escaping () -> Void
	) {
		self.onInfoButtonTap = onInfoButtonTap
		self.onDismiss = onDismiss

		self.viewModel = HealthCertificateValidationViewModel(
			healthCertificate: healthCertificate,
			countries: countries,
			store: store,
			onValidationButtonTap: onValidationButtonTap,
			onDisclaimerButtonTap: onDisclaimerButtonTap,
			onInfoButtonTap: onInfoButtonTap
		)

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

	// MARK: - Protocol FooterViewHandling

	func didTapFooterViewButton(_ type: FooterViewModel.ButtonType) {
		guard type == .primary else { return }

		viewModel.validate()
	}

	// MARK: - Protocol DismissHandling

	func wasAttemptedToBeDismissed() {
		onDismiss()
	}

	// MARK: - Private

	private let onInfoButtonTap: () -> Void
	private let onDismiss: () -> Void
	private let viewModel: HealthCertificateValidationViewModel

	@IBAction private func infoButtonTapped() {
		onInfoButtonTap()
	}

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
