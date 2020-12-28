//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class HomeRiskCellModel {

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
				switch $0 {
				case .risk(let risk):
					switch risk.level {
					case .low:
						self?.setupLowRiskState(risk: risk)
					case .high:
						self?.setupHighRiskState(risk: risk)
					}
				case .inactive:
					self?.setupInactiveState()
				case .detectionFailed:
					break
				}

				onUpdate()
			}
			.store(in: &subscriptions)

		homeState.$riskProviderActivityState
			.sink { [weak self] in
				switch $0 {
				case .downloading:
					self?.setupDownloadingState()
				case .detecting:
					self?.setupDetectingState()
				default:
					break
				}

				onUpdate()
			}
			.store(in: &subscriptions)
	}

	// MARK: - Internal

	@OpenCombine.Published var title: String! = AppStrings.Home.riskCardLowTitle
	@OpenCombine.Published var titleColor: UIColor = .enaColor(for: .textContrast)

	@OpenCombine.Published var body: String! = ""
	@OpenCombine.Published var bodyColor: UIColor = .enaColor(for: .textContrast)
	@OpenCombine.Published var isBodyHidden: Bool = true

	@OpenCombine.Published var backgroundColor: UIColor = .enaColor(for: .riskLow)
	@OpenCombine.Published var separatorColor: UIColor = .enaColor(for: .hairlineContrast)

	@OpenCombine.Published var buttonTitle: String! = AppStrings.Home.riskCardUpdateButton
	@OpenCombine.Published var buttonAction: (() -> Void)?
	@OpenCombine.Published var isButtonInverted: Bool = true
	@OpenCombine.Published var isButtonEnabled: Bool = false
	@OpenCombine.Published var isButtonHidden: Bool = true

//	var buttonTitle: String {
//		if homeState.riskProviderActivityState.isActive { return AppStrings.Home.riskCardUpdateButton }
//		if isButtonEnabled { return AppStrings.Home.riskCardUpdateButton }
//		if let timeUntilUpdate = timeUntilUpdate { return String(format: AppStrings.ExposureDetection.refreshIn, timeUntilUpdate) }
//
////		let detectionInterval = riskProvider.riskProvidingConfiguration.exposureDetectionInterval.hour ?? RiskProvidingConfiguration.defaultExposureDetectionsInterval
//		let detectionInterval = 24
//
//		return String(format: AppStrings.Home.riskCardIntervalDisabledButtonTitle, "\(detectionInterval)")
//	}

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

//	private var lastUpdateDate: Date?
//	private var timeUntilUpdate: String?

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

	private static let lastUpdateDateFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.doesRelativeDateFormatting = true
		dateFormatter.dateStyle = .short
		dateFormatter.timeStyle = .short
		return dateFormatter
	}()

	private func setupDownloadingState() {
		setupLoadingState(
			title: AppStrings.Home.riskCardStatusDownloadingTitle,
			loadingItemTitle: AppStrings.Home.riskCardStatusDownloadingBody
		)
	}

	private func setupDetectingState() {
		setupLoadingState(
			title: AppStrings.Home.riskCardStatusDetectingTitle,
			loadingItemTitle: AppStrings.Home.riskCardStatusDetectingBody
		)
	}

	private func setupLoadingState(
		title: String,
		loadingItemTitle: String
	) {
		self.title = title

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

	private func setupLowRiskState(risk: Risk) {
		backgroundColor = .enaColor(for: .riskLow)
		separatorColor = .enaColor(for: .hairlineContrast)

		title = AppStrings.Home.riskCardLowTitle
		titleColor = .enaColor(for: .textContrast)

		body = ""
		bodyColor = .enaColor(for: .textContrast)
		isBodyHidden = true

		isButtonInverted = true
		isButtonHidden = true
		isButtonEnabled = false

		let activeTracing = risk.details.activeTracing

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
			HomeImageItemViewModel(
				title: activeTracing.localizedDuration,
				titleColor: titleColor,
				iconImageName: activeTracing.inDays >= activeTracing.maximumNumberOfDays ?
					"Icons_TracingCircleFull - Dark" :
					"Icons_TracingCircle-Dark_Step \(activeTracing.inDays)",
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

	private func setupHighRiskState(risk: Risk) {
		backgroundColor = .enaColor(for: .riskHigh)
		separatorColor = .enaColor(for: .hairlineContrast)

		title = AppStrings.Home.riskCardHighTitle
		titleColor = .enaColor(for: .textContrast)

		body = ""
		bodyColor = .enaColor(for: .textContrast)
		isBodyHidden = true

		isButtonHidden = true
		isButtonEnabled = false

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
					format: AppStrings.Home.riskCardLastContactItemTitle,
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

	private func setupInactiveState() {
		backgroundColor = .enaColor(for: .background)
		separatorColor = .enaColor(for: .hairline)

		title = AppStrings.Home.riskCardInactiveNoCalculationPossibleTitle
		titleColor = .enaColor(for: .textPrimary1)

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

	private func setupFailedState() {
		backgroundColor = .enaColor(for: .background)
		separatorColor = .enaColor(for: .hairline)

		title = AppStrings.Home.riskCardFailedCalculationTitle
		titleColor = .enaColor(for: .textPrimary1)

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
