//
// Corona-Warn-App
//
// SAP SE and all other contributors
// copyright owners license this file to you under the Apache
// License, Version 2.0 (the "License"); you may not use this
// file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.
//

import Foundation
import UIKit

enum UpdateAlertType {
	case none
	case update
	case forceUpdate
}

final class AppUpdateCheckHelper {
	// MARK: Properties
	private let client: Client
	private let store: Store

	/// The retained `NotificationCenter` observer that listens for `UIApplication.didBecomeActiveNotification` notifications.
	var applicationDidBecomeActiveObserver: NSObjectProtocol?

	init(client: Client, store: Store) {
		self.client = client
		self.store = store
	}

	// MARK: Deinit
	deinit {
		removeObserver()
	}

	func checkAppVersionDialog(for vc: UIViewController?) {
		client.appConfiguration { result in
			guard let versionInfo: SAP_ApplicationVersionConfiguration = result?.appVersion else {
				return
			}
			guard let appVersion: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
				return
			}

			let alertType = self.alertTypeFrom(
				currentVersion: appVersion,
				minVersion: versionInfo.ios.min,
				latestVersion: versionInfo.ios.latest
			)

			guard let alert = self.createAlert(alertType, vc: vc) else { return }
			vc?.present(alert, animated: true, completion: nil)
		}
	}

	private func setObserver(vc: UIViewController?, alertType: UpdateAlertType) {
		guard applicationDidBecomeActiveObserver == nil else { return }
		applicationDidBecomeActiveObserver = NotificationCenter.default.addObserver(forName: UIScene.didActivateNotification, object: nil, queue: nil) { [weak self] _ in
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
				//Do nothing
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
		minVersion: SAP_SemanticVersion,
		latestVersion: SAP_SemanticVersion
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
