//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

class ExposureSubmissionThankYouViewController: DynamicTableViewController, FooterViewHandling, DismissHandling {

	// MARK: - Init
	
	init(
		onPrimaryButtonTap: (@escaping() -> Void),
		onDismiss: (@escaping(@escaping (Bool) -> Void) -> Void)
	) {
		self.viewModel = ExposureSubmissionThankYouViewModel()
		self.onPrimaryButtonTap = onPrimaryButtonTap
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
	}
	
	// MARK: - Protocol FooterViewHandling
	
	func didTapFooterViewButton(_ type: FooterViewModel.ButtonType) {
		switch type {
		case .primary:
			onPrimaryButtonTap()
		case .secondary:
			wasAttemptedToBeDismissed()
		}
	}
	
	// MARK: - Protocol DismissHandling
	
	func wasAttemptedToBeDismissed() {
		onDismiss { [weak self] isLoading in
			DispatchQueue.main.async {
				self?.footerView?.setLoadingIndicator(false, disable: isLoading, button: .primary)
				self?.footerView?.setLoadingIndicator(isLoading, disable: isLoading, button: .secondary)
			}
		}
	}
	
	// MARK: - Private
	
	private let viewModel: ExposureSubmissionThankYouViewModel
	private let onPrimaryButtonTap: (() -> Void)
	private let onDismiss: ((@escaping (Bool) -> Void) -> Void)
	
	private func setupView() {
		
		parent?.navigationItem.title = AppStrings.ThankYouScreen.title
		parent?.navigationItem.rightBarButtonItem = dismissHandlingCloseBarButton
		parent?.navigationItem.hidesBackButton = true
		
		view.backgroundColor = .enaColor(for: .background)
		
		dynamicTableViewModel = viewModel.dynamicTableViewModel
		tableView.separatorStyle = .none
	}
	
}
