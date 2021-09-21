//
// 🦠 Corona-Warn-App
//

import UIKit

class CovPassCheckInformationViewController: DynamicTableViewController, DismissHandling {

	// MARK: - Init

	init(
		onDismiss: @escaping () -> Void
	) {
		self.onDismiss = onDismiss

		self.viewModel = CovPassCheckInformationViewModel()
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()

		navigationItem.rightBarButtonItems = [dismissHandlingCloseBarButton(.normal)]

		setupTableView()

		view.backgroundColor = .enaColor(for: .background)
	}

	// MARK: - Protocol DismissHandling

	func wasAttemptedToBeDismissed() {
		onDismiss()
	}

	// MARK: - Public

	// MARK: - Internal

	// MARK: - Private

	private let onDismiss: () -> Void
	private let viewModel: CovPassCheckInformationViewModel

	private func setupTableView() {
		tableView.separatorStyle = .none
		tableView.allowsSelection = false
		tableView.backgroundColor = .enaColor(for: .background)
		tableView.contentInsetAdjustmentBehavior = .never

		tableView.register(
			UINib(nibName: "ExposureDetectionLinkCell", bundle: nil),
			forCellReuseIdentifier: ReuseIdentifiers.link.rawValue
		)

		dynamicTableViewModel = viewModel.dynamicTableViewModel
	}


	enum ReuseIdentifiers: String, TableViewCellReuseIdentifiers {
		case link = "linkCell"
	}

}
