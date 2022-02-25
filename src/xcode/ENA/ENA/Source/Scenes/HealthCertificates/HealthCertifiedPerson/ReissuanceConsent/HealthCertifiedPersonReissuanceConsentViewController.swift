//
// 🦠 Corona-Warn-App
//

import UIKit

class HealthCertifiedPersonReissuanceConsentViewController: DynamicTableViewController, DismissHandling, FooterViewHandling {

	// MARK: - Init

	init(
		cclService: CCLServable,
		certificate: HealthCertificate,
		healthCertifiedPerson: HealthCertifiedPerson,
		didTapDataPrivacy: @escaping () -> Void,
		presentAlert: @escaping (_ ok: UIAlertAction, _ retry: UIAlertAction) -> Void,
		presentUpdateSuccess: @escaping () -> Void,
		didCancel: @escaping () -> Void,
		dismiss: @escaping () -> Void
	) {
		self.presentAlert = presentAlert
		self.viewModel = HealthCertifiedPersonReissuanceConsentViewModel(
			cclService: cclService,
			certificate: certificate,
			certifiedPerson: healthCertifiedPerson,
			onDisclaimerButtonTap: didTapDataPrivacy
		)

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

		navigationItem.hidesBackButton = true
		navigationItem.rightBarButtonItem = dismissHandlingCloseBarButton
		
		title = viewModel.title

		setupView()
	}

	// MARK: - Protocol DismissHandling

	func wasAttemptedToBeDismissed() {
		dismiss()
	}

	// MARK: - Protocol FooterViewHandling

	func didTapFooterViewButton(_ type: FooterViewModel.ButtonType) {
		switch type {
		case .primary:
			footerView?.setLoadingIndicator(true, disable: true, button: .primary)
			viewModel.submit(
				completion: { [weak self] result in
					switch result {
					case .success:
						DispatchQueue.main.async {
							self?.presentUpdateSuccess()
						}
					case .failure:
						DispatchQueue.main.async {
							self?.showAlert()
						}
					}
				}
			)
		case .secondary:
			dismiss()
		}
	}

	// MARK: - Private

	private let presentAlert: (_ ok: UIAlertAction, _ retry: UIAlertAction) -> Void
	private let presentUpdateSuccess: () -> Void
	private let didCancel: () -> Void
	private let dismiss: () -> Void
	private let viewModel: HealthCertifiedPersonReissuanceConsentViewModel

	private func showAlert() {
		footerView?.setLoadingIndicator(false, disable: false, button: .primary)
		
		let okAction = UIAlertAction(
			title: AppStrings.HealthCertificate.Reissuance.Consent.defaultAlertOKButton,
			style: .default, handler: { _ in
				Log.info("OK Alert action needed here")
			}
		)

		let retryAction = UIAlertAction(
			title: AppStrings.HealthCertificate.Reissuance.Consent.defaultAlertRetryButton,
			style: .default, handler: { _ in
				Log.info("Retry Alert action needed here")
			}
		)
		presentAlert(okAction, retryAction)
	}

	private func setupView() {
		view.backgroundColor = .enaColor(for: .background)

		tableView.register(
			UINib(nibName: String(describing: DynamicLegalExtendedCell.self), bundle: nil),
			forCellReuseIdentifier: DynamicLegalExtendedCell.reuseIdentifier
		)
		tableView.register(
			UINib(nibName: "ExposureDetectionLinkCell", bundle: nil),
			forCellReuseIdentifier: "linkCell"
		)
		tableView.register(
			HealthCertificateCell.self,
			forCellReuseIdentifier: HealthCertificateCell.reuseIdentifier
		)

		tableView.contentInsetAdjustmentBehavior = .automatic
		tableView.separatorStyle = .none
		dynamicTableViewModel = viewModel.dynamicTableViewModel
	}

}
