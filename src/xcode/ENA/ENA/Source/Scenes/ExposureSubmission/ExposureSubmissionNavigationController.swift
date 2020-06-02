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

import Foundation
import UIKit

@IBDesignable
class ExposureSubmissionNavigationItem: UINavigationItem {
	@IBInspectable var titleColor: UIColor?
}

protocol ExposureSubmissionNavigationControllerChild: AnyObject {
	var bottomView: UIView? { get }
	func didTapBottomButton()
	func didTapSecondButton()
}

extension ExposureSubmissionNavigationControllerChild {
	func didTapBottomButton() {}
	func didTapSecondButton() {}
}

extension ExposureSubmissionNavigationControllerChild where Self: UIViewController {
	var bottomView: UIView? { (navigationController as? ExposureSubmissionNavigationController)?.bottomView }
	var button: UIView? { (navigationController as? ExposureSubmissionNavigationController)?.button }

	func setButtonTitle(to title: String) {
		(navigationController as? ExposureSubmissionNavigationController)?
			.setButtonTitle(title: title)
	}

	func setButtonEnabled(enabled: Bool) {
		(navigationController as? ExposureSubmissionNavigationController)?
			.setButtonEnabled(enabled: enabled)
	}

	func hideButton() {
		(navigationController as? ExposureSubmissionNavigationController)?
			.button.isHidden = true
	}

	func setSecondaryButtonTitle(to title: String) {
		(navigationController as? ExposureSubmissionNavigationController)?
			.setSecondaryButtonTitle(title: title)
	}

	func showSecondaryButton() {
		(navigationController as? ExposureSubmissionNavigationController)?
			.secondaryButton.isHidden = false
	}

	func hideSecondaryButton() {
		(navigationController as? ExposureSubmissionNavigationController)?
			.secondaryButton.isHidden = true
	}
}

class ExposureSubmissionNavigationController: UINavigationController, UINavigationControllerDelegate {

	private weak var homeViewController: HomeViewController?
	private var testResult: TestResult?
	private var keyboardWillShowObserver: NSObjectProtocol?
	private var keyboardWillHideObserver: NSObjectProtocol?
	private var keyboardWillChangeFrameObserver: NSObjectProtocol?

	private(set) var isBottomViewHidden: Bool = true
	private var isKeyboardHidden: Bool = true
	private var keyboardWindowFrame: CGRect?

	private(set) var bottomView: UIView!
	private(set) var button: ENAButton!
	private(set) var secondaryButton: ENAButton!
	private var bottomViewTopConstraint: NSLayoutConstraint!
	private var exposureSubmissionService: ExposureSubmissionService?

	// MARK: - Initializers.

	init?(
		coder: NSCoder,
		exposureSubmissionService: ExposureSubmissionService,
		homeViewController: HomeViewController? = nil,
		testResult: TestResult? = nil
	) {
		super.init(coder: coder)
		self.exposureSubmissionService = exposureSubmissionService
		self.homeViewController = homeViewController
		self.testResult = testResult

		let rootVC = getRootViewController()
		viewControllers = [rootVC]
	}

	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	/// Returns the root view controller, depending on whether we have a
	/// registration token or not.
	private func getRootViewController() -> UIViewController {

		// We got a test result and can jump straight into the test result view controller.
		if let service = exposureSubmissionService, testResult != nil {
			let vc = AppStoryboard.exposureSubmission.initiate(viewControllerType: ExposureSubmissionTestResultViewController.self)
			vc.exposureSubmissionService = service
			vc.testResult = testResult
			return vc
		}

		// By default, we show the intro view.
		let vc = AppStoryboard.exposureSubmission.initiate(viewControllerType: ExposureSubmissionIntroViewController.self)
		return vc
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		let barButtonItem = UIBarButtonItem(
			image: UIImage(named: "Icons - Close - Light"),
			style: .done, target: self, action: #selector(close)
		)
		navigationItem.rightBarButtonItem = barButtonItem

		setupBottomView()

		if topViewController?.hidesBottomBarWhenPushed ?? false {
			setBottomViewHidden(true, animated: false)
		}

		delegate = self
	}

	func setButtonTitle(title: String) {
		button.setTitle(title, for: .normal)
	}

	func setSecondaryButtonTitle(title: String) {
		secondaryButton.setTitle(title, for: .normal)
	}

	func setButtonEnabled(enabled: Bool) {
		button.isEnabled = enabled
	}

	func getExposureSubmissionService() -> ExposureSubmissionService? {
		exposureSubmissionService
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		applyDefaultRightBarButtonItem(to: topViewController)
		applyNavigationBarItem(of: topViewController)

		keyboardWillShowObserver = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: nil) { notification in
			self.isKeyboardHidden = false
			self.keyboardWindowFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
			self.updateBottomSafeAreaInset(animated: true)
		}

		keyboardWillHideObserver = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: nil) { notification in
			self.isKeyboardHidden = true
			self.keyboardWindowFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
			self.updateBottomSafeAreaInset(animated: true)
		}

		keyboardWillChangeFrameObserver = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillChangeFrameNotification, object: nil, queue: nil) { notification in
			self.keyboardWindowFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
			self.updateBottomSafeAreaInset(animated: true)
		}
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillAppear(animated)
	}

	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)

		NotificationCenter.default.removeObserver(keyboardWillShowObserver as Any, name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.removeObserver(keyboardWillHideObserver as Any, name: UIResponder.keyboardWillHideNotification, object: nil)
		NotificationCenter.default.removeObserver(keyboardWillChangeFrameObserver as Any, name: UIResponder.keyboardWillHideNotification, object: nil)
	}

	private func applyDefaultRightBarButtonItem(to viewController: UIViewController?) {
		if let viewController = viewController, viewController.navigationItem.rightBarButtonItem == nil {
			viewController.navigationItem.rightBarButtonItem = navigationItem.rightBarButtonItem
		}
	}

	private func applyNavigationBarItem(of viewController: UIViewController?) {
		if let viewController = viewController,
			let navigationItem = viewController.navigationItem as? ExposureSubmissionNavigationItem,
			let titleColor = navigationItem.titleColor {
			navigationBar.largeTitleTextAttributes = [:]
			navigationBar.largeTitleTextAttributes?[NSAttributedString.Key.foregroundColor] = titleColor
		} else {
			navigationBar.largeTitleTextAttributes?.removeValue(forKey: NSAttributedString.Key.foregroundColor)
		}
	}

	func setBottomViewHidden(_ hidden: Bool, animated: Bool) {
		guard hidden != isBottomViewHidden else { return }
		isBottomViewHidden = hidden

		updateBottomSafeAreaInset(animated: animated)
		bottomViewTopConstraint.isActive = hidden

		if animated { CATransaction.begin() }

		if isBottomViewHidden {
			bottomView.frame.origin.y = view.frame.height
			bottomView.frame.size.height = 0
		} else {
			bottomView.frame.origin.y = view.frame.height - view.safeAreaInsets.bottom
			bottomView.frame.size.height = view.safeAreaInsets.bottom
		}

		bottomView.layoutIfNeeded()

		if animated { CATransaction.commit() }
	}

	private func updateBottomSafeAreaInset(animated: Bool = false) {
		let baseInset = view.safeAreaInsets.bottom - additionalSafeAreaInsets.bottom
		var bottomInset: CGFloat = 0

		if !isBottomViewHidden { bottomInset += 90 }
		if !secondaryButton.isHidden { bottomInset += 50 }

		if !isKeyboardHidden {
			if let keyboardWindowFrame = keyboardWindowFrame {
				let localOrigin = view.convert(keyboardWindowFrame.origin, from: nil)
				bottomInset += view.frame.height - localOrigin.y - baseInset
			}
		}

		additionalSafeAreaInsets.bottom = bottomInset

		if animated {
			CATransaction.begin()
			topViewController?.view.layoutIfNeeded()
			CATransaction.commit()
		}
	}

	@objc
	func close() {
		dismiss(animated: true)
	}
}

extension ExposureSubmissionNavigationController {
	func navigationController(_: UINavigationController, willShow viewController: UIViewController, animated _: Bool) {
		applyDefaultRightBarButtonItem(to: viewController)
		applyNavigationBarItem(of: viewController)

		let isBottomViewHidden = self.isBottomViewHidden

		transitionCoordinator?.animate(alongsideTransition: { _ in
			self.setBottomViewHidden(viewController.hidesBottomBarWhenPushed, animated: false)
		}, completion: { context in
			if context.isCancelled {
				self.setBottomViewHidden(isBottomViewHidden, animated: true)
				self.applyNavigationBarItem(of: self.topViewController)
			}
        })
	}
}

extension ExposureSubmissionNavigationController {
	private func setupBottomView() {
		let view = UIView()
		view.backgroundColor = .preferredColor(for: .backgroundPrimary)
		view.insetsLayoutMarginsFromSafeArea = true
		view.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)

		view.translatesAutoresizingMaskIntoConstraints = false
		self.view.addSubview(view)
		view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
		view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
		let bottomConstraint = view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
		bottomConstraint.isActive = true
		bottomConstraint.priority = .defaultHigh
		bottomViewTopConstraint = view.topAnchor.constraint(equalTo: self.view.bottomAnchor)

		button = ENAButton(type: .system)
		button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body).scaledFont(size: 17, weight: .semibold)
		button.setTitle("", for: .normal)

		button.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(button)
		button.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor).isActive = true
		button.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor).isActive = true
		button.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor).isActive = true
		button.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: 90).isActive = true
		button.heightAnchor.constraint(equalToConstant: 50).isActive = true

		// by default, the secondary button is hidden.
		secondaryButton = ENAButton(type: .system)
		secondaryButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body).scaledFont(size: 17, weight: .bold)
		secondaryButton.setTitle("", for: .normal)
		secondaryButton.backgroundColor = .clear
		secondaryButton.setTitleColor(.preferredColor(for: .inactiveRisk), for: .normal)
		secondaryButton.translatesAutoresizingMaskIntoConstraints = false
		secondaryButton.isHidden = true
		view.addSubview(secondaryButton)

		secondaryButton.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor).isActive = true
		secondaryButton.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor).isActive = true
		secondaryButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
		secondaryButton.centerXAnchor.constraint(equalTo: button.centerXAnchor).isActive = true
		secondaryButton.topAnchor.constraint(equalTo: button.bottomAnchor, constant: 5).isActive = true

		bottomView = view
		button.addTarget(self, action: #selector(didTapButton), for: .primaryActionTriggered)
		secondaryButton.addTarget(self, action: #selector(didTapSecondaryButton), for: .primaryActionTriggered)
		setBottomViewHidden(false, animated: false)
	}

	@objc
	private func didTapButton() {
		(topViewController as? ExposureSubmissionNavigationControllerChild)?.didTapBottomButton()
	}

	@objc
	private func didTapSecondaryButton() {
		(topViewController as? ExposureSubmissionNavigationControllerChild)?.didTapSecondButton()
	}
}
