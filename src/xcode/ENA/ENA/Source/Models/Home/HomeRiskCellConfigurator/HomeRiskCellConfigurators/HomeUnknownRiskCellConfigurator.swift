//
// 🦠 Corona-Warn-App
//

import UIKit

final class HomeUnknownRiskCellConfigurator: HomeRiskLevelCellConfigurator {

	private let titleColor: UIColor = .enaColor(for: .textContrast)
	private let color: UIColor = .enaColor(for: .riskNeutral)
	private let separatorColor: UIColor = .enaColor(for: .hairlineContrast)

	// MARK: Configuration

	// MARK: Creating a unknown Risk cell
	init(
		state: RiskProvider.ActivityState,
		lastUpdateDate: Date?,
		detectionInterval: Int,
		detectionMode: DetectionMode,
		manualExposureDetectionState: ManualExposureDetectionState?
	) {
		super.init(
			state: state,
			isButtonEnabled: manualExposureDetectionState == .possible,
			isButtonHidden: detectionMode == .automatic,
			lastUpdateDate: lastUpdateDate,
			detectionInterval: detectionInterval
		)
	}

	override func configure(cell: RiskLevelCollectionViewCell) {
		var itemCellConfigurators: [HomeRiskViewConfiguratorAny] = []

		switch riskProviderState {
		case .downloading:
			itemCellConfigurators += [setupDownloadingCellState(for: cell)]
		case .detecting:
			itemCellConfigurators += [setupDetectingCellState(for: cell)]
		default:
			itemCellConfigurators.append(setupNormalCellState(for: cell))

		}

		cell.delegate = self
		cell.configureBody(text: "", bodyColor: titleColor, isHidden: true)
		cell.configureRiskViews(cellConfigurators: itemCellConfigurators)
		cell.configureBackgroundColor(color: color)

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

	private func setupNormalCellState(for cell: RiskLevelCollectionViewCell) -> HomeRiskViewConfiguratorAny {
		cell.configureTitle(title: AppStrings.Home.riskCardUnknownTitle, titleColor: titleColor)
		return HomeRiskTextItemViewConfigurator(title: AppStrings.Home.riskCardUnknownItemTitle, titleColor: titleColor, color: color, separatorColor: separatorColor)
	}


	// MARK: Hashable

	override func hash(into hasher: inout Swift.Hasher) {
		super.hash(into: &hasher)
	}

	static func == (lhs: HomeUnknownRiskCellConfigurator, rhs: HomeUnknownRiskCellConfigurator) -> Bool {
		lhs.riskProviderState == rhs.riskProviderState &&
		lhs.isButtonEnabled == rhs.isButtonEnabled &&
		lhs.isButtonHidden == rhs.isButtonHidden &&
		lhs.lastUpdateDate == rhs.lastUpdateDate &&
		lhs.detectionInterval == rhs.detectionInterval
	}
}
