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

import UIKit
import UserNotifications

enum OnboardingPageType: Int, CaseIterable {
	case togetherAgainstCoronaPage = 0
	case privacyPage = 1
	case enableLoggingOfContactsPage = 2
	case howDoesDataExchangeWorkPage = 3
	case alwaysStayInformedPage = 4

	func next() -> OnboardingPageType? {
		OnboardingPageType(rawValue: rawValue + 1)
	}

	func isLast() -> Bool {
		(self == OnboardingPageType.allCases.last)
	}
}

final class OnboardingInfoViewController: UIViewController {
	// MARK: Creating a Onboarding View Controller

	init?(
		coder: NSCoder,
		pageType: OnboardingPageType,
		exposureManager: ExposureManager,
		taskScheduler: ENATaskScheduler,
		store: Store
	) {
		self.pageType = pageType
		self.exposureManager = exposureManager
		self.taskScheduler = taskScheduler
		self.store = store
		super.init(coder: coder)
	}

	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has intentionally not been implemented")
	}

	// MARK: Properties

	var pageType: OnboardingPageType
	var exposureManager: ExposureManager
	var taskScheduler: ENATaskScheduler
	var store: Store
	@IBOutlet var imageView: UIImageView!
	@IBOutlet var titleLabel: UILabel!
	@IBOutlet var boldLabel: UILabel!
	@IBOutlet var textLabel: UILabel!
	@IBOutlet var nextButton: ENAButton!
	@IBOutlet var ignoreButton: UIButton!

	@IBOutlet var scrollView: UIScrollView!
	@IBOutlet var footerView: UIView!

	private var onboardingInfos = OnboardingInfo.testData()

	var onboardingInfo: OnboardingInfo?

	private let notificationCenter = UNUserNotificationCenter.current()

	override func viewDidLoad() {
		super.viewDidLoad()
		onboardingInfo = onboardingInfos[pageType.rawValue]
		// should be revised in the future
		viewRespectsSystemMinimumLayoutMargins = false
		view.layoutMargins = .zero
		updateUI()
		setupAccessibility()
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		let height = footerView.frame.height + 20
		scrollView.contentInset.bottom = height
	}

	func runActionForPageType(completion: @escaping () -> Void) {
		switch pageType {
		case .privacyPage:
			persistTimestamp(completion: completion)
		case .enableLoggingOfContactsPage:
			askExposureNotificationsPermissions(completion: completion)
		case .alwaysStayInformedPage:
			askLocalNotificationsPermissions(completion: completion)
		default:
			completion()
		}
	}

	private func updateUI() {
		guard isViewLoaded else { return }
		guard let onboardingInfo = onboardingInfo else { return }

		titleLabel.text = onboardingInfo.title

		imageView.image = UIImage(named: onboardingInfo.imageName)

		boldLabel.text = onboardingInfo.boldText
		boldLabel.isHidden = onboardingInfo.boldText.isEmpty

		textLabel.text = onboardingInfo.text
		textLabel.isHidden = onboardingInfo.text.isEmpty

		nextButton.setTitle(onboardingInfo.actionText, for: .normal)
		nextButton.isHidden = onboardingInfo.actionText.isEmpty

		ignoreButton.setTitle(onboardingInfo.ignoreText, for: .normal)
		ignoreButton.setTitleColor(UIColor.preferredColor(for: .tint), for: .normal)
		ignoreButton.backgroundColor = UIColor.clear
		ignoreButton.isHidden = onboardingInfo.ignoreText.isEmpty

		titleLabel.font = UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .title1).pointSize)
		boldLabel.font = UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
		textLabel.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
	}

	func setupAccessibility() {
		imageView.isAccessibilityElement = false
		titleLabel.isAccessibilityElement = true
		boldLabel.isAccessibilityElement = true
		textLabel.isAccessibilityElement = true
		nextButton.isAccessibilityElement = true
		ignoreButton.isAccessibilityElement = true

		titleLabel.accessibilityIdentifier = Accessibility.StaticText.onboardingTitle
		nextButton.accessibilityIdentifier = Accessibility.Button.next
		ignoreButton.accessibilityIdentifier = Accessibility.Button.ignore
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		if previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory {
			// content size has changed
			titleLabel.font = UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .title1).pointSize)
			boldLabel.font = UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
			textLabel.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize)
		}
	}

	private func persistTimestamp(completion: (() -> Void)?) {
		if let acceptedDate = store.dateOfAcceptedPrivacyNotice {
			appLogger.warning(message: "User has already accepted the privacy terms on \(acceptedDate)")
			completion?()
			return
		}
		store.dateOfAcceptedPrivacyNotice = Date()
		appLogger.info(message: "Persist that user acccepted the privacy terms on \(Date())")
		completion?()
	}

	// MARK: Exposure notifications

	private func askExposureNotificationsPermissions(completion: (() -> Void)?) {
		if TestEnvironment.shared.isUITesting {
			completion?()
			return
		}

		exposureManager.activate { error in
			if let error = error {
				switch error {
				case .exposureNotificationRequired:
					appLogger.warning(message: "Encourage the user to consider enabling Exposure Notifications.")
				case .exposureNotificationAuthorization:
					appLogger.warning(message: "Encourage the user to authorize this application")
				case .exposureNotificationUnavailable:
					appLogger.warning(message: "Tell the user that Exposure Notifications is currently not available.")
				}
				self.showError(error, from: self, completion: completion)
				completion?()
			} else {
				self.exposureManager.enable { enableError in
					if let enableError = enableError {
						switch enableError {
						case .exposureNotificationRequired:
							appLogger.warning(message: "Encourage the user to consider enabling Exposure Notifications.")
						case .exposureNotificationAuthorization:
							appLogger.warning(message: "Encourage the user to authorize this application")
						case .exposureNotificationUnavailable:
							appLogger.warning(message: "Tell the user that Exposure Notifications is currently not available.")
						}
					}
					self.taskScheduler.scheduleBackgroundTaskRequests()
					completion?()
				}
			}
		}
	}

	private func askLocalNotificationsPermissions(completion: (() -> Void)?) {
		if TestEnvironment.shared.isUITesting {
			completion?()
			return
		}

		let options: UNAuthorizationOptions = [.alert, .sound, .badge]
		notificationCenter.requestAuthorization(options: options) { _, error in
			if let error = error {
				// handle error
				appLogger.error(message: "Notification authorization request error: \(error.localizedDescription)")
			}
			DispatchQueue.main.async {
				completion?()
			}
		}
	}

	func openSettings() {
		guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
		UIApplication.shared.open(url, options: [:], completionHandler: nil)
	}

	func showError(_ error: ExposureNotificationError, from viewController: UIViewController, completion: (() -> Void)?) {
		let alert = UIAlertController(title: "Error", message: String(describing: error), preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: .cancel))
		viewController.present(alert, animated: true, completion: completion)
	}

	@IBAction func didTapNextButton(_: Any) {
		runActionForPageType(
			completion: {
				self.gotoNextScreen()
			}
		)
	}

	@IBAction func didTapIgnoreButton(_: Any) {
		gotoNextScreen()
	}

	func gotoNextScreen() {
		guard let nextPageType = pageType.next() else {
			store.isOnboarded = true
			return
		}
		let storyboard = AppStoryboard.onboarding.instance
		let next = storyboard.instantiateInitialViewController { [unowned self] coder in
			OnboardingInfoViewController(
				coder: coder,
				pageType: nextPageType,
				exposureManager: self.exposureManager,
				taskScheduler: self.taskScheduler,
				store: self.store
			)
		}
		// swiftlint:disable:next force_unwrapping
		navigationController?.pushViewController(next!, animated: true)
	}
}
