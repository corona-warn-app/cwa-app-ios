////
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

final class CheckInCoordinator {

	// MARK: - Init

	init() {

	}

	// MARK: - Overrides

	// MARK: - Protocol <#Name#>

	// MARK: - Public

	// MARK: - Internal

	lazy var viewController: UINavigationController = {
		let qrCodeScanner = CheckInQRCodeScannerViewController(
			presentEventForCheckIn: { [weak self] event in
				self?.showEventForCheckIn(event)
			},
			presentCheckIns: { [weak self] in
				self?.showCheckIns()
			})
		qrCodeScanner.definesPresentationContext = true
		return UINavigationController(rootViewController: qrCodeScanner)
	}()

	// MARK: - Private

	private func showCheckIns() {
		let checkInsViewController = CheckInsTableViewController()
		viewController.pushViewController(checkInsViewController, animated: true)
	}

	private func showEventForCheckIn(_ event: String) {
		let eventDetailViewController = CheckInDetailViewController(
			"Ich bin ein TestEvent",
			dismiss: { [weak self] in self?.viewController.dismiss(animated: true) },
			presentCheckIns: { [weak self] in
				self?.viewController.dismiss(animated: true, completion: {
					self?.showCheckIns()
				})
			}
		)
		eventDetailViewController.modalPresentationStyle = .overCurrentContext
		eventDetailViewController.modalTransitionStyle = .flipHorizontal
		viewController.present(eventDetailViewController, animated: true)
	}

}
