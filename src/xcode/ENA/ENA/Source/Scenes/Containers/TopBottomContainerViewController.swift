////
// 🦠 Corona-Warn-App
//

import UIKit

/** a simple container view controller to combine to view controllers vertically (top / bottom */

class TopBottomContainerViewController<TopViewController: UIViewController, BottomViewController: UIViewController>: UIViewController, DismissHandling {

	// MARK: - Init

	init(
		topController: TopViewController,
		bottomController: BottomViewController,
		bottomHeight: CGFloat
	) {
		self.topViewController = topController
		self.bottomViewController = bottomController
		self.initialHeight = bottomHeight
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
		view.backgroundColor = .enaColor(for: .background)
		navigationController?.navigationBar.prefersLargeTitles = true

		// add top controller
		addChild(topViewController)
		let topView: UIView = topViewController.view
		topView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(topView)

		// add bottom controller
		addChild(bottomViewController)
		let bottomView: UIView = bottomViewController.view
		bottomView.translatesAutoresizingMaskIntoConstraints = false

		bottomViewHeightAnchorConstraint = bottomView.safeAreaLayoutGuide.heightAnchor.constraint(equalToConstant: initialHeight)
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
		topViewController.didMove(toParent: self)
		bottomViewController.didMove(toParent: self)
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		title = topViewController.title
	}

	// MARK: - Protocol DismissHandling

	func wasAttemptedToBeDismissed() {
		guard let dismissHandler = topViewController as? DismissHandling else {
			return
		}
		dismissHandler.wasAttemptedToBeDismissed()
	}

	// MARK: - Public

	// MARK: - Internal

	// MARK: - Private

	private let topViewController: TopViewController
	private let bottomViewController: BottomViewController
	private let initialHeight: CGFloat
	private var bottomViewHeightAnchorConstraint: NSLayoutConstraint!

}
