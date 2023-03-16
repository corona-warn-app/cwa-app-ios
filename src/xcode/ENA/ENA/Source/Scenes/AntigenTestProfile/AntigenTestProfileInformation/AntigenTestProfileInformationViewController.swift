////
// 🦠 Corona-Warn-App
//

import UIKit

class AntigenTestProfileInformationViewController: DynamicTableViewController, FooterViewHandling, DismissHandling {

	// MARK: - Init

	init(
		viewModel: AntigenTestProfileInformationViewModel,
		didTapContinue: @escaping () -> Void,
		dismiss: @escaping () -> Void
	) {
		self.viewModel = viewModel
		self.didTapContinue = didTapContinue
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

		navigationItem.title = viewModel.title
		navigationItem.rightBarButtonItem = dismissHandlingCloseBarButton
		navigationItem.largeTitleDisplayMode = .always

		navigationController?.navigationBar.tintColor = .enaColor(for: .tint)

		setupView()
	}

	// MARK: - Protocol FooterViewHandling

	func didTapFooterViewButton(_ type: FooterViewModel.ButtonType) {
		guard case .primary = type else {
			return
		}
		
		didTapContinue()
	}

	// MARK: - Protocol DismissHandling

	func wasAttemptedToBeDismissed() {
		dismiss()
	}

	// MARK: - Private

	private let viewModel: AntigenTestProfileInformationViewModel
	private let didTapContinue: () -> Void
	private let dismiss: () -> Void

	private func setupView() {
		view.backgroundColor = .enaColor(for: .background)

		tableView.register(
			UINib(nibName: String(describing: DynamicLegalExtendedCell.self), bundle: nil),
			forCellReuseIdentifier: DynamicLegalExtendedCell.reuseIdentifier
		)

		dynamicTableViewModel = viewModel.dynamicTableViewModel
		tableView.separatorStyle = .none
	}


}
