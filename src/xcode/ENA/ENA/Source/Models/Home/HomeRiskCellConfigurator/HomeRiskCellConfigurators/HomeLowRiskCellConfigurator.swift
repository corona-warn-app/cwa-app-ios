//
// 🦠 Corona-Warn-App
//

import UIKit

final class HomeLowRiskCellConfigurator: HomeRiskLevelCellConfigurator {
	private var numberRiskContacts: Int
	private var numberDays: Int { activeTracing.inDays }
	private var totalDays: Int { activeTracing.maximumNumberOfDays }
	private let activeTracing: ActiveTracing

	private let titleColor: UIColor = .enaColor(for: .textContrast)
	private let color: UIColor = .enaColor(for: .riskLow)
	private let separatorColor: UIColor = .enaColor(for: .hairlineContrast)

	// MARK: Creating a Home Risk Cell Configurator

	init(
		state: RiskProvider.ActivityState,
		numberRiskContacts: Int,
		lastUpdateDate: Date?,
		isButtonHidden: Bool,
		manualExposureDetectionState: ManualExposureDetectionState?,
		detectionInterval: Int,
		activeTracing: ActiveTracing
	) {
		self.numberRiskContacts = numberRiskContacts
		self.activeTracing = activeTracing
		super.init(
			state: state,
			isButtonEnabled: manualExposureDetectionState == .possible,
			isButtonHidden: isButtonHidden,
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
			itemCellConfigurators.append(contentsOf: setupNormalCellState(for: cell))
		}

		cell.delegate = self
		cell.configureBody(text: "", bodyColor: titleColor, isHidden: true)
		cell.configureRiskViews(cellConfigurators: itemCellConfigurators)
		cell.configureBackgroundColor(color: color)

		configureButton(for: cell)
		setupAccessibility(cell)
	}

	// MARK: - Configuration helpers.

	private func setupDownloadingCellState(for cell: RiskLevelCollectionViewCell) -> HomeRiskLoadingItemViewConfigurator {
		cell.configureTitle(title: AppStrings.Home.riskCardStatusDownloadingTitle, titleColor: titleColor)
		return HomeRiskLoadingItemViewConfigurator(
			title: AppStrings.Home.riskCardStatusDownloadingBody,
			titleColor: titleColor,
			isActivityIndicatorOn: true,
			color: color,
			separatorColor: separatorColor
		)
	}

	private func setupDetectingCellState(for cell: RiskLevelCollectionViewCell) -> HomeRiskLoadingItemViewConfigurator {
		cell.configureTitle(title: AppStrings.Home.riskCardStatusDetectingTitle, titleColor: titleColor)
		return HomeRiskLoadingItemViewConfigurator(
			title: AppStrings.Home.riskCardStatusDetectingBody,
			titleColor: titleColor,
			isActivityIndicatorOn: true,
			color: color,
			separatorColor: separatorColor
		)
	}

	private func setupNormalCellState(for cell: RiskLevelCollectionViewCell) -> [HomeRiskImageItemViewConfigurator] {
		var itemCellConfigurators: [HomeRiskImageItemViewConfigurator] = []
		cell.configureTitle(title: AppStrings.Home.riskCardLowTitle, titleColor: titleColor)
		let numberContactsTitle = String(format: AppStrings.Home.riskCardLowNumberContactsItemTitle, numberRiskContacts)
		itemCellConfigurators.append(
			HomeRiskImageItemViewConfigurator(
				title: numberContactsTitle,
				titleColor: titleColor,
				iconImageName: "Icons_KeineRisikoBegegnung",
				iconTintColor: titleColor,
				color: color,
				separatorColor: separatorColor
			)
		)
		let progressImage: String = numberDays >= totalDays ? "Icons_TracingCircleFull - Dark" : "Icons_TracingCircle-Dark_Step \(activeTracing.inDays)"
		itemCellConfigurators.append(
			HomeRiskImageItemViewConfigurator(
				title: activeTracing.localizedDuration,
				titleColor: titleColor,
				iconImageName: progressImage,
				iconTintColor: titleColor,
				color: color,
				separatorColor: separatorColor
			)
		)

		let dateTitle = String(format: AppStrings.Home.riskCardDateItemTitle, lastUpdateDateString)
		itemCellConfigurators.append(
			HomeRiskImageItemViewConfigurator(
				title: dateTitle,
				titleColor: titleColor,
				iconImageName: "Icons_Aktualisiert",
				iconTintColor: titleColor,
				color: color,
				separatorColor: separatorColor
			)
		)

		return itemCellConfigurators
	}

	// MARK: Hashable

	override func hash(into hasher: inout Swift.Hasher) {
		super.hash(into: &hasher)
		hasher.combine(numberRiskContacts)
		hasher.combine(numberDays)
		hasher.combine(totalDays)
	}

	static func == (lhs: HomeLowRiskCellConfigurator, rhs: HomeLowRiskCellConfigurator) -> Bool {
		lhs.riskProviderState == rhs.riskProviderState &&
		lhs.isButtonEnabled == rhs.isButtonEnabled &&
		lhs.isButtonHidden == rhs.isButtonHidden &&
		lhs.lastUpdateDate == rhs.lastUpdateDate &&
		lhs.numberRiskContacts == rhs.numberRiskContacts &&
		lhs.numberDays == rhs.numberDays &&
		lhs.totalDays == rhs.totalDays &&
		lhs.detectionInterval == rhs.detectionInterval
	}
}
