//
// 🦠 Corona-Warn-App
//

import UIKit

class DeltaOnboardingNewVersionFeaturesViewController: DynamicTableViewController, DeltaOnboardingViewControllerProtocol, ENANavigationControllerWithFooterChild, DismissHandling {

	// MARK: - Attributes

	var finished: (() -> Void)?

	// MARK: - Initializers
	
	init(featureVersion: String = "", hasCloseButton: Bool = true) {
		self.viewModel = DeltaOnboardingNewVersionFeaturesViewModel()
		self.hasCloseButton = hasCloseButton
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - View Lifecycle Methods

	override func viewDidLoad() {
		super.viewDidLoad()

		setupTableView()

		if hasCloseButton {
			setupRightBarButtonItem()
		}
	}

	// MARK: - Overrides

	override var navigationItem: UINavigationItem {
		navigationFooterItem
	}

	private lazy var navigationFooterItem: ENANavigationFooterItem = {
		let item = ENANavigationFooterItem()

		item.primaryButtonTitle = AppStrings.NewVersionFeatures.buttonContinue
		item.isPrimaryButtonEnabled = true
		item.isSecondaryButtonHidden = true

		item.title = AppStrings.NewVersionFeatures.title

		item.rightBarButtonItem = CloseBarButtonItem(
			onTap: { [weak self] in
				self?.finished?()
			}
		)
		
		return item
	}()
	
	// MARK: - Protocol DismissHandling
	
	func wasAttemptedToBeDismissed() {
		finished?()
	}
	
	// MARK: - Protocol ENANavigationControllerWithFooterChild

	func navigationController(_ navigationController: ENANavigationControllerWithFooter, didTapPrimaryButton button: UIButton) {
		finished?()
	}

	// MARK: - Private API

	private let viewModel: DeltaOnboardingNewVersionFeaturesViewModel
	private let hasCloseButton: Bool

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

extension DeltaOnboardingNewVersionFeaturesViewController {
	enum CustomCellReuseIdentifiers: String, TableViewCellReuseIdentifiers {
		case roundedCell
	}
}
