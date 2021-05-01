////
// 🦠 Corona-Warn-App
//

import UIKit

class HealthCertificateConsentViewController: UIViewController, FooterViewHandling, DismissHandling {

	// MARK: - Init

	init(
		didTapConsetButton: @escaping () -> Void
	) {
		self.didTapConsetButton = didTapConsetButton
		self.viewModel = HealthCertificateConsentViewModel()
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()

		parent?.navigationItem.title = "Ihr Einverständnis"
		parent?.navigationItem.rightBarButtonItem = dismissHandlingCloseBarButton
	}

	// MARK: - Protocol FooterViewHandling

	func didTapFooterViewButton(_ type: FooterViewModel.ButtonType) {
		guard type == .primary else {
			return
		}
		didTapConsetButton()
	}

	// MARK: - Public

	// MARK: - Internal

	// MARK: - Private

	private let viewModel: HealthCertificateConsentViewModel
	private let didTapConsetButton: () -> Void

}
