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
		let eventsListViewController = UITableViewController()

		let qrCodeButton: UIBarButtonItem
		if #available(iOS 13.0, *) {
			qrCodeButton = UIBarButtonItem(image: UIImage(systemName: "qrcode.viewfinder"), style: .done, target: self, action: #selector(showQrCodeScanner))
		} else {
			qrCodeButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(showQrCodeScanner))
		}
		eventsListViewController.navigationItem.rightBarButtonItem = qrCodeButton

		return UINavigationController(rootViewController: eventsListViewController)
	}()

	// MARK: - Private

	@objc
	private func showQrCodeScanner() {
		Log.debug("Show QR Code scanner")
	}

}
