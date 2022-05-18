//
// 🦠 Corona-Warn-App
//

import UIKit

class AccompanyingCertificatesViewController: DynamicTableViewController, DismissHandling {

	// MARK: - Init
	
	init(
		certificates: [HealthCertificate],
		certifiedPerson: HealthCertifiedPerson,
		dismiss: @escaping () -> Void
	) {
		self.viewModel = AccompanyingCertificatesViewModel(
			certificates: certificates,
			certifiedPerson: certifiedPerson
		)
		self.dismiss = dismiss
		
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
		navigationItem.rightBarButtonItem?.accessibilityIdentifier = AccessibilityIdentifiers.HealthCertificate.Reissuance.accompanyingCertificatesCloseButton

		setupView()
	}

	// MARK: - Protocol DismissHandling

	func wasAttemptedToBeDismissed() {
		dismiss()
	}

	// MARK: - Private

	private let dismiss: () -> Void
	private let viewModel: AccompanyingCertificatesViewModel

	private func setupView() {
		view.backgroundColor = .enaColor(for: .background)

		tableView.register(
			HealthCertificateCell.self,
			forCellReuseIdentifier: HealthCertificateCell.reuseIdentifier
		)

		tableView.contentInsetAdjustmentBehavior = .automatic
		tableView.separatorStyle = .none
		dynamicTableViewModel = viewModel.dynamicTableViewModel
	}

}
