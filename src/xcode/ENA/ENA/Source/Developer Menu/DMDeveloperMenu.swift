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

#if !RELEASE
import UIKit

/// If enabled, the developer can be revealed by tripple-tapping anywhere within the `presentingViewController`.
final class DMDeveloperMenu {
	// MARK: Creating a developer menu

	/// Parameters:
	/// - presentingViewController: The instance of `UIViewController` which should receive a developer menu.
	/// - client: The `Client` to use.
	/// - store: The `Store` is used to retrieve debug information.
	init(
		presentingViewController: UIViewController,
		client: Client,
		store: Store,
		exposureManager: ExposureManager
	) {
		self.client = client
		self.presentingViewController = presentingViewController
		self.store = store
		self.exposureManager = exposureManager
	}

	// MARK: Properties

	private let presentingViewController: UIViewController
	private let client: Client
	private let store: Store
	private let exposureManager: ExposureManager

	// MARK: Interacting with the developer menu

	/// Enables the developer menu if it is currently allowed to do so.
	///
	/// Whether or not the developer menu is allowed is determined at build time by looking at the active build configuration. It is only allowed for `RELEASE` and `DEBUG` builds. Builds that target the app store (configuration `APP_STORE`) are built without support for a developer menu.
	func enableIfAllowed() {
		guard isAllowed() else {
			return
		}
		let showDeveloperMenuGesture = UITapGestureRecognizer(target: self, action: #selector(showDeveloperMenu(_:)))
		showDeveloperMenuGesture.numberOfTapsRequired = 3
		presentingViewController.view.addGestureRecognizer(showDeveloperMenuGesture)
	}

	@objc
	func showDeveloperMenu(_: UITapGestureRecognizer) {
		let vc = DMViewController(
			client: client,
			store: store,
			exposureManager: exposureManager
		)
		let navigationController = UINavigationController(
			rootViewController: vc
		)
		presentingViewController.present(
			navigationController,
			animated: true,
			completion: nil
		)
	}

	private func isAllowed() -> Bool {
		true
	}
}
#endif
