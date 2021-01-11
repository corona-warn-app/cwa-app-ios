//
// 🦠 Corona-Warn-App
//

import UIKit

final class HomeHighRiskCellConfigurator: HomeRiskLevelCellConfigurator {
	private var numberOfDaysWithHighRisk: Int
	private var mostRecentDateWithHighRisk: Date?

	private let titleColor: UIColor = .enaColor(for: .textContrast)
	private let color: UIColor = .enaColor(for: .riskHigh)
	private let separatorColor: UIColor = .enaColor(for: .hairlineContrast)

	// MARK: Creating a Home Risk Cell Configurator

	init(
		state: RiskProviderActivityState,
		numberOfDaysWithHighRisk: Int,
		mostRecentDateWithHighRisk: Date?,
		lastUpdateDate: Date?,
		manualExposureDetectionState: ManualExposureDetectionState?,
		detectionMode: DetectionMode,
		detectionInterval: Int
	) {
		self.numberOfDaysWithHighRisk = numberOfDaysWithHighRisk
		self.mostRecentDateWithHighRisk = mostRecentDateWithHighRisk
		super.init(
			state: state,
			isButtonEnabled: manualExposureDetectionState == .possible,
			isButtonHidden: detectionMode == .automatic,
			lastUpdateDate: lastUpdateDate,
			detectionInterval: detectionInterval
		)
	}

	// MARK: Configuration

	override func configure(cell: RiskLevelCollectionViewCell) {
		var itemCellConfigurators: [HomeRiskViewConfiguratorAny] = []
		
		switch riskProviderState {
		case .downloading:
			itemCellConfigurators += [setupDownloadingCellState(for: cell)]
		case .detecting:
			itemCellConfigurators += [setupDetectingCellState(for: cell)]
		default:
			itemCellConfigurators += setupNormalCellState(for: cell)
		}

		cell.configureRiskViews(cellConfigurators: itemCellConfigurators)
		cell.configureBackgroundColor(color: color)
		cell.delegate = self
		cell.configureBody(text: "", bodyColor: titleColor, isHidden: true)

		configureButton(for: cell)
		setupAccessibility(cell)
	}

	// MARK: - Configuration helpers.

	private func setupDownloadingCellState(for cell: RiskLevelCollectionViewCell) -> HomeRiskViewConfiguratorAny {
		cell.configureTitle(title: AppStrings.Home.riskCardStatusDownloadingTitle, titleColor: titleColor)
		return HomeRiskLoadingItemViewConfigurator(title: AppStrings.Home.riskCardStatusDownloadingBody, titleColor: titleColor, isActivityIndicatorOn: true, color: color, separatorColor: separatorColor)
	}

	private func setupDetectingCellState(for cell: RiskLevelCollectionViewCell) -> HomeRiskViewConfiguratorAny {
		cell.configureTitle(title: AppStrings.Home.riskCardStatusDetectingTitle, titleColor: titleColor)
		return HomeRiskLoadingItemViewConfigurator(title: AppStrings.Home.riskCardStatusDetectingBody, titleColor: titleColor, isActivityIndicatorOn: true, color: color, separatorColor: separatorColor)
	}

	private func setupNormalCellState(for cell: RiskLevelCollectionViewCell) -> [HomeRiskViewConfiguratorAny] {
		cell.configureTitle(title: AppStrings.Home.riskCardHighTitle, titleColor: titleColor)

		var formattedMostRecentDateWithHighRisk = ""
		assert(mostRecentDateWithHighRisk != nil, "mostRecentDateWithHighRisk must be set on high risk state")
		if let mostRecentDateWithHighRisk = mostRecentDateWithHighRisk {
			let dateFormatter = DateFormatter()
			dateFormatter.dateStyle = .medium
			formattedMostRecentDateWithHighRisk = dateFormatter.string(from: mostRecentDateWithHighRisk)
		}

		let numberOfDaysWithHighRiskTitle = String(format: AppStrings.Home.riskCardHighNumberContactsItemTitle, numberOfDaysWithHighRisk)
		let lastContactTitle = String(format: AppStrings.Home.riskCardLastContactItemTitle, formattedMostRecentDateWithHighRisk)
		let dateTitle = String(format: AppStrings.Home.riskCardDateItemTitle, lastUpdateDateString)

		return [
			HomeRiskImageItemViewConfigurator(title: numberOfDaysWithHighRiskTitle, titleColor: titleColor, iconImageName: "Icons_RisikoBegegnung", iconTintColor: titleColor, color: color, separatorColor: separatorColor),
			HomeRiskImageItemViewConfigurator(title: lastContactTitle, titleColor: titleColor, iconImageName: "Icons_Calendar", iconTintColor: titleColor, color: color, separatorColor: separatorColor),
			HomeRiskImageItemViewConfigurator(title: dateTitle, titleColor: titleColor, iconImageName: "Icons_Aktualisiert", iconTintColor: titleColor, color: color, separatorColor: separatorColor)
		]
	}

	// MARK: Hashable

	override func hash(into hasher: inout Swift.Hasher) {
		super.hash(into: &hasher)
		hasher.combine(numberOfDaysWithHighRisk)
		hasher.combine(mostRecentDateWithHighRisk)
	}

	static func == (lhs: HomeHighRiskCellConfigurator, rhs: HomeHighRiskCellConfigurator) -> Bool {
		lhs.riskProviderState == rhs.riskProviderState &&
		lhs.isButtonEnabled == rhs.isButtonEnabled &&
		lhs.isButtonHidden == rhs.isButtonHidden &&
		lhs.lastUpdateDate == rhs.lastUpdateDate &&
		lhs.numberOfDaysWithHighRisk == rhs.numberOfDaysWithHighRisk &&
		lhs.mostRecentDateWithHighRisk == rhs.mostRecentDateWithHighRisk &&
		lhs.detectionInterval == rhs.detectionInterval
	}
}
