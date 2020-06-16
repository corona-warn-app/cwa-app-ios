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


class NavigationControllerWithFooterView: UINavigationController {
	private var footerView: ENAButtonFooterView!

	private(set) var isFooterViewHidden: Bool {
		get { footerView.isFooterHidden }
		set { footerView.isFooterHidden = newValue }
	}

	override func loadView() {
		super.loadView()

		footerView = ENAButtonFooterView()
		view.addSubview(footerView)
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		if let topViewController = topViewController {
			self.footerView.apply(navigationItem: topViewController.navigationItem)
			self.setFooterViewHidden(topViewController.hidesBottomBarWhenPushed)
		}

		self.layoutFooterView()
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		updateAdditionalSafeAreaInsets()
		layoutFooterView()
	}
}

extension NavigationControllerWithFooterView {
	private func updateAdditionalSafeAreaInsets() {
		var bottomInset: CGFloat = 0

		if !isFooterViewHidden {
			let footerViewSize = footerView.sizeThatFits(view.bounds.size)
			bottomInset += footerViewSize.height
		}

		additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: bottomInset, right: 0)
	}
}

extension NavigationControllerWithFooterView {
	override func pushViewController(_ viewController: UIViewController, animated: Bool) {
		super.pushViewController(viewController, animated: animated)
		transitionFooterView(to: viewController)
	}

	override func popViewController(animated: Bool) -> UIViewController? {
		let viewController = super.popViewController(animated: animated)
		transitionFooterView(to: topViewController)
		return viewController
	}

	override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
		super.setViewControllers(viewControllers, animated: animated)
		transitionFooterView(to: topViewController)
	}
}

extension NavigationControllerWithFooterView {
	func setFooterViewHidden(_ isHidden: Bool, animated: Bool) {
		if animated {
			UIView.animate(withDuration: CATransaction.animationDuration()) {
				self.setFooterViewHidden(isHidden)
				self.updateAdditionalSafeAreaInsets()
				self.layoutFooterView()
			}
		} else {
			self.setFooterViewHidden(isHidden)
			self.updateAdditionalSafeAreaInsets()
			self.layoutFooterView()
		}
	}

	private func setFooterViewHidden(_ isHidden: Bool) {
		guard isHidden != isFooterViewHidden else { return }
		isFooterViewHidden = isHidden
	}

	private func layoutFooterView() {
		var frame = CGRect(
			x: 0,
			y: view.bounds.height,
			width: view.bounds.width,
			height: view.safeAreaInsets.bottom
		)

		if isFooterViewHidden {
			frame.size.height = 0
		} else {
			frame.origin.y -= view.safeAreaInsets.bottom
		}

		footerView.bounds.size = frame.size
		footerView.setNeedsLayout()
		footerView.layoutIfNeeded()
		footerView.frame.origin = frame.origin
	}

	private func transitionFooterView(to viewController: UIViewController?) {
		transitionCoordinator?.animate(alongsideTransition: { context in
			if let toViewController = context.viewController(forKey: .to) {
				self.footerView.apply(navigationItem: toViewController.navigationItem)
				self.setFooterViewHidden(toViewController.hidesBottomBarWhenPushed)
				self.updateAdditionalSafeAreaInsets()
				self.layoutFooterView()
			}

		}, completion: { context in
			if context.isCancelled {
				if let fromViewController = context.viewController(forKey: .from) {
					self.footerView.apply(navigationItem: fromViewController.navigationItem)
					self.setFooterViewHidden(fromViewController.hidesBottomBarWhenPushed)
					self.updateAdditionalSafeAreaInsets()
					self.layoutFooterView()
				}
			}
		})
	}
}
