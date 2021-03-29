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

/** a simple container view controller to combine to view controllers vertically (top / bottom */

class TopBottomContainerViewController<TopViewController: UIViewController, BottomViewController: UIViewController>: UIViewController, DismissHandling, FooterViewUpdating {

	// MARK: - Init

	init(
		topController: TopViewController,
		bottomController: BottomViewController
	) {
		self.topViewController = topController
		self.bottomViewController = bottomController
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

		bottomViewHeightAnchorConstraint = bottomView.safeAreaLayoutGuide.heightAnchor.constraint(equalToConstant: 0.0)
		bottomViewBottomAnchorConstraint = bottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor)

		view.addSubview(bottomView)
		NSLayoutConstraint.activate(
			[
				topView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
				topView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
				topView.topAnchor.constraint(equalTo: view.topAnchor),
				bottomView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
				bottomView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
				bottomView.topAnchor.constraint(equalTo: topView.bottomAnchor),
				bottomViewBottomAnchorConstraint,
				bottomViewHeightAnchorConstraint
			]
		)

		// if the the bottom view controller is FooterViewController we use it's viewModel here as well
		if let viewModel = (bottomViewController as? FooterViewController)?.viewModel {
			UIView.performWithoutAnimation {
				self.updateFooterViewModel(viewModel)
			}
		}

		NotificationCenter.default.ocombine.publisher(for: UIApplication.keyboardWillShowNotification)
			.sink { [weak self] notification in
				let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue

				guard let self = self, let keyboardHeight = keyboardSize?.height else {
					return
				}

				self.bottomViewBottomAnchorConstraint.constant = -keyboardHeight

				UIView.animate(withDuration: 0.5) {
					self.view.layoutIfNeeded()
				}
			}
			.store(in: &subscriptions)

		NotificationCenter.default.ocombine.publisher(for: UIApplication.keyboardWillHideNotification)
			.sink { [weak self] _ in
				self?.bottomViewBottomAnchorConstraint.constant = 0

				UIView.animate(withDuration: 0.5) {
					self?.view.layoutIfNeeded()
				}
			}
			.store(in: &subscriptions)
	}

	// MARK: - Protocol DismissHandling

	func wasAttemptedToBeDismissed() {
		guard let dismissHandler = topViewController as? DismissHandling else {
			return
		}
		dismissHandler.wasAttemptedToBeDismissed()
	}

	// MARK: Protocol FooterViewUpdating

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

	// MARK: - Internal

	private (set) var footerViewModel: FooterViewModel?

	// MARK: - Private

	private let topViewController: TopViewController
	private let bottomViewController: BottomViewController

	private var subscriptions: [AnyCancellable] = []
	private var bottomViewHeightAnchorConstraint: NSLayoutConstraint!
	private var bottomViewBottomAnchorConstraint: NSLayoutConstraint!

	private func updateBottomHeight(_ height: CGFloat, animated: Bool = false) {
		guard bottomViewHeightAnchorConstraint.constant != height else {
			Log.debug("no height change found")
			return
		}
		let duration = animated ? 0.35 : 0.0
		let animator = UIViewPropertyAnimator(duration: duration, curve: .easeInOut) { [weak self] in
			self?.bottomViewHeightAnchorConstraint.constant = height
			self?.view.layoutIfNeeded()
		}
		animator.startAnimation()
	}

}
