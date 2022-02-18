//
// 🦠 Corona-Warn-App
//

import UIKit

class HealthCertifiedPersonUpdateSucceededViewController: UIViewController, DismissHandling {

	// MARK: - Init

	init(
		didTapEnd: @escaping () -> Void
	) {
		self.didTapEnd = didTapEnd
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()
		// setup navigation bar
		title = AppStrings.HealthCertificate.Person.UpdateSucceeded.title
		navigationItem.hidesBackButton = true
		navigationItem.rightBarButtonItem = dismissHandlingCloseBarButton
	}

	// MARK: - Protocol DismissHandling

	func wasAttemptedToBeDismissed() {
		didTapEnd()
	}

	// MARK: - Public

	// MARK: - Internal

	// MARK: - Private

	private let didTapEnd: () -> Void

}
