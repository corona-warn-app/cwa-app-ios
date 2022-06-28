//
// 🦠 Corona-Warn-App
//

import UIKit

class HygieneRulesInfoViewController: DynamicTableViewController {
	
	// MARK: - Init
	
	init(
		dismiss: @escaping () -> Void
	) {
		self.dismiss = dismiss

		super.init(nibName: nil, bundle: nil)

		self.dynamicTableViewModel = HygieneRulesInfoViewModel().dynamicTableViewModel
		setupView()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Overrides

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		let emptyImage = UIImage()
		navigationController?.navigationBar.setBackgroundImage(emptyImage, for: .default)
		navigationController?.navigationBar.shadowImage = emptyImage
		navigationController?.navigationBar.isTranslucent = true
		navigationController?.view.backgroundColor = .clear

		navigationController?.navigationBar.prefersLargeTitles = false
		navigationController?.navigationBar.sizeToFit()
		
		setupStatusBarViewBackgroundColorIfNeeded()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		revertStatusBarViewBackgroundColorIfNeeded()
	}

	// MARK: - Private

	private let dismiss: () -> Void
	
	private func setupView() {
		tableView.backgroundColor = .enaColor(for: .background)
		tableView.separatorStyle = .none
		tableView.contentInsetAdjustmentBehavior = .never
		
		navigationItem.rightBarButtonItem = CloseBarButtonItem(onTap: dismiss, accessibilityIdentifierSuffix: AccessibilityIdentifiers.ExposureDetection.closeButtonSuffix)

		if traitCollection.userInterfaceStyle == .dark {
			navigationController?.navigationBar.tintColor = .enaColor(for: .textContrast)
		} else {
			navigationController?.navigationBar.tintColor = .enaColor(for: .tint)
		}
		
		view.backgroundColor = .enaColor(for: .background)

		tableView.separatorStyle = .none
	}
}
