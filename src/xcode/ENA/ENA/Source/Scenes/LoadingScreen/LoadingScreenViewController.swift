//
// 🦠 Corona-Warn-App
//

import UIKit

class LoadingScreenViewController: UIViewController {

	// MARK: - Init

	init() {
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func viewDidAppear(_ animated: Bool) {
		Log.info("Loading screen did appear", log: .appLifecycle)
		// Don't show loading screen content on fast devices
		DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
			Log.info("Loading screen did show activity indicator", log: .appLifecycle)

			self.logoImageView.isHidden = false
			self.activityIndicator.isHidden = false
		}
	}

	// MARK: - Private

	@IBOutlet private weak var logoImageView: UIImageView!
	@IBOutlet private weak var activityIndicator: UIActivityIndicatorView!


}
