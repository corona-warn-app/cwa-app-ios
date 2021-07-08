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
		setupTransparentNavigationBar()
		setupView()
	}

	// MARK: - Protocol DismissHandling

	func wasAttemptedToBeDismissed() {
		dismiss()
	}

	// MARK: - Private

	private let viewModel: ValidationInformationViewModel = ValidationInformationViewModel()
	private let dismiss: () -> Void
	
	private var backgroundImage: UIImage?
	private var shadowImage: UIImage?
	private var isTranslucent: Bool = false
	private var backgroundColor: UIColor?

	private func setupTransparentNavigationBar() {
		// save current state
		guard let navigationController = navigationController else {
			Log.debug("no navigation controller found - stop")
			return
		}

		backgroundImage = navigationController.navigationBar.backgroundImage(for: .default)
		shadowImage = navigationController.navigationBar.shadowImage
		isTranslucent = navigationController.navigationBar.isTranslucent
		backgroundColor = navigationController.view.backgroundColor

		let emptyImage = UIImage()
		navigationController.navigationBar.setBackgroundImage(emptyImage, for: .default)
		navigationController.navigationBar.shadowImage = emptyImage
		navigationController.navigationBar.isTranslucent = true
		navigationController.view.backgroundColor = .clear
	}

	private func restoreOriginalNavigationBar() {
		navigationController?.navigationBar.setBackgroundImage(backgroundImage, for: .default)
		navigationController?.navigationBar.shadowImage = shadowImage
		navigationController?.navigationBar.isTranslucent = isTranslucent
		navigationController?.view.backgroundColor = backgroundColor

		// reset to initial values
		backgroundImage = nil
		shadowImage = nil
		backgroundColor = nil
	}

	private func setupView() {
		view.backgroundColor = .enaColor(for: .background)

		tableView.register(
			UINib(nibName: String(describing: DynamicLegalExtendedCell.self), bundle: nil),
			forCellReuseIdentifier: DynamicLegalExtendedCell.reuseIdentifier
		)

		tableView.register(
			HealthCertificateAttributedTextCell.self,
			forCellReuseIdentifier: HealthCertificateAttributedTextCell.reuseIdentifier
		)

		dynamicTableViewModel = viewModel.dynamicTableViewModel
		tableView.separatorStyle = .none
		tableView.contentInsetAdjustmentBehavior = .never
	}

}
