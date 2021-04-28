////
// 🦠 Corona-Warn-App
//

import UIKit

class AntigenTestProfileInformationViewController: DynamicTableViewController, FooterViewHandling, DismissHandling {

	// MARK: - Init

	init(
		store: AntigenTestProfileStoring,
		didTapDataPrivacy: @escaping () -> Void,
		didTapContinue: @escaping () -> Void,
		dismiss: @escaping () -> Void
	) {
		self.viewModel = AntigenTestProfileInformationViewModel(store: store, showDisclaimer: didTapDataPrivacy)
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

		parent?.navigationItem.title = viewModel.title
		parent?.navigationItem.rightBarButtonItem = dismissHandlingCloseBarButton
		setupView()
		viewModel.markScreenSeen()
	}

	// MARK: - Protocol FooterViewHandling

	func didTapFooterViewButton(_ type: FooterViewModel.ButtonType) {

		// this one can get used if data privacy will be removed from footer's secondary button
		guard case .primary = type else {
			return
		}
		didTapContinue()
	}

	// MARK: - Protocol DismissHandling

	func wasAttemptedToBeDismissed() {
		dismiss()
	}

	// MARK: - Public

	// MARK: - Internal

	private enum ReuseIdentifiers: String, TableViewCellReuseIdentifiers {
		case legalExtended = "DynamicLegalExtendedCell"
	}

	// MARK: - Private

	private let viewModel: AntigenTestProfileInformationViewModel
	private let didTapContinue: () -> Void
	private let dismiss: () -> Void

	private func setupView() {
		view.backgroundColor = .enaColor(for: .background)

		tableView.register(
			UINib(nibName: String(describing: DynamicLegalExtendedCell.self), bundle: nil),
			forCellReuseIdentifier: ReuseIdentifiers.legalExtended.rawValue
		)

		dynamicTableViewModel = viewModel.dynamicTableViewModel
		tableView.separatorStyle = .none
	}


}
