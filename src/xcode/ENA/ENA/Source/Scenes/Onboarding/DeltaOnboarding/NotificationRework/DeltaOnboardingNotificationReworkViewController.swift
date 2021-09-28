//
// 🦠 Corona-Warn-App
//

import UIKit

final class DeltaOnboardingNotificationReworkViewController: DynamicTableViewController, DeltaOnboardingViewControllerProtocol, ENANavigationControllerWithFooterChild, UIAdaptivePresentationControllerDelegate, DismissHandling {

	// MARK: - Init
	
	init(
	
	) {
		self.viewModel = DeltaOnboardingNotificationReworkViewModel()
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
	}

	override var navigationItem: UINavigationItem {
		navigationFooterItem
	}
	
	// MARK: - Protocol DismissHandling
	
	func wasAttemptedToBeDismissed() {
		finished?()
	}
	
	// MARK: - Protocol ENANavigationControllerWithFooterChild

	func navigationController(_ navigationController: ENANavigationControllerWithFooter, didTapPrimaryButton button: UIButton) {
		finished?()
	}
	
	// MARK: - Protocol DeltaOnboardingViewControllerProtocol
	
	var finished: (() -> Void)?
		
	// MARK: - Private
	
	private let viewModel: DeltaOnboardingNotificationReworkViewModel
	
	private lazy var navigationFooterItem: ENANavigationFooterItem = {
		let item = ENANavigationFooterItem()

		item.primaryButtonTitle = AppStrings.DeltaOnboarding.primaryButton
		item.isPrimaryButtonEnabled = true
		item.isSecondaryButtonHidden = true

		item.rightBarButtonItem = CloseBarButtonItem(
			onTap: { [weak self] in
				self?.finished?()
			}
		)

		return item
	}()
	
	private func setupView() {
		navigationFooterItem?.primaryButtonTitle = AppStrings.DeltaOnboarding.primaryButton
		footerView?.primaryButton?.accessibilityIdentifier = AccessibilityIdentifiers.DeltaOnboarding.primaryButton
		setupTableView()
	}

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

extension DeltaOnboardingNotificationReworkViewController {
	enum CustomCellReuseIdentifiers: String, TableViewCellReuseIdentifiers {
		case roundedCell
	}
}
