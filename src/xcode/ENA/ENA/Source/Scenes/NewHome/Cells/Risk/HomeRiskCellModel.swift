//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class HomeRiskCellModel {

	// MARK: - Init

	init(
		homeState: HomeState
	) {
		self.homeState = homeState

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
					break
				case .detectionFailed:
					break
				}
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

	var lastUpdateDateString: String {
		if let lastUpdateDate = homeState.lastRiskCalculationDate {
			return Self.lastUpdateDateFormatter.string(from: lastUpdateDate)
		} else {
			return AppStrings.Home.riskCardNoDateTitle
		}
	}

	@OpenCombine.Published var itemViewModels: [HomeItemViewModel] = []

	// MARK: - Private

	private let homeState: HomeState

	private var lastUpdateDate: Date?

	private var timeUntilUpdate: String?

	private var subscriptions = Set<AnyCancellable>()

	private static let lastUpdateDateFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.doesRelativeDateFormatting = true
		dateFormatter.dateStyle = .short
		dateFormatter.timeStyle = .short
		return dateFormatter
	}()

	private func setupDownloadingState() {
		title = AppStrings.Home.riskCardStatusDownloadingTitle

		itemViewModels = [
			HomeLoadingItemViewModel(
				title: AppStrings.Home.riskCardStatusDownloadingBody,
				titleColor: titleColor,
				isActivityIndicatorOn: true,
				color: backgroundColor,
				separatorColor: separatorColor
			)
		]
	}

	private func setupDetectingState() {
		title = AppStrings.Home.riskCardStatusDetectingTitle

		itemViewModels = [
			HomeLoadingItemViewModel(
				title: AppStrings.Home.riskCardStatusDetectingBody,
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

		let activeTracing = risk.details.activeTracing

		itemViewModels = [
			HomeImageItemViewModel(
				title: String(format: AppStrings.Home.riskCardLowNumberContactsItemTitle, risk.details.numberOfDaysWithRiskLevel),
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
				title: String(format: AppStrings.Home.riskCardDateItemTitle, lastUpdateDateString),
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

		title = AppStrings.Home.riskCardLowTitle
		titleColor = .enaColor(for: .textContrast)

		body = ""
		bodyColor = .enaColor(for: .textContrast)
		isBodyHidden = true

		let activeTracing = risk.details.activeTracing

		itemViewModels = [
			HomeImageItemViewModel(
				title: String(format: AppStrings.Home.riskCardLowNumberContactsItemTitle, risk.details.numberOfDaysWithRiskLevel),
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
				title: String(format: AppStrings.Home.riskCardDateItemTitle, lastUpdateDateString),
				titleColor: titleColor,
				iconImageName: "Icons_Aktualisiert",
				iconTintColor: titleColor,
				color: backgroundColor,
				separatorColor: separatorColor,
				containerInsets: nil
			)
		]
	}

}
