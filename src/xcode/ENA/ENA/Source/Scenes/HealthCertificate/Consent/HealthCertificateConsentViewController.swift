////
// 🦠 Corona-Warn-App
//

import UIKit

class HealthCertificateConsentViewController: DynamicTableViewController, FooterViewHandling, DismissHandling {

	// MARK: - Init

	init(
		didTapConsentButton: @escaping () -> Void,
		didTapDataPrivacy: @escaping () -> Void,
		dismiss: @escaping () -> Void
	) {
		self.didTapConsentButton = didTapConsentButton
		self.dismiss = dismiss
		self.viewModel = HealthCertificateConsentViewModel(
			didTapDataPrivacy: didTapDataPrivacy
		)
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()
		parent?.navigationItem.rightBarButtonItem = dismissHandlingCloseBarButton

		parent?.navigationItem.title = viewModel.title
		setupView()
	}

	// MARK: - Protocol DismissHandling

	func wasAttemptedToBeDismissed() {
		dismiss()
	}

	// MARK: - Protocol FooterViewHandling

	func didTapFooterViewButton(_ type: FooterViewModel.ButtonType) {
		guard type == .primary else {
			return
		}
		didTapConsentButton()
	}

	// MARK: - Private

	private let viewModel: HealthCertificateConsentViewModel
	private let didTapConsentButton: () -> Void
	private let dismiss: () -> Void

	private func setupView() {
		view.backgroundColor = .enaColor(for: .background)

		tableView.register(
			UINib(nibName: String(describing: DynamicLegalExtendedCell.self), bundle: nil),
			forCellReuseIdentifier: DynamicLegalExtendedCell.reuseIdentifier
		)

		tableView.register(
			HealthCertificateAttributedTextCell.self,
			forCellReuseIdentifier: HealthCertificateAttributedTextCell.reuseIdentifier
		)

		dynamicTableViewModel = viewModel.dynamicTableViewModel
		tableView.separatorStyle = .none
	}

}
