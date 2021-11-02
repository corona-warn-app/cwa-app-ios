//
// 🦠 Corona-Warn-App
//

import UIKit

final class DeltaOnboardingNotificationReworkViewController: DynamicTableViewController, DeltaOnboardingViewControllerProtocol, ENANavigationControllerWithFooterChild, UIAdaptivePresentationControllerDelegate, DismissHandling {

	// MARK: - Init
	
	init() {
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
		LinkHelper.open(urlString: UIApplication.openSettingsURLString)
	}
	
	func navigationController(_ navigationController: ENANavigationControllerWithFooter, didTapSecondaryButton button: UIButton) {
		finished?()
	}
	
	// MARK: - Protocol DeltaOnboardingViewControllerProtocol
	
	var finished: (() -> Void)?
		
	// MARK: - Private
	
	private enum CustomCellReuseIdentifiers: String, TableViewCellReuseIdentifiers {
		case roundedCell
	}
	
	private let viewModel: DeltaOnboardingNotificationReworkViewModel
	
	private lazy var navigationFooterItem: ENANavigationFooterItem = {
		let item = ENANavigationFooterItem()

		item.primaryButtonTitle = AppStrings.NotificationSettings.openSystemSettings
		item.isPrimaryButtonEnabled = true
		item.isPrimaryButtonHidden = false
		item.secondaryButtonTitle = AppStrings.NotificationSettings.DeltaOnboarding.primaryButtonTitle
		item.isSecondaryButtonEnabled = true
		item.isSecondaryButtonHidden = false
		item.secondaryButtonHasBackground = true
		
		item.title = AppStrings.NotificationSettings.DeltaOnboarding.title
		
		item.rightBarButtonItem = CloseBarButtonItem(
			onTap: { [weak self] in
				self?.finished?()
			}
		)

		return item
	}()
	
	private func setupView() {
		
		navigationFooterItem?.primaryButtonTitle = AppStrings.NotificationSettings.openSystemSettings
		footerView?.primaryButton?.accessibilityIdentifier = AccessibilityIdentifiers.NotificationSettings.openSystemSettings
		navigationFooterItem?.secondaryButtonTitle = AppStrings.NotificationSettings.DeltaOnboarding.primaryButtonTitle
		footerView?.secondaryButton?.accessibilityIdentifier = AccessibilityIdentifiers.NotificationSettings.close
		
		navigationItem.largeTitleDisplayMode = .always
		navigationController?.navigationBar.prefersLargeTitles = true
		
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
