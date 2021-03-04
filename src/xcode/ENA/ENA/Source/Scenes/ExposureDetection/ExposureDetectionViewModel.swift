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
		appConfigurationProvider: AppConfigurationProviding,
		onSurveyTap: @escaping () -> Void,
		onInactiveButtonTap: @escaping (@escaping (ExposureNotificationError?) -> Void) -> Void
	) {
		self.homeState = homeState
		self.appConfigurationProvider = appConfigurationProvider
		self.onInactiveButtonTap = onInactiveButtonTap
		self.onSurveyTap = onSurveyTap

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

	let appConfigurationProvider: AppConfigurationProviding

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
	private let onSurveyTap: () -> Void

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
			appConfigurationProvider.appConfiguration()
				.sink { [weak self] in
					guard let self = self else {
						Log.debug("failed to get strong self")
						return
					}

					self.dynamicTableViewModel = self.highRiskModel(risk: risk, isSurveyEnabled: self.isSurveyEnabled($0))
				}
				.store(in: &subscriptions)
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

	private func isSurveyEnabled(_ appConfig: SAP_Internal_V2_ApplicationConfigurationIOS) -> Bool {
		let surveyParameters = appConfig.eventDrivenUserSurveyParameters.common
		return surveyParameters.surveyOnHighRiskEnabled && !surveyParameters.surveyOnHighRiskURL.isEmpty
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
		let numberOfExposures = risk.details.numberOfDaysWithRiskLevel

		var riskDataSectionCells = [DynamicCell]()

		riskDataSectionCells.append(
			.riskContacts(
				text: AppStrings.Home.riskCardLowNumberContactsItemTitle,
				image: UIImage(named: "Icons_KeineRisikoBegegnung")
			)
		)

		if numberOfExposures > 0 {
			riskDataSectionCells.append(
				.riskLastExposure(
					text: numberOfExposures == 1 ? AppStrings.ExposureDetection.lastExposureOneRiskDay : AppStrings.ExposureDetection.lastExposure,
					image: UIImage(named: "Icons_Calendar")
				)
			)
		} else if homeState.shouldShowDaysSinceInstallation {
			riskDataSectionCells.append(
				.riskStored(daysSinceInstallation: homeState.daysSinceInstallation)
			)
		}

		riskDataSectionCells.append(
			.riskRefreshed(
				text: AppStrings.ExposureDetection.refreshed,
				image: UIImage(named: "Icons_Aktualisiert")
			)
		)

		return DynamicTableViewModel([
			riskDataSection(
			   footer: .riskTint(height: 16),
			   cells: riskDataSectionCells
			),
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

	private func highRiskModel(risk: Risk, isSurveyEnabled: Bool) -> DynamicTableViewModel {
		let numberOfExposures = risk.details.numberOfDaysWithRiskLevel

		var sections: [DynamicSection] = [
			riskDataSection(
				footer: .riskTint(height: 16),
				cells: [
					.riskContacts(
						text: AppStrings.Home.riskCardHighNumberContactsItemTitle,
						image: UIImage(named: "Icons_RisikoBegegnung")
					),
					.riskLastExposure(
						text: numberOfExposures == 1 ? AppStrings.ExposureDetection.lastExposureOneRiskDay : AppStrings.ExposureDetection.lastExposure,
						image: UIImage(named: "Icons_Calendar")
					),
					.riskRefreshed(
						text: AppStrings.ExposureDetection.refreshed,
						image: UIImage(named: "Icons_Aktualisiert")
					)
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
					]),
					.guide(
						attributedString: faqLinkText(),
						image: UIImage(named: "Icons - Test Tube"),
						link: URL(string: AppStrings.Links.exposureDetectionFAQ),
						accessibilityIdentifier: AccessibilityIdentifiers.ExposureDetection.guideFAQ)
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
		]
		if isSurveyEnabled {
			sections.insert(surveySection(), at: 3)
		}
		return DynamicTableViewModel(sections)
	}

	private func faqLinkText(tintColor: UIColor = .enaColor(for: .textTint)) -> NSAttributedString {
		let rawString = String(format: AppStrings.ExposureDetection.guideFAQ, AppStrings.ExposureDetection.guideFAQLinkText)
		let string = NSMutableAttributedString(string: rawString)
		let range = string.mutableString.range(of: AppStrings.ExposureDetection.guideFAQLinkText)
		if range.location != NSNotFound {
			// Links don't work in UILabels so we fake it here. Link handling in done in view controller on cell tap.
			string.addAttribute(.foregroundColor, value: tintColor, range: range)
			string.addAttribute(.underlineColor, value: UIColor.clear, range: range)
		}
		return string
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
				.guide(text: AppStrings.ExposureDetection.guideSneeze, image: UIImage(named: "Icons - Niesen")),
				.guide(text: AppStrings.ExposureDetection.guideVentilation, image: UIImage(named: "Icons - Ventilation"))
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

	private func surveySection() -> DynamicSection {
		return .section(
			cells: [
				.custom(
					withIdentifier: ExposureDetectionViewController.ReusableCellIdentifier.survey,
					action: .execute(block: { [weak self] _, _ in
						self?.onSurveyTap()
					}),
					accessoryAction: .none,
					configure: { _, cell, _ in
						if let surveyCell = cell as? ExposureDetectionSurveyTableViewCell {
							surveyCell.configure(
								with: ExposureDetectionSurveyCellModel(),
								onPrimaryAction: { [weak self] in
									self?.onSurveyTap()
								}
							)
						}
					})
			]
		)
	}


	private func activeTracingSection(risk: Risk, accessibilityIdentifier: String?) -> DynamicSection {
		let p0 = AppStrings.ExposureDetection.tracingParagraph0

		let p1: String
		if homeState.shouldShowDaysSinceInstallation && risk.details.numberOfDaysWithRiskLevel == 0 {
			p1 = String(
				format: AppStrings.ExposureDetection.tracingParagraph1a,
				homeState.daysSinceInstallation
			)
		} else {
			p1 = AppStrings.ExposureDetection.tracingParagraph1b
		}

		let body = [p0, p1].joined(separator: "\n\n")

		return .section(
			header: .backgroundSpace(height: 8),
			footer: .backgroundSpace(height: 16),
			cells: [
				.header(
					title: AppStrings.ExposureDetection.tracingTitle,
					subtitle: AppStrings.ExposureDetection.tracingSubTitle
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
				.body(text: text, accessibilityIdentifier: accessibilityIdentifier)
			].compactMap { $0 }
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
