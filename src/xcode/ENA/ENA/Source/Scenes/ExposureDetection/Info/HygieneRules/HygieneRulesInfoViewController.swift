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
	
	// MARK: - Private

	private let dismiss: () -> Void
	
	private func setupView() {
		navigationItem.largeTitleDisplayMode = .always
		navigationItem.title = AppStrings.ExposureDetection.hygieneRulesTitle
		navigationItem.rightBarButtonItem = CloseBarButtonItem(onTap: dismiss)
		
		if traitCollection.userInterfaceStyle == .dark {
			navigationController?.navigationBar.tintColor = .enaColor(for: .textContrast)
		} else {
			navigationController?.navigationBar.tintColor = .enaColor(for: .tint)
		}
		
		view.backgroundColor = .enaColor(for: .background)

		tableView.separatorStyle = .none
	}
}
