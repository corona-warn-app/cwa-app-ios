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

	override func viewDidLoad() {
		super.viewDidLoad()

		if #available(iOS 13.0, *) {
			activityIndicator.style = .large
		} else {
			activityIndicator.style = .whiteLarge
			activityIndicator.color = .enaColor(for: .textPrimary2)
		}
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		Log.info("Loading screen did appear", log: .appLifecycle)
		// Don't show loading screen content on fast devices
		DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
			guard let self = self else {
				Log.info("Loading screen did not show activity indicator", log: .appLifecycle)
				return
			}

			Log.info("Loading screen did show activity indicator", log: .appLifecycle)

			self.logoImageView.isHidden = false
			self.activityIndicator.isHidden = false
		}
	}

	// MARK: - Private

	@IBOutlet private weak var logoImageView: UIImageView!
	@IBOutlet private weak var activityIndicator: UIActivityIndicatorView!

}
