////
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

final class CheckinCoordinator {

	// MARK: - Init

	init(
		store: Store
	) {
		self.store = store
		
		#if DEBUG
		if isUITesting {
			if let checkinInfoScreenShown = UserDefaults.standard.string(forKey: "checkinInfoScreenShown") {
				store.checkinInfoScreenShown = (checkinInfoScreenShown != "NO")
			}
		}
		#endif
	}

	// MARK: - Internal

	lazy var viewController: UINavigationController = {
		let checkInsTableViewController = CheckinsTableViewController(
			showQRCodeScanner: showQRCodeScanner,
			showSettings: showSettings
		)
		
		// temporary: show the info screen
		if !infoScreenShown {
			return ENANavigationControllerWithFooter(rootViewController: infoScreen(hidesCloseButton: true, dismissAction: { [weak self] in
				guard let self = self else { return }
				self.infoScreenShown = true
			},
			showDetail: { detailViewController in
				self.viewController.pushViewController(detailViewController, animated: true)
			}))
		} else {
			return UINavigationController(rootViewController: checkInsTableViewController)
		}
		
	}()

	// MARK: - Private
	private let store: Store
	private var infoScreenShown: Bool {
		get { store.checkinInfoScreenShown }
		set { store.checkinInfoScreenShown = newValue }
	}

	private func showQRCodeScanner() {
		let qrCodeScanner = CheckinQRCodeScannerViewController(
			didScanCheckin: { [weak self] checkin in
				self?.showCheckinDetails(checkin)
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

	private func showCheckinDetails(_ checkin: Checkin) {
		let checkinDetailViewController = CheckinDetailViewController(
			checkin,
			dismiss: { [weak self] in self?.viewController.dismiss(animated: true) },
			presentCheckins: { [weak self] in
				self?.viewController.dismiss(animated: true, completion: {
//					self?.showCheckins()
				})
			}
		)
		checkinDetailViewController.modalPresentationStyle = .overCurrentContext
		checkinDetailViewController.modalTransitionStyle = .flipHorizontal
		viewController.present(checkinDetailViewController, animated: true)
	}

	private func showSettings() {
		guard let url = URL(string: UIApplication.openSettingsURLString),
			  UIApplication.shared.canOpenURL(url) else {
			Log.debug("Failed to oper settings app", log: .checkin)
			return
		}
		UIApplication.shared.open(url, options: [:])
	}
	
	private func infoScreen(
		hidesCloseButton: Bool = false,
		dismissAction: @escaping (() -> Void),
		showDetail: @escaping ((UIViewController) -> Void)
	) -> UIViewController {
		let viewController = CheckinsInfoScreenViewController(
			viewModel: CheckInsInfoScreenViewModel(
				presentDisclaimer: {
					let detailViewController = HTMLViewController(model: AppInformationModel.privacyModel)
					detailViewController.title = AppStrings.AppInformation.privacyTitle
					showDetail(detailViewController)
				},
				hidesCloseButton: hidesCloseButton
			),
			onDismiss: {
				dismissAction()
			}
		)
		return viewController
	}

	private func presentInfoScreen() {
		// Promise the navigation view controller will be available,
		// this is needed to resolve an inset issue with large titles
		var navigationController: ENANavigationControllerWithFooter!
		let infoVC = infoScreen(
			dismissAction: {
				navigationController.dismiss(animated: true)
			},
			showDetail: { detailViewController in
				navigationController.pushViewController(detailViewController, animated: true)
			}
		)
		// We need to use UINavigationController(rootViewController: UIViewController) here,
		// otherwise the inset of the navigation title is wrong
		navigationController = ENANavigationControllerWithFooter(rootViewController: infoVC)
		viewController.present(navigationController, animated: true)
	}

}
