//
// 🦠 Corona-Warn-App
//

import UIKit

class HealthCertifiedPersonUpdateConsentViewController: UIViewController, DismissHandling, FooterViewHandling {

	// MARK: - Init

	init(
		presentAlert: @escaping (_ ok: UIAlertAction, _ retry: UIAlertAction) -> Void,
		presentUpdateSuccess: @escaping () -> Void,
		didCancel: @escaping () -> Void,
		dismiss: @escaping () -> Void
	) {
		self.presentAlert = presentAlert
		self.viewModel = HealthCertifiedPersonUpdateConsentViewModel()
		self.presentUpdateSuccess = presentUpdateSuccess
		self.didCancel = didCancel
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
		// Do any additional setup after loading the view.
		navigationItem.hidesBackButton = true
		navigationItem.rightBarButtonItem = dismissHandlingCloseBarButton
		title = AppStrings.HealthCertificate.Person.UpdateConsent.title
	}

	// MARK: - Protocol DismissHandling

	func wasAttemptedToBeDismissed() {
		dismiss()
	}

	// MARK: - Protocol FooterViewHandling

	func didTapFooterViewButton(_ type: FooterViewModel.ButtonType) {
		switch type {
		case .primary:
			presentUpdateSuccess()
		case .secondary:
			dismiss()
		}
	}

	// MARK: - Public

	// MARK: - Internal

	// MARK: - Private

	private let presentAlert: (_ ok: UIAlertAction, _ retry: UIAlertAction) -> Void
	private let presentUpdateSuccess: () -> Void
	private let didCancel: () -> Void
	private let dismiss: () -> Void
	private let viewModel: HealthCertifiedPersonUpdateConsentViewModel

	private func showAlert() {
		let okAction = UIAlertAction(
			title: AppStrings.HealthCertificate.Person.UpdateConsent.defaultAlertOKButton,
			style: .default, handler: { _ in
				Log.info("OK Alert action needed here")
			}
		)

		let retryAction = UIAlertAction(
			title: AppStrings.HealthCertificate.Person.UpdateConsent.defaultAlertRetryButton,
			style: .default, handler: { _ in
				Log.info("Retry Alert action needed here")
			}
		)
		presentAlert(okAction, retryAction)
	}

	private func setupStickyButtons() {
	}

}
