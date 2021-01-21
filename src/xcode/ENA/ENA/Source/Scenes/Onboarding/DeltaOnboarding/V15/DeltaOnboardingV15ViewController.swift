//
// 🦠 Corona-Warn-App
//

import UIKit

class DeltaOnboardingV15ViewController: DynamicTableViewController, DeltaOnboardingViewControllerProtocol, ENANavigationControllerWithFooterChild, UIAdaptivePresentationControllerDelegate, DismissHandling {

	// MARK: - Attributes

	var finished: (() -> Void)?

	// MARK: - Initializers
	
	init(
		supportedCountries: [Country]
	) {
		self.viewModel = DeltaOnboardingV15ViewModel(supportedCountries: supportedCountries)
		
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - View Lifecycle Methods

	override func viewDidLoad() {
		super.viewDidLoad()

		setupView()
		setupRightBarButtonItem()
	}
	
	// MARK: - Protocol DismissHandling
	
	func wasAttemptedToBeDismissed() {
		finished?()
	}
	
	// MARK: - Protocol ENANavigationControllerWithFooterChild

	func navigationController(_ navigationController: ENANavigationControllerWithFooter, didTapPrimaryButton button: UIButton) {
		finished?()
	}

	// MARK: - Private API

	private let viewModel: DeltaOnboardingV15ViewModel

	private func setupRightBarButtonItem() {
		let closeButton = UIButton(type: .custom)
		closeButton.setImage(UIImage(named: "Icons - Close"), for: .normal)
		closeButton.setImage(UIImage(named: "Icons - Close - Tap"), for: .highlighted)
		closeButton.addTarget(self, action: #selector(close), for: .primaryActionTriggered)

		let barButtonItem = UIBarButtonItem(customView: closeButton)
		barButtonItem.accessibilityLabel = AppStrings.AccessibilityLabel.close
		barButtonItem.accessibilityIdentifier = AccessibilityIdentifiers.AccessibilityLabel.close

		navigationItem.rightBarButtonItem = barButtonItem
	}

	private func setupView() {
		navigationFooterItem?.primaryButtonTitle = AppStrings.DeltaOnboarding.primaryButton
		footerView?.primaryButton?.accessibilityIdentifier = AccessibilityIdentifiers.DeltaOnboarding.primaryButton
		setupTableView()
	}

	private func setupTableView() {
		view.backgroundColor = .enaColor(for: .background)
		tableView.separatorStyle = .none

		tableView.register(
			DynamicTableViewRoundedCell.self,
			forCellReuseIdentifier: CustomCellReuseIdentifiers.roundedCell.rawValue
		)

		dynamicTableViewModel = viewModel.dynamicTableViewModel
	}

	@objc
	func close() {
		finished?()
	}
}

// MARK: - Cell reuse identifiers.

extension DeltaOnboardingV15ViewController {
	enum CustomCellReuseIdentifiers: String, TableViewCellReuseIdentifiers {
		case roundedCell
	}
}
