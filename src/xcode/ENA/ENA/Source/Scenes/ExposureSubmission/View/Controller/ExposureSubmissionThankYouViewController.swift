//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

class ExposureSubmissionThankYouViewController: DynamicTableViewController, ENANavigationControllerWithFooterChild, DismissHandling {

	// MARK: - Init
	
	init(
		onPrimaryButtonTap: (@escaping() -> Void),
		onDismiss: (@escaping(@escaping (Bool) -> Void) -> Void)
	) {
		self.viewModel = ExposureSubmissionThankYouViewModel()
		self.onPrimaryButtonTap = onPrimaryButtonTap
		self.onDismiss = onDismiss
		
		super.init(nibName: nil, bundle: nil)
		navigationItem.rightBarButtonItem = dismissHandlingCloseBarButton
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
		wasAttemptedToBeDismissed()
	}
	
	// MARK: - Protocol DismissHandling
	
	func wasAttemptedToBeDismissed() {
		onDismiss { [weak self] isLoading in
			DispatchQueue.main.async {
				self?.navigationFooterItem?.isPrimaryButtonEnabled = !isLoading
				self?.navigationFooterItem?.isSecondaryButtonEnabled = !isLoading
				self?.navigationFooterItem?.isSecondaryButtonLoading = isLoading
			}
		}
	}
	
	// MARK: - Private
	
	private let viewModel: ExposureSubmissionThankYouViewModel
	private let onPrimaryButtonTap: (() -> Void)
	private let onDismiss: ((@escaping (Bool) -> Void) -> Void)
	
	private lazy var navigationFooterItem: ENANavigationFooterItem = {
		let item = ENANavigationFooterItem()
		
		item.primaryButtonTitle = AppStrings.ThankYouScreen.continueButton
		item.secondaryButtonTitle = AppStrings.ThankYouScreen.cancelButton
		item.isPrimaryButtonEnabled = true
		item.isSecondaryButtonEnabled = true
		item.secondaryButtonHasBackground = true
		
		item.title = AppStrings.ThankYouScreen.title
		item.hidesBackButton = true
		
		return item
	}()
	
	private func setupView() {
		view.backgroundColor = .enaColor(for: .background)
		
		dynamicTableViewModel = viewModel.dynamicTableViewModel
		tableView.separatorStyle = .none
	}
	
}
