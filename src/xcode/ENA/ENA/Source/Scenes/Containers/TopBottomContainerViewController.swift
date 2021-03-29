////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

protocol FooterViewUpdating {
	var footerViewHandler: FooterViewHandling? { get }

	func setBackgroundColor(_ color: UIColor)
	func update(to state: FooterViewModel.VisibleButtons)
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
		view.addSubview(bottomView)
		NSLayoutConstraint.activate(
			[
				topView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
				topView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
				topView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
				bottomView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
				bottomView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
				bottomView.topAnchor.constraint(equalTo: topView.bottomAnchor, constant: 0),
				bottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
				bottomViewHeightAnchorConstraint
			]
		)

		// if the the bottom view controller is FooterViewController we use it's viewModel here as well
		if let viewModel = (bottomViewController as? FooterViewController)?.viewModel {
			updateFooterViewModel(viewModel)
		}
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
