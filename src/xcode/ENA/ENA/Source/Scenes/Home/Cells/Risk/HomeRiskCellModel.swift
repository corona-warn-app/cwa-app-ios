//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

// swiftlint:disable:next type_body_length
class HomeRiskCellModel: CountdownTimerDelegate {

	// MARK: - Init

	init(
		homeState: HomeState,
		onInactiveButtonTap: @escaping () -> Void,
		onUpdate: @escaping () -> Void
	) {
		self.homeState = homeState
		self.onInactiveButtonTap = onInactiveButtonTap

		homeState.$riskState
			.sink { [weak self] in
				self?.scheduleCountdownTimer()
				switch $0 {
				case .risk(let risk):
					switch risk.level {
					case .low:
						self?.setupForLowRiskState(risk: risk)
					case .high:
						self?.setupForHighRiskState(risk: risk)
					}
				case .inactive:
					self?.setupForInactiveState()
				case .detectionFailed:
					self?.setupForFailedState()
				}

				onUpdate()
			}
			.store(in: &subscriptions)

		homeState.$riskProviderActivityState
			.sink { [weak self] in
				switch $0 {
				case .downloading:
					self?.setupForDownloadingState()
				case .detecting:
					self?.setupForDetectingState()
				default:
					break
				}

				onUpdate()
			}
			.store(in: &subscriptions)

		homeState.$detectionMode
			.sink { [weak self] detectionMode in
				self?.scheduleCountdownTimer()

				if case .risk = homeState.riskState {
					self?.isButtonHidden = detectionMode == .automatic
				}

				onUpdate()
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

	enum ChevronStyle {
		case plain
		case circled
	}

	@OpenCombine.Published var title: String! = AppStrings.Home.riskCardLowTitle
	@OpenCombine.Published var titleAccessibilityValue: String! = AppStrings.Home.riskCardLowTitleColorName
	@OpenCombine.Published var titleColor: UIColor = .enaColor(for: .textContrast)

	@OpenCombine.Published var chevronStyle: ChevronStyle = .circled

	@OpenCombine.Published var body: String! = ""
	@OpenCombine.Published var bodyColor: UIColor = .enaColor(for: .textContrast)
	@OpenCombine.Published var isBodyHidden: Bool = true

	@OpenCombine.Published var backgroundColor: UIColor = .enaColor(for: .riskLow)
	@OpenCombine.Published var separatorColor: UIColor = .enaColor(for: .hairlineContrast)

	@OpenCombine.Published var buttonTitle: String! = AppStrings.Home.riskCardUpdateButton
	@OpenCombine.Published var isButtonInverted: Bool = true
	@OpenCombine.Published var isButtonEnabled: Bool = false
	@OpenCombine.Published var isButtonHidden: Bool = true

	@OpenCombine.Published var itemViewModels: [HomeItemViewModel] = []

	func onButtonTap() {
		switch homeState.riskState {
		case .inactive:
			onInactiveButtonTap()
		case .risk, .detectionFailed:
			homeState.requestRisk(userInitiated: true)
		}
	}

	// MARK: - Private

	private let homeState: HomeState
	private let onInactiveButtonTap: () -> Void

	private var countdownTimer: CountdownTimer?
	private var timeUntilUpdate: String?

	private var subscriptions = Set<AnyCancellable>()

	private var lastUpdateDateString: String {
		if let lastUpdateDate = homeState.lastRiskCalculationResult?.calculationDate {
			return Self.lastUpdateDateFormatter.string(from: lastUpdateDate)
		} else {
			return AppStrings.Home.riskCardNoDateTitle
		}
	}

	private var previousRiskTitle: String {
		switch homeState.lastRiskCalculationResult?.riskLevel {
		case .low:
			return AppStrings.Home.riskCardLastActiveItemLowTitle
		case .high:
			return AppStrings.Home.riskCardLastActiveItemHighTitle
		case .none:
			return AppStrings.Home.riskCardLastActiveItemUnknownTitle
		}
	}

	private var riskButtonTitle: String {
		if let timeUntilUpdate = timeUntilUpdate {
			return String(format: AppStrings.ExposureDetection.refreshIn, timeUntilUpdate)
		}

		if homeState.manualExposureDetectionState == .possible {
			return AppStrings.Home.riskCardUpdateButton
		}

		let detectionInterval = homeState.exposureDetectionInterval

		return String(format: AppStrings.Home.riskCardIntervalDisabledButtonTitle, "\(detectionInterval)")
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

	private func setupForDownloadingState() {
		setupForLoadingState(
			title: AppStrings.Home.riskCardStatusDownloadingTitle,
			loadingItemTitle: AppStrings.Home.riskCardStatusDownloadingBody
		)
	}

	private func setupForDetectingState() {
		setupForLoadingState(
			title: AppStrings.Home.riskCardStatusDetectingTitle,
			loadingItemTitle: AppStrings.Home.riskCardStatusDetectingBody
		)
	}

	private func setupForLoadingState(
		title: String,
		loadingItemTitle: String
	) {
		self.title = title
		titleAccessibilityValue = ""

		body = ""
		bodyColor = .enaColor(for: .textContrast)
		isBodyHidden = true

		isButtonHidden = true
		isButtonEnabled = false

		itemViewModels = [
			HomeLoadingItemViewModel(
				title: loadingItemTitle,
				titleColor: titleColor,
				isActivityIndicatorOn: true,
				color: backgroundColor,
				separatorColor: separatorColor
			)
		]
	}

	private func setupForLowRiskState(risk: Risk) {
		backgroundColor = .enaColor(for: .riskLow)
		separatorColor = .enaColor(for: .hairlineContrast)

		title = AppStrings.Home.riskCardLowTitle
		titleAccessibilityValue = risk.level.accessibilityRiskColor
		titleColor = .enaColor(for: .textContrast)

		chevronStyle = .circled

		body = ""
		bodyColor = .enaColor(for: .textContrast)
		isBodyHidden = true

		buttonTitle = riskButtonTitle
		isButtonInverted = true
		isButtonHidden = homeState.detectionMode == .automatic
		isButtonEnabled = homeState.manualExposureDetectionState == .possible

		var formattedMostRecentDateWithLowRisk = ""
		if let mostRecentDateWithLowRisk = risk.details.mostRecentDateWithRiskLevel {
			let dateFormatter = DateFormatter()
			dateFormatter.dateStyle = .medium
			formattedMostRecentDateWithLowRisk = dateFormatter.string(from: mostRecentDateWithLowRisk)
		}

		// TODO: RDA
		let activeTracingDaysModel = HomeImageItemViewModel(
			title: "To be done", //activeTracing.localizedDuration,
			titleColor: titleColor,
			iconImageName: "Icons_TracingCircleFull - Dark", //activeTracing.inDays >= activeTracing.maximumNumberOfDays ?
			    //"Icons_TracingCircleFull - Dark" :
			    //"Icons_TracingCircle-Dark_Step \(activeTracing.inDays)",
		    iconTintColor: titleColor,
		    color: backgroundColor,
		    separatorColor: separatorColor,
		    containerInsets: nil
	    )
		let recentRiskDaysModel = HomeImageItemViewModel(
			title: String(
				format: risk.details.numberOfDaysWithRiskLevel == 1 ? AppStrings.Home.riskCardLastContactItemTitleOneRiskDay : AppStrings.Home.riskCardLastContactItemTitle,
				formattedMostRecentDateWithLowRisk
		    ),
		    titleColor: titleColor,
		    iconImageName: "Icons_Calendar",
		    iconTintColor: titleColor,
		    color: backgroundColor,
		    separatorColor: separatorColor,
		    containerInsets: nil
	    )

		itemViewModels = [
			HomeImageItemViewModel(
				title: String(
					format: AppStrings.Home.riskCardLowNumberContactsItemTitle,
					risk.details.numberOfDaysWithRiskLevel
				),
				titleColor: titleColor,
				iconImageName: "Icons_KeineRisikoBegegnung",
				iconTintColor: titleColor,
				color: backgroundColor,
				separatorColor: separatorColor,
				containerInsets: nil
			),
			risk.details.numberOfDaysWithRiskLevel > 0 ? recentRiskDaysModel : activeTracingDaysModel,
			HomeImageItemViewModel(
				title: String(
					format: AppStrings.Home.riskCardDateItemTitle,
					lastUpdateDateString
				),
				titleColor: titleColor,
				iconImageName: "Icons_Aktualisiert",
				iconTintColor: titleColor,
				color: backgroundColor,
				separatorColor: separatorColor,
				containerInsets: nil
			)
		]
	}

	private func setupForHighRiskState(risk: Risk) {
		backgroundColor = .enaColor(for: .riskHigh)
		separatorColor = .enaColor(for: .hairlineContrast)

		title = AppStrings.Home.riskCardHighTitle
		titleAccessibilityValue = risk.level.accessibilityRiskColor
		titleColor = .enaColor(for: .textContrast)

		chevronStyle = .circled

		body = ""
		bodyColor = .enaColor(for: .textContrast)
		isBodyHidden = true

		buttonTitle = riskButtonTitle
		isButtonInverted = true
		isButtonHidden = homeState.detectionMode == .automatic
		isButtonEnabled = homeState.manualExposureDetectionState == .possible

		let mostRecentDateWithHighRisk = risk.details.mostRecentDateWithRiskLevel
		var formattedMostRecentDateWithHighRisk = ""
		assert(mostRecentDateWithHighRisk != nil, "mostRecentDateWithHighRisk must be set on high risk state")
		if let mostRecentDateWithHighRisk = mostRecentDateWithHighRisk {
			let dateFormatter = DateFormatter()
			dateFormatter.dateStyle = .medium
			formattedMostRecentDateWithHighRisk = dateFormatter.string(from: mostRecentDateWithHighRisk)
		}

		itemViewModels = [
			HomeImageItemViewModel(
				title: String(
					format: AppStrings.Home.riskCardHighNumberContactsItemTitle,
					risk.details.numberOfDaysWithRiskLevel
				),
				titleColor: titleColor,
				iconImageName: "Icons_RisikoBegegnung",
				iconTintColor: titleColor,
				color: backgroundColor,
				separatorColor: separatorColor,
				containerInsets: nil
			),
			HomeImageItemViewModel(
				title: String(
					format: risk.details.numberOfDaysWithRiskLevel == 1 ? AppStrings.Home.riskCardLastContactItemTitleOneRiskDay : AppStrings.Home.riskCardLastContactItemTitle,
					formattedMostRecentDateWithHighRisk
				),
				titleColor: titleColor,
				iconImageName: "Icons_Calendar",
				iconTintColor: titleColor,
				color: backgroundColor,
				separatorColor: separatorColor,
				containerInsets: nil
			),
			HomeImageItemViewModel(
				title: String(
					format: AppStrings.Home.riskCardDateItemTitle,
					lastUpdateDateString
				),
				titleColor: titleColor,
				iconImageName: "Icons_Aktualisiert",
				iconTintColor: titleColor,
				color: backgroundColor,
				separatorColor: separatorColor,
				containerInsets: nil
			)
		]
	}

	private func setupForInactiveState() {
		backgroundColor = .enaColor(for: .background)
		separatorColor = .enaColor(for: .hairline)

		title = AppStrings.Home.riskCardInactiveNoCalculationPossibleTitle
		titleAccessibilityValue = ""
		titleColor = .enaColor(for: .textPrimary1)

		chevronStyle = .plain

		body = AppStrings.Home.riskCardInactiveNoCalculationPossibleBody
		bodyColor = .enaColor(for: .textPrimary1)
		isBodyHidden = false

		buttonTitle = AppStrings.Home.riskCardInactiveNoCalculationPossibleButton
		isButtonInverted = false
		isButtonHidden = false
		isButtonEnabled = true

		itemViewModels = [
			HomeImageItemViewModel(
				title: String(
					format: AppStrings.Home.riskCardLastActiveItemTitle,
					previousRiskTitle
				),
				titleColor: titleColor,
				iconImageName: "Icons_LetzteErmittlung-Light",
				iconTintColor: .enaColor(for: .riskNeutral),
				color: backgroundColor,
				separatorColor: separatorColor,
				containerInsets: nil
			),
			HomeImageItemViewModel(
				title: String(
					format: AppStrings.Home.riskCardDateItemTitle,
					lastUpdateDateString
				),
				titleColor: titleColor,
				iconImageName: "Icons_Aktualisiert",
				iconTintColor: .enaColor(for: .riskNeutral),
				color: backgroundColor,
				separatorColor: separatorColor,
				containerInsets: nil
			)
		]
	}

	private func setupForFailedState() {
		backgroundColor = .enaColor(for: .background)
		separatorColor = .enaColor(for: .hairline)

		title = AppStrings.Home.riskCardFailedCalculationTitle
		titleAccessibilityValue = ""
		titleColor = .enaColor(for: .textPrimary1)

		chevronStyle = .plain

		body = AppStrings.Home.riskCardFailedCalculationBody
		bodyColor = .enaColor(for: .textPrimary1)
		isBodyHidden = false

		buttonTitle = AppStrings.Home.riskCardFailedCalculationRestartButtonTitle
		isButtonInverted = false
		isButtonHidden = false
		isButtonEnabled = true

		itemViewModels = [
			HomeImageItemViewModel(
				title: String(
					format: AppStrings.Home.riskCardLastActiveItemTitle,
					previousRiskTitle
				),
				titleColor: titleColor,
				iconImageName: "Icons_LetzteErmittlung-Light",
				iconTintColor: .enaColor(for: .riskNeutral),
				color: backgroundColor,
				separatorColor: separatorColor,
				containerInsets: nil
			),
			HomeImageItemViewModel(
				title: String(
					format: AppStrings.Home.riskCardDateItemTitle,
					lastUpdateDateString
				),
				titleColor: titleColor,
				iconImageName: "Icons_Aktualisiert",
				iconTintColor: .enaColor(for: .riskNeutral),
				color: backgroundColor,
				separatorColor: separatorColor,
				containerInsets: nil
			)
		]
	}

}
