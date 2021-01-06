//
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine
import UIKit

enum UpdateAlertType {
	case none
	case update
	case forceUpdate
}

final class AppUpdateCheckHelper {
	// MARK: Properties
	private let appConfigurationProvider: AppConfigurationProviding
	private let store: Store
	private var subscriptions = [AnyCancellable]()

	/// The retained `NotificationCenter` observer that listens for `UIApplication.didBecomeActiveNotification` notifications.
	var applicationDidBecomeActiveObserver: NSObjectProtocol?

	init(appConfigurationProvider: AppConfigurationProviding, store: Store) {
		self.appConfigurationProvider = appConfigurationProvider
		self.store = store
	}

	// MARK: Deinit
	deinit {
		removeObserver()
	}

	func checkAppVersionDialog(for vc: UIViewController?) {
		appConfigurationProvider.appConfiguration().sink { [weak self] applicationConfiguration in
			guard let self = self else { return }
			
			let alertType = self.alertTypeFrom(
				currentVersion: Bundle.main.appVersion,
				minVersion: applicationConfiguration.minVersion,
				latestVersion: applicationConfiguration.latestVersion
			)

			guard let alert = self.createAlert(alertType, vc: vc) else { return }
			vc?.present(alert, animated: true, completion: nil)
		}.store(in: &subscriptions)
	}

	private func setObserver(vc: UIViewController?, alertType: UpdateAlertType) {
		guard applicationDidBecomeActiveObserver == nil else { return }
		applicationDidBecomeActiveObserver = NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil) { [weak self] _ in
			guard let self = self else { return }
			let alreadyPresentingSomething = vc?.presentedViewController != nil
			guard alreadyPresentingSomething == false else {
				return
			}
			guard let alert = self.createAlert(alertType, vc: vc) else {
				return
			}
			vc?.present(alert, animated: true, completion: nil)
		}
	}

	private func removeObserver() {
		NotificationCenter.default.removeObserver(applicationDidBecomeActiveObserver as Any)
		applicationDidBecomeActiveObserver = nil
	}

	func createAlert(_ type: UpdateAlertType, vc: UIViewController?) -> UIAlertController? {
		let alert = UIAlertController(title: AppStrings.UpdateMessage.title, message: AppStrings.UpdateMessage.text, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: NSLocalizedString(AppStrings.UpdateMessage.actionUpdate, comment: ""), style: .cancel, handler: { _ in
			 let url = URL(staticString: "https://apps.apple.com/de/app/corona-warn-app/id1512595757?mt=8")
			UIApplication.shared.open(url, options: [:], completionHandler: nil)
		}))
		switch type {
		case .update:
			alert.addAction(UIAlertAction(title: NSLocalizedString(AppStrings.UpdateMessage.actionLater, comment: ""), style: .default, handler: { _ in
				// Do nothing
			}))
		case .forceUpdate:
			alert.message = AppStrings.UpdateMessage.textForce
			self.setObserver(vc: vc, alertType: type)
		case .none:
			return nil
		}
		return alert
	}

	func alertTypeFrom(
		currentVersion: String,
		minVersion: SAP_Internal_V2_SemanticVersion,
		latestVersion: SAP_Internal_V2_SemanticVersion
	) -> UpdateAlertType {
		guard let currentSemanticVersion = currentVersion.semanticVersion else {
			return .none
		}

		if currentSemanticVersion < minVersion {
			return .forceUpdate
		}

		if currentSemanticVersion < latestVersion {
			return .update
		}
		
		return .none
	}
}
