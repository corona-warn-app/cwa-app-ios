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
		let checkInsTableViewController = CheckInsTableViewController(
			showQRCodeScanner: showQRCodeScanner,
			showSettings: showSettings
		)

		return UINavigationController(rootViewController: checkInsTableViewController)
	}()

	// MARK: - Private

	private func showQRCodeScanner() {
		let qrCodeScanner = CheckInQRCodeScannerViewController(
			didScanCheckIn: { [weak self] event in
				self?.showEventForCheckIn(event)
			},
			dismiss: { [weak self] in
				self?.viewController.dismiss(animated: true)
			}
		)
		qrCodeScanner.definesPresentationContext = true
		DispatchQueue.main.async { [weak self] in
			let navigationController = UINavigationController(rootViewController: qrCodeScanner)
			navigationController.modalPresentationStyle = .fullScreen
			self?.viewController.present(navigationController, animated: true)
		}
	}

	private func showEventForCheckIn(_ event: Event) {
		let eventDetailViewController = CheckInDetailViewController(
			event,
			dismiss: { [weak self] in self?.viewController.dismiss(animated: true) },
			presentCheckIns: { [weak self] in
				self?.viewController.dismiss(animated: true, completion: {
					//					self?.showCheckIns()
				})
			}
		)
		eventDetailViewController.modalPresentationStyle = .overCurrentContext
		eventDetailViewController.modalTransitionStyle = .flipHorizontal
		viewController.present(eventDetailViewController, animated: true)
	}

	private func showSettings() {
		guard let url = URL(string: UIApplication.openSettingsURLString),
			  UIApplication.shared.canOpenURL(url) else {
			Log.debug("Failed to oper settings app", log: .checkin)
			return
		}
		UIApplication.shared.open(url, options: [:])
	}

}
