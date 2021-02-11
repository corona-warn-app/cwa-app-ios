//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

class AppNavigationController: ENANavigationControllerWithFooter {
	private var scrollViewObserver: NSKeyValueObservation?
	
	@available(iOS 13.0, *)
	private(set) lazy var defaultScrollEdgeAppearance: UINavigationBarAppearance? = nil

	override func viewDidLoad() {
		super.viewDidLoad()

		navigationBar.isTranslucent = true
		navigationBar.prefersLargeTitles = true

		if #available(iOS 13.0, *) {
			defaultScrollEdgeAppearance = navigationBar.scrollEdgeAppearance
		}

		view.backgroundColor = .enaColor(for: .separator)

		delegate = self
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		scrollViewObserver?.invalidate()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		if let topViewController = topViewController {
			// Since we invalidate the observer on `viewWillDisappear()`, we need to establish it again here.
			// Else the opacity is not set correctly upon returning to this screen.
			// Ex. this happens when the FAQ page is presented.
			observeScrollView(of: topViewController)
		}
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		if let opacityDelegate = topViewController as? NavigationBarOpacityDelegate {
			navigationBar.backgroundAlpha = opacityDelegate.backgroundAlpha
		}
	}
}

extension AppNavigationController: UINavigationControllerDelegate {
	func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
		let previousScrollViewObserver = scrollViewObserver

		var navigationBackgroundAlpha: CGFloat = 1.0
		var largeTitleBlurEffect: UIBlurEffect.Style?
		var largeTitleBackgroundColor: UIColor?

		if let opacityDelegate = viewController as? NavigationBarOpacityDelegate {
			navigationBackgroundAlpha = opacityDelegate.backgroundAlpha
			largeTitleBlurEffect = opacityDelegate.preferredLargeTitleBlurEffect
			largeTitleBackgroundColor = opacityDelegate.preferredLargeTitleBackgroundColor

			observeScrollView(of: viewController)
		}

		let previousNavigationBackgroundAlpha = navigationBar.backgroundAlpha
		if #available(iOS 13.0, *) {
			let previousScrollEdgeAppearance = navigationBar.scrollEdgeAppearance
			
			transitionCoordinator?.animate(alongsideTransition: { _ in
				self.navigationBar.backgroundAlpha = navigationBackgroundAlpha

				if let largeTitleBackgroundColor = largeTitleBackgroundColor {
					self.navigationBar.scrollEdgeAppearance = UINavigationBarAppearance()
					self.navigationBar.scrollEdgeAppearance?.backgroundColor = largeTitleBackgroundColor
				} else if let largeTitleBlurEffect = largeTitleBlurEffect {
					self.navigationBar.scrollEdgeAppearance = UINavigationBarAppearance()
					self.navigationBar.scrollEdgeAppearance?.backgroundEffect = UIBlurEffect(style: largeTitleBlurEffect)
				} else {
					self.navigationBar.scrollEdgeAppearance = self.defaultScrollEdgeAppearance
				}

			}, completion: { context in
				if context.isCancelled {
					self.navigationBar.backgroundAlpha = previousNavigationBackgroundAlpha
					self.navigationBar.scrollEdgeAppearance = previousScrollEdgeAppearance

					self.scrollViewObserver?.invalidate()
					self.scrollViewObserver = previousScrollViewObserver

				} else {
					previousScrollViewObserver?.invalidate()
				}
			})
		} else {
			transitionCoordinator?.animate(alongsideTransition: { _ in
				self.navigationBar.backgroundAlpha = navigationBackgroundAlpha

			}, completion: { context in
				if context.isCancelled {
					self.navigationBar.backgroundAlpha = previousNavigationBackgroundAlpha

					self.scrollViewObserver?.invalidate()
					self.scrollViewObserver = previousScrollViewObserver

				} else {
					previousScrollViewObserver?.invalidate()
				}
			})
		}

	}

	/// If the passed in `UIViewController` is a `NavigationBarOpacityDelegate` and contains a `UIScrollView`,
	/// register an observer for the `contentOffset` property so that the navigation bar's `backgroundAlpha` is set as the controller scrolls.
	///
	/// - parameter viewController: The controller to regsiter the observer for
	private func observeScrollView(of viewController: UIViewController) {
		guard
			let opacityDelegate = viewController as? NavigationBarOpacityDelegate,
			let scrollView = viewController.scrollView
		else {
			return
		}
		// We can overwrite the existing observer, since Swift 4 block based observers clean themselves up.
		scrollViewObserver = scrollView.observe(\.contentOffset) { [weak self] _, _ in
			guard let self = self else { return }
			guard viewController == self.topViewController else { return }
			self.navigationBar.backgroundAlpha = opacityDelegate.backgroundAlpha
		}
	}
}

extension UINavigationBar {
	var backgroundView: UIView? { subviews.first }
	var backgroundAlpha: CGFloat {
		get { backgroundView?.alpha ?? 0 }
		set { backgroundView?.alpha = newValue }
	}
}

private extension UIViewController {
	var scrollView: UIScrollView? {
		([view] + view.subviews).first(ofType: UIScrollView.self)
	}
}

private extension Array {
	func first<T>(ofType _: T.Type) -> T? {
		first(where: { $0 is T }) as? T
	}

	func last<T>(ofType _: T.Type) -> T? {
		last(where: { $0 is T }) as? T
	}
}

protocol NavigationBarOpacityDelegate: class {
	var preferredNavigationBarOpacity: CGFloat { get }
	var preferredLargeTitleBlurEffect: UIBlurEffect.Style? { get }
	var preferredLargeTitleBackgroundColor: UIColor? { get }
}

extension NavigationBarOpacityDelegate {
	var preferredNavigationBarOpacity: CGFloat { 1.0 }
	var preferredLargeTitleBlurEffect: UIBlurEffect.Style? { nil }
	var preferredLargeTitleBackgroundColor: UIColor? { nil }
	fileprivate var backgroundAlpha: CGFloat { max(0, min(preferredNavigationBarOpacity, 1)) }
}
