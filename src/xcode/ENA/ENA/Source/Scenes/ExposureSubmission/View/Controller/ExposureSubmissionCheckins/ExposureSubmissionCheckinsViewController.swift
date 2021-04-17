////
// 🦠 Corona-Warn-App
//

import UIKit

class ExposureSubmissionCheckinsViewController: UITableViewController, ENANavigationControllerWithFooterChild {

	// MARK: - Init
	
	init(checkins: [Checkin], onCompletion: @escaping ([Checkin]) -> Void) {
		self.viewModel = ExposureSubmissionCheckinsViewModel(checkins: checkins)
		self.onCompletion = onCompletion
		
		super.init(style: .plain)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Overrides
	
	// MARK: - Protocol <#Name#>
	
	// MARK: - Public
	
	// MARK: - Internal
	
	// MARK: - Private
	
	private let viewModel: ExposureSubmissionCheckinsViewModel
	private let onCompletion: ([Checkin]) -> Void
	
}
