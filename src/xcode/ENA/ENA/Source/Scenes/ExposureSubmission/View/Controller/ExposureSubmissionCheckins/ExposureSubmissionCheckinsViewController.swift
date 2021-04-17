////
// 🦠 Corona-Warn-App
//

import UIKit

class ExposureSubmissionCheckinsViewController: UITableViewController, ENANavigationControllerWithFooterChild, DismissHandling {

	// MARK: - Init
	
	init(checkins: [Checkin], onCompletion: @escaping ([Checkin]) -> Void, onDismiss: @escaping () -> Void) {
		self.viewModel = ExposureSubmissionCheckinsViewModel(checkins: checkins)
		self.onCompletion = onCompletion
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
	
	
	// MARK: - Public
	
	// MARK: - Internal
	
	// MARK: - Private
	
	private let viewModel: ExposureSubmissionCheckinsViewModel
	private let onCompletion: ([Checkin]) -> Void
	private let onDismiss: () -> Void
	
}
