//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

class ExposureSubmissionThankYouViewController: DynamicTableViewController, ENANavigationControllerWithFooterChild, DismissHandling, RequiresDismissConfirmation {

	// MARK: - Init
	
	init(
		onPrimaryButtonTap: (@escaping() -> Void),
		onSecondaryButtonTap: (@escaping() -> Void),
		presentCancelAlert: (@escaping() -> Void)
	) {
		self.viewModel = ExposureSubmissionThankYouViewModel()
		self.onPrimaryButtonTap = onPrimaryButtonTap
		self.onSecondaryButtonTap = onSecondaryButtonTap
		self.presentCancelAlert = presentCancelAlert
		
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
	
	// MARK: - Protocol ENANavigationControllerWithFooterChild
	
	func navigationController(_ navigationController: ENANavigationControllerWithFooter, didTapPrimaryButton button: UIButton) {
		onPrimaryButtonTap()
	}
	
	func navigationController(_ navigationController: ENANavigationControllerWithFooter, didTapSecondaryButton button: UIButton) {
		onSecondaryButtonTap()
	}
	
	// MARK: - Protocol DismissHandling
	
	func presentDismiss(dismiss: @escaping () -> Void) {
		presentCancelAlert()
	}
	
	// MARK: - Private
	
	private let viewModel: ExposureSubmissionThankYouViewModel
	private let onPrimaryButtonTap: (() -> Void)
	private let onSecondaryButtonTap: (() -> Void)
	private let presentCancelAlert: (() -> Void)
	
	private lazy var navigationFooterItem: ENANavigationFooterItem = {
		let item = ENANavigationFooterItem()
		
		item.primaryButtonTitle = AppStrings.ThankYouScreen.continueButton
		item.secondaryButtonTitle = AppStrings.ThankYouScreen.cancelButton
		item.isPrimaryButtonEnabled = true
		item.isSecondaryButtonEnabled = true
		item.secondaryButtonHasBackground = true
		
		item.title = AppStrings.ThankYouScreen.title
		
		return item
	}()
	
	private func setupView() {
		view.backgroundColor = .enaColor(for: .background)
		cellBackgroundColor = .clear
		
		dynamicTableViewModel = viewModel.dynamicTableViewModel
		tableView.separatorStyle = .none
	}
	
}
