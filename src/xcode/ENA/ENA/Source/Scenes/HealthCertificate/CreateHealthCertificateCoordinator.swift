////
// 🦠 Corona-Warn-App
//

import UIKit

final class CreateHealthCertificateCoordinator {

	// MARK: - Init

	init(
		parentViewController: UIViewController
	) {
		self.parentViewController = parentViewController
		self.coordinatorViewModel = CreateHealthCertificateCoordinatorViewModel()
		self.navigationController = UINavigationController()
	}

	// MARK: - Overrides

	// MARK: - Protocol <#Name#>

	// MARK: - Public

	// MARK: - Internal

	func start() {
		if !coordinatorViewModel.hasShownConsetScreem {
			showConsetScreem()
		} else {

		}
	}

	// MARK: - Private

	private let parentViewController: UIViewController
	private let coordinatorViewModel: CreateHealthCertificateCoordinatorViewModel
	private let navigationController: UINavigationController

	private func showConsetScreem() {
		let consetScreen = UIViewController()
		consetScreen.title = "Ihr Einverständnis"
		// we do not animate here because this alwasy is the first screen
		navigationController.pushViewController(consetScreen, animated: false)
		parentViewController.present(navigationController, animated: true)
	}

	private func presentQRCodeScanner() {

	}

}

final class CreateHealthCertificateCoordinatorViewModel {

	// MARK: - Init

	// MARK: - Public

	// MARK: - Internal

	let hasShownConsetScreem: Bool = false
	let hasHealthCertificate: Bool = false

	// MARK: - Private
}
