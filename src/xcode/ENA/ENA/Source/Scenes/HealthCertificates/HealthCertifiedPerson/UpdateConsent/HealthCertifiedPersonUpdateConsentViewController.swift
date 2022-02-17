//
// 🦠 Corona-Warn-App
//

import UIKit

class HealthCertifiedPersonUpdateConsentViewController: UIViewController {

	// MARK: - Init

	init(
		presentAlert: @escaping (_ ok: UIAlertAction, _ retry: UIAlertAction) -> Void,
		presentUpdateSuccess: @escaping () -> Void,
		dismiss: @escaping () -> Void
	) {
		self.presentAlert = presentAlert
		self.viewModel = HealthCertifiedPersonUpdateConsentViewModel()
		self.presentUpdateSuccess = presentUpdateSuccess
		self.dismiss = dismiss
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		title = "Update Consent"
	}

	// MARK: - Protocol <#Name#>

	// MARK: - Public

	// MARK: - Internal

	// MARK: - Private
	private let presentAlert: (_ ok: UIAlertAction, _ retry: UIAlertAction) -> Void
	private let presentUpdateSuccess: () -> Void
	private let dismiss: () -> Void
	private let viewModel: HealthCertifiedPersonUpdateConsentViewModel

}
