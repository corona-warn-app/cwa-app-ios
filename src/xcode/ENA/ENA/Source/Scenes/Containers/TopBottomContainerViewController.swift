////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

protocol FooterViewUpdating {
	var footerViewHandler: FooterViewHandling? { get }

	func setBackgroundColor(_ color: UIColor)
	func update(to state: FooterViewModel.VisibleButtons)
	func setEnabled(_ isEnabled: Bool, button: FooterViewModel.ButtonType)
	func setLoadingIndicator(_ show: Bool, disable: Bool, button: FooterViewModel.ButtonType)
}

/** a simple container view controller to combine to view controllers vertically (top / bottom) */

class TopBottomContainerViewController<TopViewController: UIViewController, BottomView: UIView>: UIViewController, DismissHandling, FooterViewUpdating {

	// MARK: - Init

	deinit {
		subscriptions.forEach { $0.cancel() }
		keyboardSubscriptions.forEach { $0.cancel() }
	}
	
	init(
		topController: TopViewController,
		bottomView: BottomView
	) {
		self.topViewController = topController
		self.bottomView = bottomView
		
		// if the the bottom view controller is FooterView we use it's viewModel here as well
		self.footerViewModel = (bottomView as? FooterView)?.viewModel
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()

		// container configuration
		view.backgroundColor = footerViewModel?.backgroundColor
		navigationController?.navigationBar.prefersLargeTitles = true

		// add top controller
		addChild(topViewController)
		topViewController.didMove(toParent: self)
		let topView: UIView = topViewController.view
		topView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(topView)

		// add bottom controller
		bottomView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(bottomView)

		bottomViewBottomConstraint = bottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
		
		NSLayoutConstraint.activate(
			[
				// topView
				topView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
				topView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
				topView.topAnchor.constraint(equalTo: view.topAnchor),
				topView.bottomAnchor.constraint(equalTo: bottomView.topAnchor),
				// bottomView
				bottomView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
				bottomView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
				bottomViewBottomConstraint
			]
		)
		subscribeToKeyboardNotifications()
		
		// if the the bottom view controller is FooterView we use it's viewModel here as well
		if let viewModel = (bottomView as? FooterView)?.viewModel {
			UIView.performWithoutAnimation {
				self.updateFooterViewModel(viewModel)
			}
		}
	}
	
	// MARK: - Protocol DismissHandling

	func wasAttemptedToBeDismissed() {
		guard let dismissHandler = topViewController as? DismissHandling else {
			return
		}
		dismissHandler.wasAttemptedToBeDismissed()
	}

	// MARK: - Protocol FooterViewUpdating

	var footerViewHandler: FooterViewHandling? {
		return topViewController as? FooterViewHandling
	}

	func update(to state: FooterViewModel.VisibleButtons) {
		footerViewModel?.update(to: state)
	}

	func setEnabled(_ isEnabled: Bool, button: FooterViewModel.ButtonType) {
		footerViewModel?.setEnabled(isEnabled, button: button)
	}

	func setLoadingIndicator(_ show: Bool, disable: Bool, button: FooterViewModel.ButtonType) {
		footerViewModel?.setLoadingIndicator(show, disable: disable, button: button)
	}

	func setBackgroundColor(_ color: UIColor) {
		footerViewModel?.backgroundColor = color
	}

	func updateFooterViewModel(_ viewModel: FooterViewModel) {
		
		guard let footerView = (bottomView as? FooterView) else {
			return
		}
		// clear
		
		subscriptions.forEach { $0.cancel() }
		subscriptions.removeAll()
		
		// setup
		
		footerViewModel = viewModel
		footerView.viewModel = viewModel
	}

	// MARK: - Internal

	private (set) var footerViewModel: FooterViewModel?

	// MARK: - Private

	private let topViewController: TopViewController
	private let bottomView: BottomView

	private var subscriptions: [AnyCancellable] = []
	private var keyboardSubscriptions: [AnyCancellable] = []
	private var bottomViewBottomConstraint: NSLayoutConstraint!
	
	private func subscribeToKeyboardNotifications() {
		NotificationCenter.default.ocombine.publisher(for: UIApplication.keyboardWillShowNotification)
			.append(NotificationCenter.default.ocombine.publisher(for: UIApplication.keyboardWillChangeFrameNotification))
			.sink { [weak self] notification in
				
				guard let self = self,
					  let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
					  let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
					  let animationCurve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int else {
					return
				}
				
				self.bottomViewBottomConstraint.constant = -keyboardFrame.height
				
				let options = UIView.AnimationOptions(rawValue: (UInt(animationCurve << 16)))
				UIView.animate(withDuration: animationDuration, delay: 0, options: options, animations: { [weak self] in
					self?.view.layoutIfNeeded()
				}, completion: nil)
			}
			.store(in: &keyboardSubscriptions)
		
		NotificationCenter.default.ocombine.publisher(for: UIApplication.keyboardWillHideNotification)
			.sink { [weak self] notification in
				
				guard let self = self,
					  let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
					  let animationCurve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int else {
					return
				}
				
				self.bottomViewBottomConstraint.constant = -self.view.safeAreaInsets.bottom
				
				let options = UIView.AnimationOptions(rawValue: (UInt(animationCurve << 16)))
				UIView.animate(withDuration: animationDuration, delay: 0, options: options, animations: { [weak self] in
					self?.view.layoutIfNeeded()
				}, completion: nil)
			}
			.store(in: &keyboardSubscriptions)
		
		NotificationCenter.default.ocombine.publisher(for: UIApplication.keyboardDidShowNotification)
			.sink { [weak self] notification in
				guard let self = self,
					  let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
					return
				}
				self.footerViewHandler?.didShowKeyboard(keyboardFrame)
			}
			.store(in: &keyboardSubscriptions)
		
		NotificationCenter.default.ocombine.publisher(for: UIApplication.keyboardDidHideNotification)
			.sink { [weak self] _ in
				self?.footerViewHandler?.didHideKeyboard()
			}
			.store(in: &keyboardSubscriptions)
	}
}
