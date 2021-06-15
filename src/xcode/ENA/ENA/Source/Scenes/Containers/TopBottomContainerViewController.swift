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

	/// Optional function to update the footer view with given `bounds` of the view.
	///
	/// Added to support customized Footer views that don't follow the 'model' approach. Consider this a hack until autolayout implementation is in place.
	/// - Parameters:
	///   - size: The final `size` of the footer view after the update.
	///   - animated: Animated update or not.
	///   - completion: An optional completion handler after the update.
	func update(to size: CGSize, animated: Bool, completion: (() -> Void)?)
}

extension FooterViewUpdating {
	func update(to size: CGSize, animated: Bool, completion: (() -> Void)?) {
		// Intentionally left blank to treat this as an optional protocol function
		preconditionFailure("Called \(#function), but not implemented. Check this.") // to prevent developer errors
	}
}

/** a simple container view controller to combine to view controllers vertically (top / bottom) */

class TopBottomContainerViewController<TopViewController: UIViewController, BottomViewController: UIViewController>: UIViewController, DismissHandling, FooterViewUpdating {

	// MARK: - Init

	deinit {
		subscriptions.forEach { $0.cancel() }
		keyboardSubscriptions.forEach { $0.cancel() }
	}
	
	init(
		topController: TopViewController,
		bottomController: BottomViewController
	) {
		self.topViewController = topController
		self.bottomViewController = bottomController

		// if the the bottom view controller is FooterViewController we use it's viewModel here as well
		self.footerViewModel = (bottomViewController as? FooterViewController)?.viewModel
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
		addChild(bottomViewController)
		bottomViewController.didMove(toParent: self)
		let bottomView: UIView = bottomViewController.view
		bottomView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(bottomView)

		let initialHeight = footerViewModel?.height ?? bottomView.bounds.height
		bottomViewHeightAnchorConstraint = bottomView.safeAreaLayoutGuide.heightAnchor.constraint(equalToConstant: initialHeight)
		
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
				bottomView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
				bottomViewHeightAnchorConstraint
			]
		)

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
				guard let self = self else {
					return
				}
				self.footerViewHandler?.didHideKeyboard()
			}
			.store(in: &keyboardSubscriptions)
		
		// if the the bottom view controller is FooterViewController we use it's viewModel here as well
		if let viewModel = (bottomViewController as? FooterViewController)?.viewModel {
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
		
		guard let footerViewController = (bottomViewController as? FooterViewController) else {
			return
		}
		// clear
		
		subscriptions.forEach { $0.cancel() }
		subscriptions.removeAll()
		
		// setup
		
		footerViewModel = viewModel
		footerViewController.viewModel = viewModel
		
		footerViewModel?.$height.sink { [weak self] height in
			self?.updateBottomHeight(height, animated: true)
		}
		.store(in: &subscriptions)
	}

	func update(to size: CGSize, animated: Bool, completion: (() -> Void)?) {
		updateBottomHeight(size.height, animated: animated, completion: completion)
	}

	// MARK: - Internal

	private (set) var footerViewModel: FooterViewModel?

	// MARK: - Private

	private let topViewController: TopViewController
	private let bottomViewController: BottomViewController

	private var subscriptions: [AnyCancellable] = []
	private var keyboardSubscriptions: [AnyCancellable] = []
	private var bottomViewHeightAnchorConstraint: NSLayoutConstraint!
	private var keyboardDidHideObserver: NSObjectProtocol?

	private func updateBottomHeight(_ height: CGFloat, animated: Bool = false, completion: (() -> Void)? = nil) {
		guard bottomViewHeightAnchorConstraint.constant != height else {
			Log.debug("no height change found")
			return
		}
		view.setNeedsLayout()
		bottomViewHeightAnchorConstraint.constant = height
		let duration = animated ? 0.35 : 0.0
		let animator = UIViewPropertyAnimator(duration: duration, curve: .easeInOut) { [weak self] in
			self?.view.layoutIfNeeded()
		}
		animator.addCompletion { _ in
			completion?()
		}
		animator.startAnimation()
	}
}
