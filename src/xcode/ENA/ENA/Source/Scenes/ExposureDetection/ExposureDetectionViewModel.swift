//
// 🦠 Corona-Warn-App
//

import ExposureNotification
import Foundation
import UIKit
import OpenCombine

// swiftlint:disable file_length
// swiftlint:disable:next type_body_length
class ExposureDetectionViewModel: CountdownTimerDelegate {

	// MARK: - Init

	init(
		homeState: HomeState,
		onInactiveButtonTap: @escaping (@escaping (ExposureNotificationError?) -> Void) -> Void
	) {
		self.homeState = homeState
		self.onInactiveButtonTap = onInactiveButtonTap

		homeState.$riskState
			.sink { [weak self] in
				self?.scheduleCountdownTimer()
				self?.setup(for: $0)
			}
			.store(in: &subscriptions)

		homeState.$riskProviderActivityState
			.sink { [weak self] in
				self?.riskProviderActivityState = $0

				switch $0 {
				case .downloading:
					self?.setupForDownloadingState()
				case .detecting:
					self?.setupForDetectingState()
				default:
					break
				}
			}
			.store(in: &subscriptions)

		homeState.$detectionMode
			.sink { [weak self] detectionMode in
				self?.scheduleCountdownTimer()

				if case .risk = homeState.riskState {
					self?.isButtonHidden = detectionMode == .automatic
				}
			}
			.store(in: &subscriptions)

		homeState.$exposureDetectionInterval
			.sink { [weak self] _ in
				self?.scheduleCountdownTimer()
			}
			.store(in: &subscriptions)
	}

	// MARK: - Protocol CountdownTimerDelegate

	func countdownTimer(_ timer: CountdownTimer, didEnd done: Bool) {
		timeUntilUpdate = nil
		
		if case .risk = homeState.riskState, homeState.manualExposureDetectionState == .possible {
			buttonTitle = AppStrings.Home.riskCardUpdateButton
			isButtonEnabled = true
		}
	}

	func countdownTimer(_ timer: CountdownTimer, didUpdate time: String) {
		timeUntilUpdate = time

		if case .risk = homeState.riskState {
			buttonTitle = riskButtonTitle
		}
	}

	// MARK: - Internal

	enum CloseButtonStyle {
		case normal
		case contrast
	}

	@OpenCombine.Published var dynamicTableViewModel: DynamicTableViewModel = DynamicTableViewModel([])

	@OpenCombine.Published var titleText: String! = RiskLevel.low.text
	@OpenCombine.Published var titleTextAccessibilityColor: String? = RiskLevel.low.accessibilityRiskColor

	@OpenCombine.Published var riskBackgroundColor: UIColor! = RiskLevel.low.backgroundColor
	@OpenCombine.Published var titleTextColor: UIColor = .enaColor(for: .textContrast)
	@OpenCombine.Published var closeButtonStyle: CloseButtonStyle = .contrast

	@OpenCombine.Published var buttonTitle: String! = AppStrings.ExposureDetection.buttonRefresh
	@OpenCombine.Published var isButtonEnabled: Bool = false
	@OpenCombine.Published var isButtonHidden: Bool = true

	@OpenCombine.Published var exposureNotificationError: ExposureNotificationError?

	var previousRiskTitle: String {
		switch homeState.lastRiskCalculationResult?.riskLevel {
		case .low:
			return AppStrings.ExposureDetection.low
		case .high:
			return AppStrings.ExposureDetection.high
		case .none:
			return AppStrings.ExposureDetection.unknown
		}
	}

	var riskTintColor: UIColor {
		switch homeState.riskState {
		case .risk(let risk):
			return risk.level.tintColor
		case .inactive, .detectionFailed:
			return .enaColor(for: .riskNeutral)
		}
	}

	var riskContrastTintColor: UIColor {
		switch homeState.riskState {
		case .risk:
			return .enaColor(for: .textContrast)
		case .inactive, .detectionFailed:
			return .enaColor(for: .riskNeutral)
		}
	}

	var riskSeparatorColor: UIColor {
		switch homeState.riskState {
		case .risk:
			return .enaColor(for: .hairlineContrast)
		case .inactive, .detectionFailed:
			return .enaColor(for: .hairline)
		}
	}

	var riskDetails: Risk.Details? {
		if case .risk(let risk) = homeState.riskState {
			return risk.details
		}

		return nil
	}

	func onButtonTap() {
		switch homeState.riskState {
		case .inactive:
			onInactiveButtonTap { [weak self] error in
				self?.exposureNotificationError = error
			}
		case .risk, .detectionFailed:
			homeState.requestRisk(userInitiated: true)
		}
	}

	// MARK: - Private

	private let homeState: HomeState
	private let onInactiveButtonTap: (@escaping (ExposureNotificationError?) -> Void) -> Void

	private var countdownTimer: CountdownTimer?
	private var timeUntilUpdate: String?

	private var riskProviderActivityState: RiskProviderActivityState = .idle

	private var subscriptions = Set<AnyCancellable>()

	private var lastUpdateDateString: String {
		if let lastUpdateDate = homeState.lastRiskCalculationResult?.calculationDate {
			return Self.lastUpdateDateFormatter.string(from: lastUpdateDate)
		} else {
			return AppStrings.Home.riskCardNoDateTitle
		}
	}

	private var riskButtonTitle: String {
		if let timeUntilUpdate = timeUntilUpdate {
			return String(format: AppStrings.ExposureDetection.refreshIn, timeUntilUpdate)
		}

		if homeState.manualExposureDetectionState == .possible {
			return AppStrings.ExposureDetection.buttonRefresh
		}

		return String(format: AppStrings.Home.riskCardIntervalDisabledButtonTitle, "\(homeState.exposureDetectionInterval)")
	}

	private static let lastUpdateDateFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.doesRelativeDateFormatting = true
		dateFormatter.dateStyle = .short
		dateFormatter.timeStyle = .short
		return dateFormatter
	}()

	private func scheduleCountdownTimer() {
		guard homeState.detectionMode == .manual else { return }

		// Cleanup potentially existing countdown.
		countdownTimer?.invalidate()
		NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
		NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)

		// Schedule new countdown.
		NotificationCenter.default.addObserver(self, selector: #selector(invalidateCountdownTimer), name: UIApplication.didEnterBackgroundNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(refreshTimerAfterResumingFromBackground), name: UIApplication.didBecomeActiveNotification, object: nil)

		countdownTimer = CountdownTimer(countdownTo: homeState.nextExposureDetectionDate)
		countdownTimer?.delegate = self
		countdownTimer?.start()
	}

	@objc
	private func invalidateCountdownTimer() {
		countdownTimer?.invalidate()
	}

	@objc
	private func refreshTimerAfterResumingFromBackground() {
		scheduleCountdownTimer()
	}

	private func setup(for riskState: RiskState) {
		switch riskState {
		case .risk(let risk):
			setupForRiskState(risk: risk)
		case .inactive:
			setupForInactiveState()
		case .detectionFailed:
			setupForFailedState()
		}
	}

	private func setupForDownloadingState() {
		setupForLoadingState()

		titleText = AppStrings.ExposureDetection.riskCardStatusDownloadingTitle
	}

	private func setupForDetectingState() {
		setupForLoadingState()

		titleText = AppStrings.ExposureDetection.riskCardStatusDetectingTitle
	}

	private func setupForLoadingState() {
		// Update dynamic table view model with current risk state
		setup(for: homeState.riskState)

		titleTextAccessibilityColor = nil

		isButtonHidden = true
		isButtonEnabled = false
	}

	private func setupForRiskState(risk: Risk) {
		switch risk.level {
		case .low:
			dynamicTableViewModel = lowRiskModel(risk: risk)
		case .high:
			dynamicTableViewModel = highRiskModel(risk: risk)
		}

		titleText = risk.level.text
		titleTextAccessibilityColor = risk.level.accessibilityRiskColor

		riskBackgroundColor = risk.level.backgroundColor
		titleTextColor = .enaColor(for: .textContrast)
		closeButtonStyle = .contrast

		buttonTitle = riskButtonTitle
		isButtonHidden = homeState.detectionMode == .automatic
		isButtonEnabled = homeState.manualExposureDetectionState == .possible
	}

	private func setupForInactiveState() {
		dynamicTableViewModel = inactiveModel

		titleText = AppStrings.ExposureDetection.off
		titleTextAccessibilityColor = nil

		riskBackgroundColor = .enaColor(for: .background)
		titleTextColor = .enaColor(for: .textPrimary1)
		closeButtonStyle = .normal

		buttonTitle = AppStrings.Home.riskCardInactiveNoCalculationPossibleButton
		isButtonHidden = false
		isButtonEnabled = true
	}

	private func setupForFailedState() {
		dynamicTableViewModel = failureModel

		titleText = AppStrings.ExposureDetection.riskCardFailedCalculationTitle
		titleTextAccessibilityColor = nil

		riskBackgroundColor = .enaColor(for: .background)
		titleTextColor = .enaColor(for: .textPrimary1)
		closeButtonStyle = .normal

		buttonTitle = AppStrings.Home.riskCardFailedCalculationRestartButtonTitle
		isButtonHidden = false
		isButtonEnabled = true
	}

	// MARK: Dynamic Table View Models

	private var inactiveModel: DynamicTableViewModel {
		DynamicTableViewModel([
			riskDataSection(
				footer: .separator(color: .enaColor(for: .hairline), height: 1, insets: UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)),
				cells: [
					.riskText(text: AppStrings.ExposureDetection.offText),
					.riskLastRiskLevel(hasSeparator: false, text: AppStrings.ExposureDetection.lastRiskLevel, image: UIImage(named: "Icons_LetzteErmittlung-Light")),
					.riskRefreshed(text: AppStrings.ExposureDetection.refreshed, image: UIImage(named: "Icons_Aktualisiert"))
				]
			),
			riskLoadingSection,
			standardGuideSection,
			explanationSection(
				text: AppStrings.ExposureDetection.explanationTextOff,
				accessibilityIdentifier: AccessibilityIdentifiers.ExposureDetection.explanationTextOff)
		])
	}

	private var failureModel: DynamicTableViewModel {
		DynamicTableViewModel([
			riskDataSection(
				footer: .separator(color: .enaColor(for: .hairline), height: 1, insets: UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)),
				cells: [
					.riskText(text: AppStrings.ExposureDetection.riskCardFailedCalculationBody),
					.riskLastRiskLevel(hasSeparator: false, text: AppStrings.ExposureDetection.lastRiskLevel, image: UIImage(named: "Icons_LetzteErmittlung-Light")),
					.riskRefreshed(text: AppStrings.ExposureDetection.refreshed, image: UIImage(named: "Icons_Aktualisiert"))
				]
			),
			riskLoadingSection,
			standardGuideSection,
			explanationSection(
				text: AppStrings.ExposureDetection.explanationTextOff,
				accessibilityIdentifier: AccessibilityIdentifiers.ExposureDetection.explanationTextOff)
		])
	}

	private func lowRiskModel(risk: Risk) -> DynamicTableViewModel {
		let activeTracing = risk.details.activeTracing
		let numberOfExposures = risk.details.numberOfDaysWithRiskLevel
		let riskDataSectionWithExposure = riskDataSection(
		   footer: .riskTint(height: 16),
		   cells: [
			   .riskContacts(text: AppStrings.Home.riskCardLowNumberContactsItemTitle, image: UIImage(named: "Icons_KeineRisikoBegegnung")),
			   .riskLastExposure(text: numberOfExposures == 1 ?
								   AppStrings.ExposureDetection.lastExposureOneRiskDay :
								   AppStrings.ExposureDetection.lastExposure,
								 image: UIImage(named: "Icons_Calendar")),
			   .riskStored(activeTracing: activeTracing, imageName: "Icons_TracingCircle-Dark_Step %u"),
			   .riskRefreshed(text: AppStrings.ExposureDetection.refreshed, image: UIImage(named: "Icons_Aktualisiert"))
		   ]
		)
		let riskDataSectionWithoutExposure = riskDataSection(
		   footer: .riskTint(height: 16),
		   cells: [
			   .riskContacts(text: AppStrings.Home.riskCardLowNumberContactsItemTitle, image: UIImage(named: "Icons_KeineRisikoBegegnung")),
			   .riskStored(activeTracing: activeTracing, imageName: "Icons_TracingCircle-Dark_Step %u"),
			   .riskRefreshed(text: AppStrings.ExposureDetection.refreshed, image: UIImage(named: "Icons_Aktualisiert"))
		   ]
		)
		return DynamicTableViewModel([
			numberOfExposures > 0 ? riskDataSectionWithExposure : riskDataSectionWithoutExposure,
			riskLoadingSection,
			lowRiskExposureSection(
				numberOfExposures,
				accessibilityIdentifier: AccessibilityIdentifiers.ExposureDetection.lowRiskExposureSection
			),
			standardGuideSection,
			activeTracingSection(risk: risk, accessibilityIdentifier: AccessibilityIdentifiers.ExposureDetection.activeTracingSection),
			explanationSection(
				text: numberOfExposures > 0 ?
					AppStrings.ExposureDetection.explanationTextLowWithEncounter :
					AppStrings.ExposureDetection.explanationTextLowNoEncounter,
				numberOfExposures: numberOfExposures,
				accessibilityIdentifier: numberOfExposures > 0 ? AccessibilityIdentifiers.ExposureDetection.explanationTextLowWithEncounter :
					AccessibilityIdentifiers.ExposureDetection.explanationTextLowNoEncounter
			)
		])
	}

	private func highRiskModel(risk: Risk) -> DynamicTableViewModel {
		let activeTracing = risk.details.activeTracing
		let numberOfExposures = risk.details.numberOfDaysWithRiskLevel
		return DynamicTableViewModel([
			riskDataSection(
				footer: .riskTint(height: 16),
				cells: [
					.riskContacts(text: AppStrings.Home.riskCardHighNumberContactsItemTitle, image: UIImage(named: "Icons_RisikoBegegnung")),
					.riskLastExposure(text: numberOfExposures == 1 ?
										AppStrings.ExposureDetection.lastExposureOneRiskDay :
										AppStrings.ExposureDetection.lastExposure,
									  image: UIImage(named: "Icons_Calendar")),
					.riskStored(activeTracing: activeTracing, imageName: "Icons_TracingCircle-Dark_Step %u"),
					.riskRefreshed(text: AppStrings.ExposureDetection.refreshed, image: UIImage(named: "Icons_Aktualisiert"))
				]
			),
			riskLoadingSection,
			.section(
				header: .backgroundSpace(height: 16),
				cells: [
					.header(title: AppStrings.ExposureDetection.behaviorTitle, subtitle: AppStrings.ExposureDetection.behaviorSubtitle),
					.guide(text: AppStrings.ExposureDetection.guideHome, image: UIImage(named: "Icons - Home")),
					.guide(text: AppStrings.ExposureDetection.guideDistance, image: UIImage(named: "Icons - Abstand")),
					.guide(image: UIImage(named: "Icons - Hotline"), text: [
						AppStrings.ExposureDetection.guideHotline1,
						AppStrings.ExposureDetection.guideHotline2,
						AppStrings.ExposureDetection.guideHotline3,
						AppStrings.ExposureDetection.guideHotline4
					])
				]
			),
			activeTracingSection(
				risk: risk,
				accessibilityIdentifier: AccessibilityIdentifiers.ExposureDetection.activeTracingSectionText
			),
			highRiskExplanationSection(
				risk: risk,
				mostRecentDateWithRiskLevelText: AppStrings.ExposureDetection.explanationTextHighDateOfLastExposure,
				explanationText: AppStrings.ExposureDetection.explanationTextHigh,
				isActive: true,
				accessibilityIdentifier: AccessibilityIdentifiers.ExposureDetection.explanationTextHigh
			)
		])
	}

	// MARK: Sections

	private func riskDataSection(
		footer: DynamicHeader,
		cells: [DynamicCell]
	) -> DynamicSection {
		.section(
			header: .none,
			footer: footer,
			isHidden: { (($0 as? ExposureDetectionViewController)?.viewModel.riskProviderActivityState.isActive ?? false) },
			cells: cells
		)
	}

	private var riskLoadingSection: DynamicSection {
		var riskLoadingText = ""
		switch riskProviderActivityState {
		case .detecting:
			riskLoadingText = AppStrings.ExposureDetection.riskCardStatusDetectingBody
		case .downloading:
			riskLoadingText = AppStrings.ExposureDetection.riskCardStatusDownloadingBody
		default:
			break
		}

		return DynamicSection.section(
			header: .none,
			footer: .none,
			isHidden: { !(($0 as? ExposureDetectionViewController)?.viewModel.riskProviderActivityState.isActive ?? false) },
			cells: [
				.riskLoading(text: riskLoadingText)
			]
		)
	}

	private var standardGuideSection: DynamicSection {
		.section(
			header: .backgroundSpace(height: 16),
			cells: [
				.header(title: AppStrings.ExposureDetection.behaviorTitle, subtitle: AppStrings.ExposureDetection.behaviorSubtitle),
				.guide(text: AppStrings.ExposureDetection.guideHands, image: UIImage(named: "Icons - Hands")),
				.guide(text: AppStrings.ExposureDetection.guideMask, image: UIImage(named: "Icons - Mundschutz")),
				.guide(text: AppStrings.ExposureDetection.guideDistance, image: UIImage(named: "Icons - Abstand")),
				.guide(text: AppStrings.ExposureDetection.guideSneeze, image: UIImage(named: "Icons - Niesen"))
			]
		)
	}

	/// - NOTE: This section should only be displayed when more than 0 exposures occured.
	private func lowRiskExposureSection(_ numberOfExposures: Int, accessibilityIdentifier: String?) -> DynamicSection {
		guard numberOfExposures > 0 else { return .section(cells: []) }

		return .section(
			header: .backgroundSpace(height: 8),
			footer: .backgroundSpace(height: 16),
			cells: [
				.header(
					title: AppStrings.ExposureDetection.lowRiskExposureTitle,
					subtitle: AppStrings.ExposureDetection.lowRiskExposureSubtitle
				),
				.body(
					text: AppStrings.ExposureDetection.lowRiskExposureBody,
					accessibilityIdentifier: accessibilityIdentifier
				)
			]
		)
	}

	private func activeTracingSection(risk: Risk, accessibilityIdentifier: String?) -> DynamicSection {
		let p0 = NSLocalizedString(
			"ExposureDetection_ActiveTracingSection_Text_Paragraph0",
			comment: ""
		)

		let p1 = risk.details.activeTracing.exposureDetectionActiveTracingSectionTextParagraph1

		let body = [p0, p1].joined(separator: "\n\n")

		return .section(
			header: .backgroundSpace(height: 8),
			footer: .backgroundSpace(height: 16),
			cells: [
				.header(
					title: NSLocalizedString(
						"ExposureDetection_ActiveTracingSection_Title",
						comment: ""
					),
					subtitle: NSLocalizedString(
						"ExposureDetection_ActiveTracingSection_Subtitle",
						comment: ""
					)
				),
				.body(
					text: body,
					accessibilityIdentifier: accessibilityIdentifier
				)
			]
		)
	}

	private func explanationSection(text: String, numberOfExposures: Int = -1, accessibilityIdentifier: String?) -> DynamicSection {
		return .section(
			header: .backgroundSpace(height: 8),
			footer: .backgroundSpace(height: 16),
			cells: [
				.header(
					title: AppStrings.ExposureDetection.explanationTitle,
					subtitle: AppStrings.ExposureDetection.explanationSubtitle
				),
				.body(text: text, accessibilityIdentifier: accessibilityIdentifier),
				infectionRiskExplanationFAQLink(numberOfExposures)
			].compactMap { $0 }
		)
	}

	/// - NOTE: This cell should only be displayed when more than 0 exposures occured.
	private func infectionRiskExplanationFAQLink(_ numberOfExposures: Int) -> DynamicCell? {
		guard numberOfExposures > 0 else { return nil }
		return .link(
			text: AppStrings.ExposureDetection.explanationFAQLinkText,
			url: URL(string: AppStrings.ExposureDetection.explanationFAQLink)
		)
	}

	private func highRiskExplanationSection(risk: Risk, mostRecentDateWithRiskLevelText: String, explanationText: String, isActive: Bool, accessibilityIdentifier: String?) -> DynamicSection {
		let dateFormatter = DateFormatter()
		dateFormatter.dateStyle = .medium

		guard let mostRecentDateWithHighRisk = risk.details.mostRecentDateWithRiskLevel else {
			assertionFailure("mostRecentDateWithRiskLevel must be set on high risk state")

			return .section(
				header: .backgroundSpace(height: 8),
				footer: .backgroundSpace(height: 16),
				cells: [
					.header(
						title: AppStrings.ExposureDetection.explanationTitle,
						subtitle: AppStrings.ExposureDetection.explanationSubtitle
					),
					.body(
						text: explanationText,
						accessibilityIdentifier: accessibilityIdentifier)
				]
			)
		}

		let formattedMostRecentDateWithHighRisk = dateFormatter.string(from: mostRecentDateWithHighRisk)
		return .section(
			header: .backgroundSpace(height: 8),
			footer: .backgroundSpace(height: 16),
			cells: [
				.header(
					title: AppStrings.ExposureDetection.explanationTitle,
					subtitle: AppStrings.ExposureDetection.explanationSubtitle
				),
				.body(
					text: [
						.localizedStringWithFormat(mostRecentDateWithRiskLevelText, formattedMostRecentDateWithHighRisk),
						explanationText
					].joined(separator: " "),
					accessibilityIdentifier: accessibilityIdentifier)
			]
		)
	}

}

extension RiskLevel {

	var text: String {
		switch self {
		case .low: return AppStrings.ExposureDetection.low
		case .high: return AppStrings.ExposureDetection.high
		}
	}

	var accessibilityRiskColor: String {
		switch self {
		case .low: return AppStrings.ExposureDetection.lowColorName
		case .high: return AppStrings.ExposureDetection.highColorName
		}
	}

	var backgroundColor: UIColor {
		switch self {
		case .low: return .enaColor(for: .riskLow)
		case .high: return .enaColor(for: .riskHigh)
		}
	}

	var tintColor: UIColor {
		switch self {
		case .low: return .enaColor(for: .riskLow)
		case .high: return .enaColor(for: .riskHigh)
		}
	}

}
