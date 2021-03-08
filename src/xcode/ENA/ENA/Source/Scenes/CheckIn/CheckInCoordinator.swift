////
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

final class CheckInCoordinator {

	// MARK: - Init

	init() {

	}

	// MARK: - Internal

	lazy var viewController: UINavigationController = {
		let checkInsTableViewController = CheckInsTableViewController()



//		let qrCodeScanner = CheckInQRCodeScannerViewController(
//			presentEventForCheckIn: { [weak self] rect, event in
//				self?.showEventForCheckIn(rect, event: event)
//			},
//			presentCheckIns: { [weak self] in
//				self?.showCheckIns()
//			})
//		qrCodeScanner.definesPresentationContext = true
		return UINavigationController(rootViewController: checkInsTableViewController
		)
	}()

	// MARK: - Private

	private func showCheckIns() {
		let checkInsViewController = CheckInsTableViewController()
		viewController.pushViewController(checkInsViewController, animated: true)
	}

	private func showEventForCheckIn(_ fromRect: CGRect, event: String) {
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
