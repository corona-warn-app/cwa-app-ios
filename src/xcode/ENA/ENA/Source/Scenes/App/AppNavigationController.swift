//
// Corona-Warn-App
//
// SAP SE and all other contributors
// copyright owners license this file to you under the Apache
// License, Version 2.0 (the "License"); you may not use this
// file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.
//

import Foundation
import UIKit

class AppNavigationController: UINavigationController {
	private var scrollViewObserver: NSKeyValueObservation?
	private var defaultScrollEdgeAppearance: UINavigationBarAppearance?

	override func viewDidLoad() {
		super.viewDidLoad()

		navigationBar.isTranslucent = true
		navigationBar.prefersLargeTitles = true

		defaultScrollEdgeAppearance = navigationBar.scrollEdgeAppearance

		view.backgroundColor = .enaColor(for: .separator)
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		if let topViewController = topViewController {
			transition(to: topViewController, animated: animated)
		}
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		scrollViewObserver?.invalidate()
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		if let opacityDelegate = topViewController as? NavigationBarOpacityDelegate {
			navigationBar.backgroundAlpha = opacityDelegate.backgroundAlpha
		}
	}
}

extension AppNavigationController {
	override func pushViewController(_ viewController: UIViewController, animated: Bool) {
		super.pushViewController(viewController, animated: animated)
		transition(to: viewController, animated: animated)
	}

	override func popViewController(animated: Bool) -> UIViewController? {
		let viewController = super.popViewController(animated: animated)
		if let topViewController = topViewController {
			transition(to: topViewController, animated: animated)
		}
		return viewController
	}

	override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
		super.setViewControllers(viewControllers, animated: animated)
		if let topViewController = topViewController {
			transition(to: topViewController, animated: animated)
		}
	}
}

extension AppNavigationController {
	func transition(to viewController: UIViewController, animated: Bool) {
		if animated, let transitionCoordinator = transitionCoordinator {
			transitionCoordinator.animate(alongsideTransition: { context in
				self.transition(to: viewController, animated: false)
			}, completion: { context in
				if context.isCancelled {
					if let fromViewController = context.viewController(forKey: .from) {
						self.applyNavigationBarAppearance(for: fromViewController)
					}
				}
			})

		} else {
			applyNavigationBarAppearance(for: viewController)
			observeScrollView(of: viewController)
		}
	}

	private func applyNavigationBarAppearance(for viewController: UIViewController) {
		let state = NavigationBarState(for: viewController)

		navigationBar.backgroundAlpha = state.backgroundAlpha
		navigationBar.scrollEdgeAppearance = state.scrollEdgeAppearance ?? defaultScrollEdgeAppearance
	}

	private func observeScrollView(of viewController: UIViewController) {
		scrollViewObserver?.invalidate()
		guard let opacityDelegate = viewController as? NavigationBarOpacityDelegate  else { return }
		guard let scrollView = viewController.scrollView else { return }

		scrollViewObserver = scrollView.observe(\.contentOffset) { [weak self] _, _ in
			guard let self = self else { return }
			guard viewController == self.topViewController else { return }
			self.navigationBar.backgroundAlpha = opacityDelegate.backgroundAlpha
		}
	}
}

extension AppNavigationController {
	private struct NavigationBarState {
		weak var opacityDelegate: NavigationBarOpacityDelegate?
		let backgroundAlpha: CGFloat
		let largeTitleBlurEffect: UIBlurEffect.Style?
		let largeTitleBackgroundColor: UIColor?

		init(for viewController: UIViewController?) {
			opacityDelegate = viewController as? NavigationBarOpacityDelegate
			backgroundAlpha = opacityDelegate?.backgroundAlpha ?? 1.0
			largeTitleBlurEffect = opacityDelegate?.preferredLargeTitleBlurEffect
			largeTitleBackgroundColor = opacityDelegate?.preferredLargeTitleBackgroundColor
		}

		var scrollEdgeAppearance: UINavigationBarAppearance? {
			UINavigationBarAppearance(backgroundColor: largeTitleBackgroundColor) ?? UINavigationBarAppearance(blurEffectStyle: largeTitleBlurEffect)
		}
	}
}

private extension UIViewController {
	var scrollView: UIScrollView? { view as? UIScrollView ?? view.subviews.first(ofType: UIScrollView.self) }
}

private extension UINavigationBar {
	var backgroundView: UIView? { subviews.first }
	var backgroundAlpha: CGFloat {
		get { backgroundView?.alpha ?? 0 }
		set { backgroundView?.alpha = newValue }
	}
}

private extension UINavigationBarAppearance {
	convenience init?(blurEffectStyle: UIBlurEffect.Style?) {
		guard let style = blurEffectStyle else { return nil }
		self.init()
		self.backgroundEffect = UIBlurEffect(style: style)
	}

	convenience init?(backgroundColor: UIColor?) {
		guard let color = backgroundColor else { return nil }
		self.init()
		self.backgroundColor = color
	}
}

private extension Array {
	func first<T>(ofType _: T.Type) -> T? {
		first(where: { $0 is T }) as? T
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
