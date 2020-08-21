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

protocol DMStore: AnyObject {
	var dmLastSubmissionRequest: Data? { get set }
	var dmErrorMessages: [String] { get set }
}

extension UserDefaults: DMStore {
	var dmLastSubmissionRequest: Data? {
		get {
			data(forKey: "dmLastSubmissionRequest")
		}
		set {
			set(newValue, forKey: "dmLastSubmissionRequest")
		}
	}
	var dmErrorMessages: [String] {
		get {
			(array(forKey: "dmErrorMessages") ?? []) as [String]
		}
		set {
			set(newValue, forKey: "dmErrorMessages")
		}
	}
}

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
		exposureManager: ExposureManager,
		developerStore: DMStore,
		exposureSubmissionService: ExposureSubmissionService
	) {
		self.client = client
		self.presentingViewController = presentingViewController
		self.store = store
		self.exposureManager = exposureManager
		self.developerStore = developerStore
		self.exposureSubmissionService = exposureSubmissionService
	}

	// MARK: Properties
	private let presentingViewController: UIViewController
	private let client: Client
	private let store: Store
	private let exposureManager: ExposureManager
	private let exposureSubmissionService: ExposureSubmissionService
	private let developerStore: DMStore

	// MARK: Interacting with the developer menu

	/// Enables the developer menu if it is currently allowed to do so.
	///
	/// Whether or not the developer menu is allowed is determined at build time by looking at the active build configuration. It is only allowed for `RELEASE` and `DEBUG` builds. Builds that target the app store (configuration `APP_STORE`) are built without support for a developer menu.
	func enableIfAllowed() {
		guard isAllowed() else {
			return
		}
		let showDeveloperMenuGesture = UITapGestureRecognizer(target: self, action: #selector(_showDeveloperMenu(_:)))
		showDeveloperMenuGesture.numberOfTapsRequired = 3
		presentingViewController.view.addGestureRecognizer(showDeveloperMenuGesture)
	}

	@objc
	private func _showDeveloperMenu(_: UITapGestureRecognizer) {
		showDeveloperMenu()
	}

	 func showDeveloperMenu() {
		let vc = DMViewController(
			client: client,
			exposureSubmissionService: exposureSubmissionService
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
