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

protocol ExposureSubmissionNavigationControllerChild: UIViewController {
	func didTapButton()
	func didTapSecondButton()
}

extension ExposureSubmissionNavigationControllerChild {

	/// Default handler for the button that appears at the bottom of the screen.
	func didTapButton() {}

	/// This is the handler for the second button that appears under the
	/// button normally shown in the screens. Currently,
	/// you can find this button used in `ExposureSubmissionHotlineViewController.swift`.
	func didTapSecondButton() {}
}

extension ExposureSubmissionNavigationControllerChild {
	var exposureSubmissionNavigationController: ExposureSubmissionNavigationController? { navigationController as? ExposureSubmissionNavigationController }
	var button: ENAButton? { exposureSubmissionNavigationController?.button }

	func setButtonTitle(to title: String) {
		exposureSubmissionNavigationController?.setButtonTitle(title: title)
	}

	func setButtonEnabled(enabled: Bool) {
		exposureSubmissionNavigationController?.setButtonEnabled(enabled: enabled)
	}

	func startButtonSpinner() {
		exposureSubmissionNavigationController?.button.isLoading = true
	}

	func stopButtonSpinner() {
		exposureSubmissionNavigationController?.button.isLoading = false
	}

	func setSecondaryButtonTitle(to title: String) {
		exposureSubmissionNavigationController?.setSecondaryButtonTitle(title: title)
	}

	func showSecondaryButton() {
		exposureSubmissionNavigationController?.showSecondaryButton()
	}

	func hideSecondaryButton() {
		exposureSubmissionNavigationController?.hideSecondaryButton()
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

	private(set) var footerView: UIVisualEffectView!
	private(set) var footerStackView: UIStackView!
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
	}

	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	/// Returns the root view controller, depending on whether we have a
	/// registration token or not.
	private func getRootViewController() -> UIViewController {

		// We got a test result and can jump straight into the test result view controller.
		if let service = exposureSubmissionService, testResult != nil, service.hasRegistrationToken() {
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

		let rootVC = getRootViewController()
		setViewControllers([rootVC], animated: false)

		let barButtonItem = UIBarButtonItem(
			image: UIImage(named: "Icons - Close"),
			style: .done, target: self, action: #selector(close)
		)
		barButtonItem.accessibilityLabel = AppStrings.AccessibilityLabel.close
		barButtonItem.accessibilityIdentifier = "AppStrings.AccessibilityLabel.close"
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

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		updateBottomSafeAreaInset()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		applyDefaultRightBarButtonItem(to: topViewController)
		applyNavigationBarItem(of: topViewController)

		keyboardWillShowObserver = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: nil) { [weak self] notification in
			self?.isKeyboardHidden = false
			self?.keyboardWindowFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
			self?.updateBottomSafeAreaInset()
		}

		keyboardWillHideObserver = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: nil) { [weak self] notification in
			self?.isKeyboardHidden = true
			self?.keyboardWindowFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
			self?.updateBottomSafeAreaInset()
		}

		keyboardWillChangeFrameObserver = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillChangeFrameNotification, object: nil, queue: nil) { [weak self] notification in
			self?.keyboardWindowFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
			self?.updateBottomSafeAreaInset()
		}
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		homeViewController?.updateTestResultState()
	}

	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)

		NotificationCenter.default.removeObserver(keyboardWillShowObserver as Any, name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.removeObserver(keyboardWillHideObserver as Any, name: UIResponder.keyboardWillHideNotification, object: nil)
		NotificationCenter.default.removeObserver(keyboardWillChangeFrameObserver as Any, name: UIResponder.keyboardWillHideNotification, object: nil)
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		navigationItem.rightBarButtonItem?.image = UIImage(named: "Icons - Close")
		applyDefaultRightBarButtonItem(to: topViewController)
		updateBottomSafeAreaInset()
	}

	private func applyDefaultRightBarButtonItem(to viewController: UIViewController?) {
		print(viewController?.navigationItem.rightBarButtonItem == navigationItem.rightBarButtonItem)
		if let viewController = viewController,
			viewController.navigationItem.rightBarButtonItem == nil ||
				viewController.navigationItem.rightBarButtonItem == navigationItem.rightBarButtonItem {
			viewController.navigationItem.rightBarButtonItem = navigationItem.rightBarButtonItem
		}
	}

	private func applyNavigationBarItem(of viewController: UIViewController?) {
		let defaultColor = UINavigationBar.appearance().largeTitleTextAttributes?[NSAttributedString.Key.foregroundColor] ?? UIColor.enaColor(for: .textPrimary1)
		if let viewController = viewController,
			let navigationItem = viewController.navigationItem as? ExposureSubmissionNavigationItem,
			let titleColor = navigationItem.titleColor {
			navigationBar.standardAppearance.titleTextAttributes[NSAttributedString.Key.foregroundColor] = defaultColor
			navigationBar.standardAppearance.largeTitleTextAttributes[NSAttributedString.Key.foregroundColor] = titleColor
		} else {
			navigationBar.standardAppearance.titleTextAttributes[NSAttributedString.Key.foregroundColor] = defaultColor
			navigationBar.standardAppearance.largeTitleTextAttributes[NSAttributedString.Key.foregroundColor] = defaultColor
		}
	}

	func setBottomViewHidden(_ hidden: Bool, animated: Bool) {
		guard hidden != isBottomViewHidden else { return }
		isBottomViewHidden = hidden

		updateBottomSafeAreaInset()
		bottomViewTopConstraint.isActive = hidden

		if isBottomViewHidden {
			footerView.frame.origin.y = view.frame.height
			footerView.frame.size.height = 0
		} else {
			footerView.frame.origin.y = view.frame.height - view.safeAreaInsets.bottom
			footerView.frame.size.height = view.safeAreaInsets.bottom
		}

		footerView.layoutIfNeeded()
	}

	func showSecondaryButton() {
		self.secondaryButton.isHidden = false
		updateBottomSafeAreaInset()
	}

	func hideSecondaryButton() {
		self.secondaryButton.isHidden = true
		updateBottomSafeAreaInset()
	}

	private func updateBottomSafeAreaInset() {
		let baseInset = view.safeAreaInsets.bottom - additionalSafeAreaInsets.bottom
		var bottomInset: CGFloat = 0

		if !isBottomViewHidden {
			let size = footerStackView.systemLayoutSizeFitting(.zero, withHorizontalFittingPriority: .defaultLow, verticalFittingPriority: .defaultHigh)
			bottomInset += size.height + footerView.contentView.layoutMargins.top + footerView.contentView.layoutMargins.bottom
		}

		if !isKeyboardHidden {
			if let keyboardWindowFrame = keyboardWindowFrame {
				let localOrigin = view.convert(keyboardWindowFrame.origin, from: nil)
				bottomInset += view.frame.height - localOrigin.y - baseInset
			}
		}

		additionalSafeAreaInsets.bottom = bottomInset

		topViewController?.view.setNeedsLayout()
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
		let view = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
		view.contentView.preservesSuperviewLayoutMargins = false
		view.contentView.insetsLayoutMarginsFromSafeArea = false
		view.contentView.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

		view.translatesAutoresizingMaskIntoConstraints = false
		self.view.addSubview(view)
		view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
		view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
		let topConstraint = view.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
		topConstraint.isActive = true
		topConstraint.priority = .defaultHigh
		let bottomConstraint = view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
		bottomConstraint.isActive = true
		bottomConstraint.priority = .defaultHigh

		bottomViewTopConstraint = view.topAnchor.constraint(equalTo: self.view.bottomAnchor)
		
		button = ENAButton(type: .custom)
		button.setTitle("", for: .normal)

		secondaryButton = ENAButton(type: .custom)
		secondaryButton.setTitle("", for: .normal)
		secondaryButton.isTransparent = true
		secondaryButton.isHidden = true

		let stackView = UIStackView(arrangedSubviews: [button, secondaryButton])
		stackView.axis = .vertical
		stackView.spacing = 8
		stackView.translatesAutoresizingMaskIntoConstraints = false
		view.contentView.addSubview(stackView)
		view.contentView.layoutMarginsGuide.leadingAnchor.constraint(equalTo: stackView.leadingAnchor).isActive = true
		view.contentView.layoutMarginsGuide.trailingAnchor.constraint(equalTo: stackView.trailingAnchor).isActive = true
		view.contentView.layoutMarginsGuide.topAnchor.constraint(equalTo: stackView.topAnchor).isActive = true

		button.addTarget(self, action: #selector(didTapButton), for: .primaryActionTriggered)
		secondaryButton.addTarget(self, action: #selector(didTapSecondaryButton), for: .primaryActionTriggered)

		footerView = view
		footerStackView = stackView

		setBottomViewHidden(false, animated: false)
	}

	@objc
	private func didTapButton() {
		(topViewController as? ExposureSubmissionNavigationControllerChild)?.didTapButton()
	}

	@objc
	private func didTapSecondaryButton() {
		(topViewController as? ExposureSubmissionNavigationControllerChild)?.didTapSecondButton()
	}
}
