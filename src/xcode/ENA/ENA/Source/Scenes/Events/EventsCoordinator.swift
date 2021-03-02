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
		qrCodeScanner.definesPresentationContext = true
		return UINavigationController(rootViewController: qrCodeScanner)
	}()

	// MARK: - Private

	private func showCheckIns() {
		let eventDetailViewController = EventDetailViewController("Ich bin ein TestEvent")
		eventDetailViewController.modalPresentationStyle = .overCurrentContext
//		eventDetailViewController.isModalInPresentation = false
		eventDetailViewController.modalTransitionStyle = .flipHorizontal
		viewController.present(eventDetailViewController, animated: true)

//		let checkInsViewController = CheckInsTableViewController()
//		viewController.pushViewController(checkInsViewController, animated: true)
	}

}
