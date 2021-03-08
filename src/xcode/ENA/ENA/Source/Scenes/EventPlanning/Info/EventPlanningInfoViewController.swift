//
// 🦠 Corona-Warn-App
//

import UIKit

class EventPlanningInfoViewController: DynamicTableViewController, ENANavigationControllerWithFooterChild {
	
	// MARK: - Init
	
	init(
		viewModel: EventPlanningInfoViewModel,
		onDismiss: @escaping () -> Void
	) {
		self.viewModel = viewModel
		self.onDismiss = onDismiss

		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()

		setupView()

		if !viewModel.hidesCloseButton {
			navigationItem.rightBarButtonItem = CloseBarButtonItem(
				onTap: { [weak self] in
					self?.onDismiss()
				}
			)
		}

		navigationController?.navigationBar.prefersLargeTitles = true
		footerView?.primaryButton?.accessibilityIdentifier = AccessibilityIdentifiers.ExposureSubmission.primaryButton
	}

	override var navigationItem: UINavigationItem {
		navigationFooterItem
	}

	// MARK: - Protocol ENANavigationControllerWithFooterChild

	func navigationController(_ navigationController: ENANavigationControllerWithFooter, didTapPrimaryButton button: UIButton) {
		onDismiss()
	}

	// MARK: - Internal
	
	enum ReuseIdentifiers: String, TableViewCellReuseIdentifiers {
		case legalExtended = "DynamicLegalExtendedCell"
	}
	
	// MARK: - Private

	private let viewModel: EventPlanningInfoViewModel
	private let onDismiss: () -> Void

	private lazy var navigationFooterItem: ENANavigationFooterItem = {
		let item = ENANavigationFooterItem()

		item.primaryButtonTitle = AppStrings.EventPlanning.Information.primaryButtonTitle
		item.isPrimaryButtonEnabled = true
		item.isSecondaryButtonHidden = true

		item.title = AppStrings.EventPlanning.Information.title

		return item
	}()

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
