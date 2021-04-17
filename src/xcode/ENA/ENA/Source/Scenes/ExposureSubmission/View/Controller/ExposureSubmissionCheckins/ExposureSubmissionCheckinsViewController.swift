////
// 🦠 Corona-Warn-App
//

import UIKit

class ExposureSubmissionCheckinsViewController: UITableViewController, DismissHandling, FooterViewHandling {

	// MARK: - Init
	
	init(checkins: [Checkin], onCompletion: @escaping ([Checkin]) -> Void, onSkip: @escaping () -> Void, onDismiss: @escaping () -> Void) {
		self.viewModel = ExposureSubmissionCheckinsViewModel(checkins: checkins)
		self.onCompletion = onCompletion
		self.onSkip = onSkip
		self.onDismiss = onDismiss
		
		super.init(style: .plain)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Overrides
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.title = viewModel.title
		self.navigationItem.hidesBackButton = true
		self.navigationItem.rightBarButtonItem = dismissHandlingCloseBarButton
	}
	
	// MARK: - Protocol DismissHandling
	
	func wasAttemptedToBeDismissed() {
		onDismiss()
	}
	
	
	// MARK: - Protocol FooterViewHandling
	
	func didTapFooterViewButton(_ type: FooterViewModel.ButtonType) {
		switch type {
		case .primary:
			// Submit
			onCompletion([])
		case .secondary:
			// Skip
			onSkip()
		}
	}

	
	// MARK: - Public
	
	// MARK: - Internal
	
	// MARK: - Private
	
	private let viewModel: ExposureSubmissionCheckinsViewModel
	private let onCompletion: ([Checkin]) -> Void
	private let onSkip: () -> Void
	private let onDismiss: () -> Void
	
}
