//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class HealthCertificateValidationViewController: UIViewController, FooterViewHandling, DismissHandling {

	// MARK: - Init

	init(
		healthCertificate: HealthCertificate,
		countries: [Country],
		store: HealthCertificateStoring,
		onValidationButtonTap: @escaping (Country, Date) -> Void,
		onInfoButtonTap: @escaping () -> Void,
		onDismiss: @escaping () -> Void
	) {
		self.onInfoButtonTap = onInfoButtonTap
		self.onDismiss = onDismiss

		self.viewModel = HealthCertificateValidationViewModel(
			healthCertificate: healthCertificate,
			countries: countries,
			store: store,
			onValidationButtonTap: onValidationButtonTap
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

		// Placeholder for info button in screen
		let infoButton = UIButton(type: .infoLight)
		infoButton.addTarget(self, action: #selector(infoButtonTapped), for: .touchUpInside)
		let infoBarButtonItem = UIBarButtonItem(customView: infoButton)

		parent?.navigationItem.rightBarButtonItems = [dismissHandlingCloseBarButton(.normal), infoBarButtonItem]
		parent?.navigationItem.title = "Gültigkeit des Zertifikats"
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

}
