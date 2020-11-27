//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

class ExposureSubmissionThankYouViewController: DynamicTableViewController, ENANavigationControllerWithFooterChild {
	
	// MARK: - Init
	
	init(
		onPrimaryButtonTap: (@escaping() -> Void),
		onSecondaryButtonTap: (@escaping() -> Void)
	) {
		self.viewModel = ExposureSubmissionThankYouViewModel()
		self.onPrimaryButtonTap = onPrimaryButtonTap
		self.onSecondaryButtonTap = onSecondaryButtonTap
		
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
	
	// MARK: - Private
	
	private let viewModel: ExposureSubmissionThankYouViewModel
	private let onPrimaryButtonTap: (() -> Void)
	private let onSecondaryButtonTap: (() -> Void)
	
	private lazy var navigationFooterItem: ENANavigationFooterItem = {
		let item = ENANavigationFooterItem()
		
		item.primaryButtonTitle = AppStrings.ExposureSubmissionQRInfo.primaryButtonTitle
		item.secondaryButtonTitle = "Beenden"
		item.isPrimaryButtonEnabled = true
		item.isSecondaryButtonEnabled = true
		item.secondaryButtonHasBackground = true
		
		item.title = "Vielen Dank!"
		
		return item
	}()
	
	private func setupView() {
		view.backgroundColor = .enaColor(for: .background)
		cellBackgroundColor = .clear
		
		dynamicTableViewModel = viewModel.dynamicTableViewModel
		tableView.separatorStyle = .none
	}
	
}
