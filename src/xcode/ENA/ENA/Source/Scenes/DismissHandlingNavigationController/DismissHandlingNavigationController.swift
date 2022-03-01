////
// 🦠 Corona-Warn-App
//

import UIKit

class DismissHandlingNavigationController: UINavigationController, UIAdaptivePresentationControllerDelegate {

	// MARK: - Init

	init(transparent: Bool = false) {
		super.init(nibName: nil, bundle: nil)
		setup()
		if transparent {
			setupTransparentNavigationBar()
		}
	}

	convenience init(rootViewController: UIViewController, transparent: Bool = false) {
		self.init(rootViewController: rootViewController)
		if transparent {
			setupTransparentNavigationBar()
		}
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		setup()
	}

	// MARK: - Overrides

	override private init(rootViewController: UIViewController) {
		if #available(iOS 13.0, *) {
			super.init(rootViewController: rootViewController)
		} else {
			super.init(nibName: nil, bundle: nil)
			self.viewControllers = [rootViewController]
		}
		setup()
	}

	// MARK: - Protocol UIAdaptivePresentationControllerDelegate

	func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
		guard let topViewController = viewControllers.last,
			  let dismissAbleViewController = topViewController as? DismissHandling  else {
			return
		}

		dismissAbleViewController.wasAttemptedToBeDismissed()
	}

	// MARK: - Internal
	
	func setupTransparentNavigationBar() {
		// save current state
		backgroundImage = navigationBar.backgroundImage(for: .default)
		shadowImage = navigationBar.shadowImage
		isTranslucent = navigationBar.isTranslucent
		backgroundColor = view.backgroundColor
		prefersLargeTitles = navigationBar.prefersLargeTitles

		let emptyImage = UIImage()
		navigationBar.setBackgroundImage(emptyImage, for: .default)
		navigationBar.shadowImage = emptyImage
		navigationBar.isTranslucent = true
		view.backgroundColor = .clear
		navigationBar.tintColor = .clear

		navigationBar.prefersLargeTitles = false
		navigationBar.sizeToFit()
	}

	func restoreOriginalNavigationBar() {
		navigationBar.setBackgroundImage(backgroundImage, for: .default)
		navigationBar.shadowImage = shadowImage
		navigationBar.isTranslucent = isTranslucent
		view.backgroundColor = backgroundColor
		navigationBar.tintColor = .enaColor(for: .tint)

		// reset to initial values
		backgroundImage = nil
		shadowImage = nil
		backgroundColor = nil

		navigationBar.prefersLargeTitles = prefersLargeTitles
		navigationBar.sizeToFit()
	}

	// MARK: - Private

	private var backgroundImage: UIImage?
	private var shadowImage: UIImage?
	private var isTranslucent: Bool = false
	private var backgroundColor: UIColor?
	private var prefersLargeTitles: Bool = false

	private func setup() {
		presentationController?.delegate = self
		if #available(iOS 13.0, *) {
			isModalInPresentation = true
		}
	}

}
