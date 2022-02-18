//
// 🦠 Corona-Warn-App
//

import UIKit

class HealthCertifiedPersonUpdateSucceededViewController: UIViewController, DismissHandling {

	// MARK: - Init

	init(
		dismiss: @escaping () -> Void
	) {
		self.dismiss = dismiss
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
		navigationItem.rightBarButtonItem = dismissHandlingCloseBarButton
	}

	// MARK: - Protocol DismissHandling

	func wasAttemptedToBeDismissed() {
		dismiss()
	}

	// MARK: - Public

	// MARK: - Internal

	// MARK: - Private

	private let dismiss: () -> Void


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
