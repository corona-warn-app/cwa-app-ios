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
import ExposureNotification

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

extension OnboardingInfoViewController: RequiresAppDependencies {

}

final class OnboardingInfoViewController: UIViewController {
	// MARK: Creating a Onboarding View Controller

	init?(
		coder: NSCoder,
		pageType: OnboardingPageType,
		exposureManager: ExposureManager,
		store: Store
	) {
		self.pageType = pageType
		self.exposureManager = exposureManager
		self.store = store
		super.init(coder: coder)
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has intentionally not been implemented")
	}

	// MARK: Properties

	var pageType: OnboardingPageType
	var exposureManager: ExposureManager
	var store: Store

	@IBOutlet var imageView: UIImageView!
	@IBOutlet var stateHeaderLabel: ENALabel!
	@IBOutlet var stateTitleLabel: ENALabel!
	@IBOutlet var stateStateLabel: ENALabel!
	@IBOutlet var titleLabel: UILabel!
	@IBOutlet var boldLabel: UILabel!
	@IBOutlet var textLabel: UILabel!
	@IBOutlet var nextButton: ENAButton!
	@IBOutlet var ignoreButton: ENAButton!

	@IBOutlet var scrollView: UIScrollView!
	@IBOutlet var stackView: UIStackView!
	@IBOutlet var stateView: UIView!
	@IBOutlet var innerStackView: UIStackView!
	@IBOutlet var footerView: UIView!

	private var onboardingInfos = OnboardingInfo.testData()
	private var exposureManagerActivated = false
	var htmlTextView: HtmlTextView?

	var onboardingInfo: OnboardingInfo?

	override func viewDidLoad() {
		super.viewDidLoad()
		onboardingInfo = onboardingInfos[pageType.rawValue]
		// should be revised in the future
		viewRespectsSystemMinimumLayoutMargins = false
		view.layoutMargins = .zero
		setupAccessibility()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		let preconditions = exposureManager.preconditions()
		updateUI(exposureManagerState: preconditions)
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		scrollView.contentInset.bottom = footerView.frame.height - scrollView.safeAreaInsets.bottom
		scrollView.verticalScrollIndicatorInsets.bottom = scrollView.contentInset.bottom
	}

	func runActionForPageType(completion: @escaping () -> Void) {
		switch pageType {
		case .privacyPage:
			persistTimestamp(completion: completion)
		case .enableLoggingOfContactsPage:
			func handleBluetooth(completion: @escaping () -> Void) {
				if let alertController = self.exposureManager.alertForBluetoothOff(completion: { completion() }) {
					self.present(alertController, animated: true)
				}
				completion()
			}
			askExposureNotificationsPermissions(completion: {
				handleBluetooth {
					completion()
				}
			})

		case .alwaysStayInformedPage:
			askLocalNotificationsPermissions(completion: completion)
		default:
			completion()
		}
	}

	func runIgnoreActionForPageType(completion: @escaping () -> Void) {
		guard pageType == .enableLoggingOfContactsPage, !exposureManager.preconditions().authorized else {
			completion()
			return
		}

		let alert = OnboardingInfoViewControllerUtils.setupExposureConfirmationAlert {
			completion()
		}
		present(alert, animated: true, completion: nil)
	}

	private func updateUI(exposureManagerState: ExposureManagerState) {
		guard isViewLoaded else { return }
		guard let onboardingInfo = onboardingInfo else { return }

		titleLabel.text = onboardingInfo.title

		let exposureNotificationsNotSet = exposureManagerState.status == .unknown || exposureManagerState.status == .bluetoothOff
		let exposureNotificationsEnabled = exposureManagerState.enabled
		let exposureNotificationsDisabled = !exposureNotificationsEnabled && !exposureNotificationsNotSet
		let showStateView = onboardingInfo.showState && !exposureNotificationsNotSet

		// swiftlint:disable force_unwrapping
		let imageName = exposureNotificationsDisabled && onboardingInfo.alternativeImageName != nil ? onboardingInfo.alternativeImageName! : onboardingInfo.imageName
		imageView.image = UIImage(named: imageName)

		boldLabel.text = onboardingInfo.boldText
		boldLabel.isHidden = onboardingInfo.boldText.isEmpty

		textLabel.text = onboardingInfo.text
		textLabel.isHidden = onboardingInfo.text.isEmpty

		nextButton.setTitle(onboardingInfo.actionText, for: .normal)
		nextButton.isHidden = onboardingInfo.actionText.isEmpty

		ignoreButton.setTitle(onboardingInfo.ignoreText, for: .normal)
		ignoreButton.isHidden = onboardingInfo.ignoreText.isEmpty || showStateView

		stateView.isHidden = !showStateView

		stateHeaderLabel.text = onboardingInfo.stateHeader?.uppercased()
		stateTitleLabel.text = onboardingInfo.stateTitle
		stateStateLabel.text = exposureNotificationsEnabled ? onboardingInfo.stateActivated : onboardingInfo.stateDeactivated

		switch pageType {
		case .enableLoggingOfContactsPage:
			addPanel(
				title: AppStrings.Onboarding.onboardingInfo_enableLoggingOfContactsPage_panelTitle,
				body: AppStrings.Onboarding.onboardingInfo_enableLoggingOfContactsPage_panelBody
			)
		case .privacyPage:
			innerStackView.isHidden = true
			let textView = HtmlTextView()
			textView.layoutMargins = .zero
			textView.delegate = self
			if let url = Bundle.main.url(forResource: "privacy-policy", withExtension: "html") {
				textView.load(from: url)
			}
			stackView.addArrangedSubview(textView)
			htmlTextView = textView
			addSkipAccessibilityActionToHeader()
		default:
			break
		}

	}

	func setupAccessibility() {
		imageView.isAccessibilityElement = true
		titleLabel.isAccessibilityElement = true
		boldLabel.isAccessibilityElement = true
		textLabel.isAccessibilityElement = true
		nextButton.isAccessibilityElement = true
		ignoreButton.isAccessibilityElement = true

		imageView.accessibilityLabel = onboardingInfo?.imageDescription

		titleLabel.accessibilityIdentifier = onboardingInfo?.titleAccessibilityIdentifier
		imageView.accessibilityIdentifier = onboardingInfo?.imageAccessibilityIdentifier
		nextButton.accessibilityIdentifier = onboardingInfo?.actionTextAccessibilityIdentifier
		ignoreButton.accessibilityIdentifier = onboardingInfo?.ignoreTextAccessibilityIdentifier

		titleLabel.accessibilityTraits = .header
	}

	func addSkipAccessibilityActionToHeader() {
		titleLabel.accessibilityHint = AppStrings.Onboarding.onboardingContinueDescription
		let actionName = AppStrings.Onboarding.onboardingContinue
		let skipAction = UIAccessibilityCustomAction(name: actionName, target: self, selector: #selector(skip(_:)))
		titleLabel.accessibilityCustomActions = [skipAction]
		htmlTextView?.accessibilityCustomActions = [skipAction]
	}

	@objc
	func skip(_ sender: Any) {
		didTapNextButton(sender)
	}

	private func persistTimestamp(completion: (() -> Void)?) {
		if let acceptedDate = store.dateOfAcceptedPrivacyNotice {
			log(message: "User has already accepted the privacy terms on \(acceptedDate)", level: .warning)
			completion?()
			return
		}
		store.dateOfAcceptedPrivacyNotice = Date()
		log(message: "Persist that user accepted the privacy terms on \(Date())", level: .info)
		completion?()
	}

	// MARK: Exposure notifications

	private func askExposureNotificationsPermissions(completion: (() -> Void)?) {
		if exposureManager is MockExposureManager {
			completion?()
			return
		}

		func persistForDPP(accepted: Bool) {
			self.store.exposureActivationConsentAccept = accepted
			self.store.exposureActivationConsentAcceptTimestamp = Int64(Date().timeIntervalSince1970)
		}

		func shouldHandleError(_ error: ExposureNotificationError?) -> Bool {
			switch error {
			case .exposureNotificationRequired:
				log(message: "Encourage the user to consider enabling Exposure Notifications.", level: .warning)
			case .exposureNotificationAuthorization:
				log(message: "Encourage the user to authorize this application", level: .warning)
			case .exposureNotificationUnavailable:
				log(message: "Tell the user that Exposure Notifications is currently not available.", level: .warning)
			case .apiMisuse:
				// User already enabled notifications, but went back to the previous screen. Just ignore error and proceed
				return false
			default:
				break
			}
			return true
		}

		guard !exposureManagerActivated else {
			completion?()
			return
		}

		exposureManager.activate { error in
			if let error = error {
				guard shouldHandleError(error) else {
					completion?()
					return
				}
				self.showError(error, from: self, completion: completion)
				persistForDPP(accepted: false)
				completion?()
			} else {
				self.exposureManagerActivated = true
				self.exposureManager.enable { enableError in
					if let enableError = enableError {
						guard shouldHandleError(enableError) else {
							completion?()
							return
						}
						persistForDPP(accepted: false)
					} else {
						persistForDPP(accepted: true)
					}
					completion?()
				}
			}
		}
	}

	private func askLocalNotificationsPermissions(completion: (() -> Void)?) {
		exposureManager.requestUserNotificationsPermissions {
			completion?()
			return
		}
	}

	func openSettings() {
		guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
		UIApplication.shared.open(url, options: [:], completionHandler: nil)
	}

	func showError(_ error: ExposureNotificationError, from viewController: UIViewController, completion: (() -> Void)?) {
		let alert = UIAlertController(title: AppStrings.ExposureSubmission.generalErrorTitle, message: String(describing: error), preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: AppStrings.Common.alertActionOk, style: .cancel))
		viewController.present(alert, animated: true, completion: completion)
	}

	@IBAction func didTapNextButton(_: Any) {
		nextButton.isUserInteractionEnabled = false
		runActionForPageType(
			completion: { [weak self] in
				self?.gotoNextScreen()
				self?.nextButton.isUserInteractionEnabled = true
			}
		)
	}

	@IBAction func didTapIgnoreButton(_: Any) {
		runIgnoreActionForPageType(
			completion: {
				self.gotoNextScreen()
			}
		)
	}

	func gotoNextScreen() {

		guard let nextPageType = pageType.next() else {
			finishOnBoarding()
			return
		}

		let storyboard = AppStoryboard.onboarding.instance
		let next = storyboard.instantiateInitialViewController { [unowned self] coder in
			OnboardingInfoViewController(
				coder: coder,
				pageType: nextPageType,
				exposureManager: self.exposureManager,
				store: self.store
			)
		}
		// swiftlint:disable:next force_unwrapping
		navigationController?.pushViewController(next!, animated: true)
	}


	private func finishOnBoarding() {
		store.isOnboarded = true
		NotificationCenter.default.post(name: .isOnboardedDidChange, object: nil)
	}

}

extension OnboardingInfoViewController: UITextViewDelegate {
	func textView(_ textView: UITextView, shouldInteractWith url: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
		LinkHelper.openLink(withUrl: url, from: self)
		return false
	}
}

extension OnboardingInfoViewController: NavigationBarOpacityDelegate {
	var preferredNavigationBarOpacity: CGFloat {
		let alpha = (scrollView.adjustedContentInset.top + scrollView.contentOffset.y) / scrollView.adjustedContentInset.top
		return max(0, min(alpha, 1))
	}
}
