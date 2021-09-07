//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine
import UserNotifications
import ExposureNotification
import WebKit

// swiftlint:disable:next type_body_length
final class OnboardingInfoViewController: UIViewController {

	@IBOutlet var scrollView: UIScrollView!
	@IBOutlet var containerView: UIView!
	@IBOutlet var stackView: UIStackView!
	
	// MARK: - Init
	
	init(
		pageType: OnboardingPageType,
		exposureManager: ExposureManager,
		store: Store,
		client: Client,
		supportedCountries: [Country]? = nil
	) {
		self.pageType = pageType
		self.exposureManager = exposureManager
		self.store = store
		self.client = client
		self.supportedCountries = supportedCountries
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has intentionally not been implemented")
	}

	// MARK: - Overrides
	
	override func viewDidLoad() {
		super.viewDidLoad()
		onboardingInfo = onboardingInfos[pageType.rawValue]
		pageSetupDone = false
		// should be revised in the future
		viewRespectsSystemMinimumLayoutMargins = false
		view.layoutMargins = .zero
		setupAccessibility()
		setupNavigationBar()
		if pageType == .togetherAgainstCoronaPage { loadCountryList() }
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		let preconditions = exposureManager.exposureManagerState
		updateUI(exposureManagerState: preconditions)
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		scrollView.contentInset.bottom = footerView.frame.height - scrollView.safeAreaInsets.bottom
		scrollView.verticalScrollIndicatorInsets.bottom = scrollView.contentInset.bottom
	}

	// MARK: - Private
	
	@IBOutlet private var imageView: UIImageView!
	@IBOutlet private var stateHeaderLabel: ENALabel!
	@IBOutlet private var stateTitleLabel: ENALabel!
	@IBOutlet private var stateStateLabel: ENALabel!
	@IBOutlet private var titleLabel: UILabel!
	@IBOutlet private var boldLabel: UILabel!
	@IBOutlet private var textLabel: UILabel!
	@IBOutlet private var linkTextView: UITextView!
	@IBOutlet private var nextButton: ENAButton!
	@IBOutlet private var ignoreButton: ENAButton!
	@IBOutlet private var stateView: UIView!
	@IBOutlet private var innerStackView: UIStackView!
	@IBOutlet private var footerView: UIView!

	private var pageType: OnboardingPageType
	private var exposureManager: ExposureManager
	private var store: Store
	private var webView: HTMLView?
	private var onboardingInfo: OnboardingInfo?
	private var supportedCountries: [Country]?
	private var client: Client
	private var pageSetupDone = false
	private var onboardingInfos = OnboardingInfo.testData()
	private var exposureManagerActivated = false
	private var subscriptions = [AnyCancellable]()

	@IBAction private func didTapNextButton(_: Any) {
		nextButton.isUserInteractionEnabled = false
		runActionForPageType(
			completion: { [weak self] in
				self?.gotoNextScreen()
				self?.nextButton.isUserInteractionEnabled = true
			}
		)
	}

	@IBAction private func didTapIgnoreButton(_: Any) {
		runIgnoreActionForPageType(
			completion: {
				self.gotoNextScreen()
			}
		)
	}

	private func setupNavigationBar() {
		navigationItem.largeTitleDisplayMode = .never
	}
	
	private func openSettings() {
		LinkHelper.open(urlString: UIApplication.openSettingsURLString)
	}

	private func showError(_ error: ExposureNotificationError, from viewController: UIViewController, completion: (() -> Void)?) {
		let alert = UIAlertController(title: AppStrings.ExposureSubmission.generalErrorTitle, message: String(describing: error), preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: AppStrings.Common.alertActionOk, style: .cancel))
		viewController.present(alert, animated: true, completion: completion)
	}

	private func gotoNextScreen() {
		guard let nextPageType = pageType.next() else {
			gotoDataDonationScreen()
			return
		}
		let next = OnboardingInfoViewController(
			pageType: nextPageType,
			exposureManager: self.exposureManager,
			store: self.store,
			client: client,
			supportedCountries: supportedCountries
		)
		navigationController?.pushViewController(next, animated: true)
	}
	
	private func gotoDataDonationScreen() {
		guard let jsonFileURL = Bundle.main.url(forResource: "ppdd-ppa-administrative-unit-set-ua-approved", withExtension: "json") else {
			preconditionFailure("missing json file")
		}

		let dataDonationViewModel = DefaultDataDonationViewModel(
			store: store,
			presentSelectValueList: { [weak self] selectValueViewModel in
				let selectValueViewController = SelectValueTableViewController(
					selectValueViewModel,
					dismiss: { [weak self] in
						self?.navigationController?.dismiss(animated: true)
					})
				let selectValueNavigationController = UINavigationController(rootViewController: selectValueViewController)
				self?.navigationController?.present(selectValueNavigationController, animated: true)
			},
			datadonationModel: DataDonationModel(
				store: store,
				jsonFileURL: jsonFileURL
			)
		)

		let dataDonationViewController = DataDonationViewController(viewModel: dataDonationViewModel)

		let containerViewController = TopBottomContainerViewController(
			topController: dataDonationViewController,
			bottomController: FooterViewController(
				FooterViewModel(
					primaryButtonName: AppStrings.DataDonation.Info.buttonOK,
					secondaryButtonName: AppStrings.DataDonation.Info.buttonNOK
				),
				didTapPrimaryButton: { [weak self] in
					dataDonationViewModel.save(consentGiven: true)
					self?.finishOnBoarding()
				},
				didTapSecondaryButton: { [weak self] in
					dataDonationViewModel.save(consentGiven: false)
					self?.finishOnBoarding()
				}
			)
		)
		
		navigationController?.pushViewController(containerViewController, animated: true)
	}

	private func loadCountryList() {
		// force loading app configuration regardless the cached state. If, for some
		// reason no app configuration is available, we'll use a minimal default config.
		appConfigurationProvider.appConfiguration(forceFetch: true).sink { [weak self] configuration in
			let supportedCountryIDs = configuration.supportedCountries

			let supportedCountries = supportedCountryIDs.compactMap { Country(countryCode: $0) }
			self?.supportedCountries = supportedCountries.sortedByLocalizedName
		}.store(in: &subscriptions)
	}

	private func updateUI(exposureManagerState: ExposureManagerState) {
		guard isViewLoaded else { return }
		guard let onboardingInfo = onboardingInfo else { return }

		titleLabel.text = onboardingInfo.title

		let exposureNotificationsNotSet = exposureManagerState.status == .unknown || exposureManagerState.status == .bluetoothOff
		let exposureNotificationsEnabled = exposureManagerState.enabled
		let exposureNotificationsDisabled = !exposureNotificationsEnabled && !exposureNotificationsNotSet
		// show state of "Expoure Logging" when it has been enabled by the user
		let showStateView = onboardingInfo.showState && !exposureNotificationsNotSet

		// swiftlint:disable force_unwrapping
		let imageName = exposureNotificationsDisabled && onboardingInfo.alternativeImageName != nil ? onboardingInfo.alternativeImageName! : onboardingInfo.imageName
		imageView.image = UIImage(named: imageName)

		boldLabel.text = onboardingInfo.boldText
		boldLabel.isHidden = onboardingInfo.boldText.isEmpty

		textLabel.text = onboardingInfo.text
		textLabel.isHidden = onboardingInfo.text.isEmpty

		if Bundle.main.preferredLocalizations.first == "de" {
			let textAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.preferredFont(forTextStyle: .body).scaledFont(size: 15, weight: .regular), .link: onboardingInfo.link]

			let attributedString = NSMutableAttributedString(string: onboardingInfo.linkDisplayText, attributes: textAttributes)

			linkTextView.attributedText = attributedString
			linkTextView.dataDetectorTypes = UIDataDetectorTypes.all
			linkTextView.isScrollEnabled = false
			linkTextView.isHidden = onboardingInfo.link.isEmpty
			linkTextView.isUserInteractionEnabled = true
			linkTextView.adjustsFontForContentSizeCategory = true
			linkTextView.textContainerInset = .zero
			linkTextView.textContainer.lineFragmentPadding = .zero
			linkTextView.backgroundColor = .clear
			linkTextView.delegate = self
		} else {
			linkTextView.isHidden = true
		}

		if pageType == .enableLoggingOfContactsPage && showStateView {
			nextButton.setTitle(onboardingInfo.alternativeActionText, for: .normal)
		} else {
			nextButton.setTitle(onboardingInfo.actionText, for: .normal)
		}
		nextButton.isHidden = onboardingInfo.actionText.isEmpty

		ignoreButton.setTitle(onboardingInfo.ignoreText, for: .normal)
		ignoreButton.isHidden = onboardingInfo.ignoreText.isEmpty || showStateView

		stateView.isHidden = !showStateView

		stateHeaderLabel.text = onboardingInfo.stateHeader?.uppercased()
		stateTitleLabel.text = onboardingInfo.stateTitle
		stateStateLabel.text = exposureNotificationsEnabled ? onboardingInfo.stateActivated : onboardingInfo.stateDeactivated
		
		if pageSetupDone {
			return
		} else {
			setupPage()
		}
	}

	private func setupPage() {
		switch pageType {
		case .enableLoggingOfContactsPage:
			addParagraph(
				title: AppStrings.Onboarding.onboardingInfo_enableLoggingOfContactsPage_euTitle,
				body: AppStrings.Onboarding.onboardingInfo_enableLoggingOfContactsPage_euDescription
			)
			addCountrySection(title: AppStrings.Onboarding.onboardingInfo_ParticipatingCountries_Title, countries: supportedCountries ?? [])
			addPanel(
				title: AppStrings.Onboarding.onboardingInfo_enableLoggingOfContactsPage_consentUnderagesTitle,
				body: AppStrings.Onboarding.onboardingInfo_enableLoggingOfContactsPage_consentUnderagesText,
				textColor: .textContrast,
				bgColor: .riskNeutral
			)
			addPanel(
				title: AppStrings.Onboarding.onboardingInfo_enableLoggingOfContactsPage_panelTitle,
				body: AppStrings.Onboarding.onboardingInfo_enableLoggingOfContactsPage_panelBody
			)
		case .privacyPage:
			innerStackView.isHidden = true
			let htmlView = HTMLView()
			htmlView.translatesAutoresizingMaskIntoConstraints = false
			htmlView.navigationDelegate = self // used to size the webview after loading HTML
			if let url = Bundle.main.url(forResource: "privacy-policy", withExtension: "html") {
				htmlView.load(URLRequest(url: url))
			} else {
				Log.error("Could not load privacy-policy.html", log: .ui, error: nil)
			}
			containerView.addSubview(htmlView)
			webView = htmlView

			NSLayoutConstraint.activate([
				htmlView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 8),
				htmlView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
				htmlView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0),
				htmlView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16)
			])
			
			addSkipAccessibilityActionToHeader()
		default:
			break
		}
		pageSetupDone = true
	}
	
	private func persistTimestamp(completion: (() -> Void)?) {
		if let acceptedDate = store.dateOfAcceptedPrivacyNotice {
			Log.warning("User has already accepted the privacy terms on \(acceptedDate)", log: .localData)
			completion?()
			return
		}
		store.dateOfAcceptedPrivacyNotice = Date()
		Log.info("Persist that user accepted the privacy terms on \(Date())", log: .localData)
		completion?()
	}

	private func askExposureNotificationsPermissions(completion: (() -> Void)?) {
		#if DEBUG
		if exposureManager is MockExposureManager {
			completion?()
			return
		}
		#endif

		func persistForDPP(accepted: Bool) {
			self.store.exposureActivationConsentAccept = accepted
			self.store.exposureActivationConsentAcceptTimestamp = Int64(Date().timeIntervalSince1970)
		}

		func shouldHandleError(_ error: ExposureNotificationError?) -> Bool {
			switch error {
			case .exposureNotificationRequired:
				Log.warning("Encourage the user to consider enabling Exposure Notifications.", log: .api)
			case .exposureNotificationAuthorization:
				Log.warning("Encourage the user to authorize this application", log: .api)
			case .exposureNotificationUnavailable:
				Log.warning("Tell the user that Exposure Notifications is currently not available.", log: .api)
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

	private func finishOnBoarding() {
		store.isOnboarded = true
		store.onboardingVersion = Bundle.main.appVersion

		NotificationCenter.default.post(name: .isOnboardedDidChange, object: nil)
	}
	
	private func runActionForPageType(completion: @escaping () -> Void) {
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
	
	private func runIgnoreActionForPageType(completion: @escaping () -> Void) {
		guard pageType == .enableLoggingOfContactsPage, !exposureManager.exposureManagerState.authorized else {
			completion()
			return
		}

		let alert = OnboardingInfoViewControllerUtils.setupExposureConfirmationAlert {
			completion()
		}
		present(alert, animated: true, completion: nil)
	}
	
	private func setupAccessibility() {
		imageView.isAccessibilityElement = true
		imageView.accessibilityLabel = onboardingInfo?.imageDescription
		imageView.accessibilityIdentifier = onboardingInfo?.imageAccessibilityIdentifier
		titleLabel.isAccessibilityElement = true
		titleLabel.accessibilityIdentifier = onboardingInfo?.titleAccessibilityIdentifier
		titleLabel.accessibilityTraits = .header
		boldLabel.isAccessibilityElement = true
		textLabel.isAccessibilityElement = true
		linkTextView.isAccessibilityElement = true
		nextButton.isAccessibilityElement = true
		nextButton.accessibilityIdentifier = onboardingInfo?.actionTextAccessibilityIdentifier
		ignoreButton.accessibilityIdentifier = onboardingInfo?.ignoreTextAccessibilityIdentifier
		ignoreButton.isAccessibilityElement = true
	}

	private func addSkipAccessibilityActionToHeader() {
		titleLabel.accessibilityHint = AppStrings.Onboarding.onboardingContinueDescription
		let actionName = AppStrings.Onboarding.onboardingContinue
		let skipAction = UIAccessibilityCustomAction(name: actionName, target: self, selector: #selector(skip(_:)))
		titleLabel.accessibilityCustomActions = [skipAction]
		webView?.accessibilityCustomActions = [skipAction]
	}

	@objc
	private func skip(_ sender: Any) {
		didTapNextButton(sender)
	}
	
}

extension OnboardingInfoViewController: WKNavigationDelegate {

	func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
		webView.evaluateJavaScript("document.readyState", completionHandler: { complete, error in
			if complete != nil {
				self.webView?.evaluateJavaScript("document.body.scrollHeight", completionHandler: { [weak self] height, error in
					if let height = height as? CGFloat {
						Log.debug("Set content height to \(height) @\(UIScreen.main.scale)x")
						self?.webView?.heightAnchor.constraint(equalToConstant: height).isActive = true
						self?.webView?.sizeToFit()
					} else {
						Log.error("Could not get website height! \(error?.localizedDescription ?? "")", error: error)
					}
				})
			}
		})
	}

	func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
		if navigationAction.navigationType == .linkActivated, let url = navigationAction.request.url {
			LinkHelper.open(url: url)
			decisionHandler(.cancel)
		} else {
			decisionHandler(.allow)
		}
	}
}
