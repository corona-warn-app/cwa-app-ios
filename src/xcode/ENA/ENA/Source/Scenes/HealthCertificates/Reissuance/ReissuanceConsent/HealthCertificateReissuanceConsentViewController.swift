//
// 🦠 Corona-Warn-App
//

import UIKit

class HealthCertificateReissuanceConsentViewController: DynamicTableViewController, DismissHandling, FooterViewHandling {

	// MARK: - Init
	
	init(
		healthCertificateService: HealthCertificateService,
		restServiceProvider: RestServiceProviding,
		appConfigProvider: AppConfigurationProviding,
		cclService: CCLServable,
		certificate: HealthCertificate,
		healthCertifiedPerson: HealthCertifiedPerson,
		didTapDataPrivacy: @escaping () -> Void,
		onError: @escaping (HealthCertificateReissuanceError) -> Void,
		onReissuanceSuccess: @escaping () -> Void,
		dismiss: @escaping () -> Void
	) {

		self.viewModel = HealthCertificateReissuanceConsentViewModel(
			cclService: cclService,
			certificate: certificate,
			certifiedPerson: healthCertifiedPerson,
			appConfigProvider: appConfigProvider,
			restServiceProvider: restServiceProvider,
			healthCertificateService: healthCertificateService,
			onDisclaimerButtonTap: didTapDataPrivacy
		)

		self.onError = onError
		self.onReissuanceSuccess = onReissuanceSuccess
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

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		viewModel.markCertificateReissuanceAsSeen()
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
					self?.footerView?.setLoadingIndicator(false, disable: false, button: .primary)

					switch result {
					case .success:
						DispatchQueue.main.async {
							self?.onReissuanceSuccess()
						}
					case .failure(let error):
						DispatchQueue.main.async {
							self?.onError(error)
						}
					}
				}
			)
		case .secondary:
			dismiss()
		}
	}

	// MARK: - Private

	private let onError: (HealthCertificateReissuanceError) -> Void
	private let onReissuanceSuccess: () -> Void
	private let dismiss: () -> Void
	private let viewModel: HealthCertificateReissuanceConsentViewModel

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
