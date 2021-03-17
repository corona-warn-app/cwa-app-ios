////
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

final class CheckinCoordinator {

	// MARK: - Init

	init(
		store: Store,
		eventStore: EventStoringProviding
	) {
		self.store = store
		self.eventStore = eventStore
	}

	// MARK: - Internal

	lazy var viewController: UINavigationController = {
		let checkinsOverviewViewController = CheckinsOverviewViewController(
			viewModel: CheckinsOverviewViewModel(
				store: eventStore,
				onAddEntryCellTap: { [weak self] in
					self?.showQRCodeScanner()
				},
				onEntryCellTap: { checkin in
					Log.debug("Checkin cell tapped: \(checkin)")
				}
			),
			onInfoButtonTap: {
				Log.debug("Info button tapped")
			},
			onMissingPermissionsButtonTap: { [weak self] in
				self?.showSettings()
			}
		)

		let footerViewController = FooterViewController(
			FooterViewModel(
				primaryButtonName: AppStrings.Checkins.Overview.deleteAllButtonTitle,
				isSecondaryButtonEnabled: false,
				isPrimaryButtonHidden: true,
				isSecondaryButtonHidden: true,
				primaryButtonColor: .enaColor(for: .buttonDestructive)
			)
		)

		let topBottomContainerViewController = TopBottomContainerViewController(
			topController: checkinsOverviewViewController,
			bottomController: footerViewController
		)

		return UINavigationController(rootViewController: topBottomContainerViewController)
	}()

	// MARK: - Private

	private let store: Store
	private let eventStore: EventStoringProviding

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

}
