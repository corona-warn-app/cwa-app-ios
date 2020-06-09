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

		delegate = self
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

extension AppNavigationController: UINavigationControllerDelegate {
	func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
		scrollViewObserver?.invalidate()

		var navigationBackgroundAlpha: CGFloat = 1.0
		var largeTitleBlurEffect: UIBlurEffect.Style?

		if let opacityDelegate = viewController as? NavigationBarOpacityDelegate {
			navigationBackgroundAlpha = opacityDelegate.backgroundAlpha
			largeTitleBlurEffect = opacityDelegate.preferredLargeTitleBlurEffect

			if let scrollView = viewController.view as? UIScrollView ?? viewController.view.subviews.first(ofType: UIScrollView.self) {
				scrollViewObserver = scrollView.observe(\.contentOffset) { [weak self] _, _ in
					guard let self = self else { return }
					guard viewController == self.topViewController else { return }
					self.navigationBar.backgroundAlpha = opacityDelegate.backgroundAlpha
				}
			}
		}

		let previousNavigationBackgroundAlpha = navigationBar.backgroundAlpha
		let previousScrollEdgeAppearance = navigationBar.scrollEdgeAppearance
		transitionCoordinator?.animate(alongsideTransition: { _ in
			self.navigationBar.backgroundAlpha = navigationBackgroundAlpha

			if let largeTitleBlurEffect = largeTitleBlurEffect {
				self.navigationBar.scrollEdgeAppearance = UINavigationBarAppearance()
				self.navigationBar.scrollEdgeAppearance?.backgroundEffect = UIBlurEffect(style: largeTitleBlurEffect)
			} else {
				self.navigationBar.scrollEdgeAppearance = self.defaultScrollEdgeAppearance
			}

		}, completion: { context in
			if context.isCancelled {
				self.navigationBar.backgroundAlpha = previousNavigationBackgroundAlpha
				self.navigationBar.scrollEdgeAppearance = previousScrollEdgeAppearance
			}
		})
	}
}

extension UINavigationBar {
	var backgroundView: UIView? { subviews.first }
	var backgroundAlpha: CGFloat {
		get { backgroundView?.alpha ?? 0 }
		set { backgroundView?.alpha = newValue }
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
}

extension NavigationBarOpacityDelegate {
	var preferredNavigationBarOpacity: CGFloat { 1.0 }
	var preferredLargeTitleBlurEffect: UIBlurEffect.Style? { nil }
	fileprivate var backgroundAlpha: CGFloat { max(0, min(preferredNavigationBarOpacity, 1)) }
}
