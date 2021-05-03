////
// 🦠 Corona-Warn-App
//

import UIKit

class HealthCertificatePersonViewController: UITableViewController, DismissHandling, FooterViewHandling {

	// MARK: - Init

	init(
		// add real HealCertificatePerson
		healthCertificatePerson: String,
		dismiss: @escaping () -> Void,
		didTapHealtCertificate: @escaping () -> Void,
		didTapRegisterAnotherHealtCertificate: @escaping () -> Void
	) {
		self.dismiss = dismiss
		self.didTapHealtCertificate = didTapHealtCertificate
		self.didTapRegisterAnotherHealtCertificate = didTapRegisterAnotherHealtCertificate
		self.viewModel = HealthCertificatePersonViewModel()
		super.init(style: .plain)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	// MARK: - Protocol DismissHandling

	func wasAttemptedToBeDismissed() {
		dismiss()
	}

	// MARK: - Protocol FooterViewHandling

	func didTapFooterViewButton(_ type: FooterViewModel.ButtonType) {
		guard type == .primary else {
			return
		}
		didTapRegisterAnotherHealtCertificate()
	}

	// MARK: - Protocol UITableViewDateSource

	// MARK: - Protocol UITableViewDelegate

	// MARK: - Public

	// MARK: - Internal

	// MARK: - Private

	private let dismiss: () -> Void
	private let didTapHealtCertificate: () -> Void
	private let didTapRegisterAnotherHealtCertificate: () -> Void
	private let viewModel: HealthCertificatePersonViewModel

}
