////
// 🦠 Corona-Warn-App
//

import UIKit

class ValidationInformationViewController: DynamicTableViewController, DismissHandling {

	// MARK: - Init

	init(
		dismiss: @escaping () -> Void
	) {
		self.dismiss = dismiss

		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()

		navigationItem.rightBarButtonItem = dismissHandlingCloseBarButton
		setupView()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		if #unavailable(iOS 13.0) {
			guard let statusBarView = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else {
				return
			}
			statusBarView.backgroundColor = UIColor.white
		}
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		if #unavailable(iOS 13.0) {
			guard let statusBarView = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else {
					return
				}
			statusBarView.backgroundColor = UIColor.clear
		}
	}
	
	// MARK: - Protocol DismissHandling

	func wasAttemptedToBeDismissed() {
		dismiss()
	}

	// MARK: - Private

	private let viewModel: ValidationInformationViewModel = ValidationInformationViewModel()
	private let dismiss: () -> Void
	
	private func setupView() {
		view.backgroundColor = .enaColor(for: .background)
		dynamicTableViewModel = viewModel.dynamicTableViewModel
		tableView.separatorStyle = .none
		tableView.contentInsetAdjustmentBehavior = .never
	}

}
