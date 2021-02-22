//
// 🦠 Corona-Warn-App
//

import UIKit

class DiaryDayNotesInfoViewController: DynamicTableViewController, DismissHandling {

	// MARK: - Initializers
	
	init() {
		self.viewModel = DiaryDayNotesInfoViewModel()
		super.init(nibName: nil, bundle: nil)
		navigationItem.rightBarButtonItem = dismissHandlingCloseBarButton
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - View Lifecycle Methods

	override func viewDidLoad() {
		super.viewDidLoad()

		setupTableView()
	}

	// MARK: - Overrides

	override var navigationItem: UINavigationItem {
		navigationFooterItem
	}

	private lazy var navigationFooterItem: ENANavigationFooterItem = {
		let item = ENANavigationFooterItem()

		item.primaryButtonTitle = AppStrings.NewVersionFeatures.buttonContinue
		item.isPrimaryButtonEnabled = true
		item.isSecondaryButtonHidden = true

		return item
	}()
	
	// MARK: - Protocol DismissHandling
	
	func wasAttemptedToBeDismissed() {
		
	}
	
	// MARK: - Protocol ENANavigationControllerWithFooterChild

	func navigationController(_ navigationController: ENANavigationControllerWithFooter, didTapPrimaryButton button: UIButton) {
		wasAttemptedToBeDismissed()
	}

	// MARK: - Private API

	private let viewModel: DiaryDayNotesInfoViewModel

	private func setupTableView() {
		view.backgroundColor = .enaColor(for: .background)
		tableView.separatorStyle = .none

		tableView.register(
			DynamicTableViewRoundedCell.self,
			forCellReuseIdentifier: CustomCellReuseIdentifiers.roundedCell.rawValue
		)

		dynamicTableViewModel = viewModel.dynamicTableViewModel
	}
}

// MARK: - Cell reuse identifiers.

extension DiaryDayNotesInfoViewController {
	enum CustomCellReuseIdentifiers: String, TableViewCellReuseIdentifiers {
		case roundedCell
	}
}
