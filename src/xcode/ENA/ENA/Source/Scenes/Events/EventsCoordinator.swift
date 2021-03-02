////
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

final class EventsCoordinator {

	// MARK: - Init

	init() {

	}

	// MARK: - Overrides

	// MARK: - Protocol <#Name#>

	// MARK: - Public

	// MARK: - Internal

	lazy var viewController: UINavigationController = {
		let qrCodeScanner = QRCodeScannerViewController(
			presentCheckIns: { [weak self] in
				self?.showCheckIns()
			})
		return UINavigationController(rootViewController: qrCodeScanner)
	}()

	// MARK: - Private

	private func showCheckIns() {
		let checkInsViewController = CheckInsTableViewController()
		viewController.pushViewController(checkInsViewController, animated: true)
	}

}
