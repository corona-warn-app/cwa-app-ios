////
// 🦠 Corona-Warn-App
//

import UIKit

class HealthCertificateInfoViewController: DynamicTableViewController, FooterViewHandling, DismissHandling {

	// MARK: - Init

	init(
		viewModel: HealthCertificateInfoViewModel,
		store: HealthCertificateStoring,
		onDemand: Bool,
		dismiss: @escaping (_ animated: Bool) -> Void
	) {
		self.dismiss = dismiss
		self.store = store
		self.onDemand = onDemand
		self.viewModel = viewModel

		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()

		if !viewModel.hidesCloseButton {
			navigationItem.rightBarButtonItem = dismissHandlingCloseBarButton
		}

		navigationItem.title = viewModel.title
		setupView()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		if store.healthCertificateInfoScreenShown && !onDemand {
			dismiss(false)
		}
	}

	// MARK: - Protocol DismissHandling

	func wasAttemptedToBeDismissed() {
		dismiss(true)
	}

	// MARK: - Protocol FooterViewHandling

	func didTapFooterViewButton(_ type: FooterViewModel.ButtonType) {
		guard type == .primary else {
			return
		}

		dismiss(true)
	}

	// MARK: - Private

	private let viewModel: HealthCertificateInfoViewModel
	private let store: HealthCertificateStoring
	private let onDemand: Bool
	private let dismiss: (_ animated: Bool) -> Void

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
