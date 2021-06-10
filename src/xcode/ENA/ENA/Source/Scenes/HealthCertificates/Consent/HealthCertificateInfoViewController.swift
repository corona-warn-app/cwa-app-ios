////
// 🦠 Corona-Warn-App
//

import UIKit

class HealthCertificateInfoViewController: DynamicTableViewController, FooterViewHandling, DismissHandling {

	// MARK: - Init

	init(
		viewModel: HealthCertificateInfoViewModel,
		dismiss: @escaping () -> Void
	) {
		self.dismiss = dismiss
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
			parent?.navigationItem.rightBarButtonItem = dismissHandlingCloseBarButton
		}

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

		dismiss()
	}

	// MARK: - Private

	private let viewModel: HealthCertificateInfoViewModel
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
