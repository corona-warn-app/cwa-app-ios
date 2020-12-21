//
// 🦠 Corona-Warn-App
//

import UIKit

final class HomeFailedCellConfigurator: HomeRiskCellConfigurator {

	// MARK: - Init

	init(
		state: RiskProviderActivityState,
		previousRiskLevel: RiskLevel?,
		lastUpdateDate: Date?
	) {
		self.riskProviderState = state
		self.previousRiskLevel = previousRiskLevel
		self.lastUpdateDate = lastUpdateDate
	}

	// MARK: - Overrides

	// MARK: - Internal

	var activeAction: (() -> Void)?
	var riskProviderState: RiskProviderActivityState

	let title = AppStrings.Home.riskCardFailedCalculationTitle
	let body = AppStrings.Home.riskCardFailedCalculationBody
	let buttonTitle = AppStrings.Home.riskCardFailedCalculationRestartButtonTitle

	var previousRiskTitle: String {
		switch previousRiskLevel {
		case .low?:
			return AppStrings.Home.riskCardLastActiveItemLowTitle
		case .high?:
			return AppStrings.Home.riskCardLastActiveItemHighTitle
		default:
			return AppStrings.Home.riskCardLastActiveItemUnknownTitle
		}
	}

	func setupAccessibility(_ cell: RiskFailedCollectionViewCell) {
		cell.titleLabel.isAccessibilityElement = false
		cell.chevronImageView.isAccessibilityElement = false
		cell.viewContainer.isAccessibilityElement = false
		cell.stackView.isAccessibilityElement = false

		cell.topContainer.isAccessibilityElement = true
		cell.bodyLabel.isAccessibilityElement = true

		let topContainerText = cell.titleLabel.text ?? ""
		cell.topContainer.accessibilityLabel = topContainerText
		cell.topContainer.accessibilityTraits = [.button, .header]
	}

	func configure(cell: RiskFailedCollectionViewCell) {

		cell.delegate = self

		// Configuring the UI.

		configureUI(for: cell)

		setupAccessibility(cell)

	}

	func hash(into hasher: inout Swift.Hasher) {
		hasher.combine(previousRiskLevel)
		hasher.combine(lastUpdateDate)
	}

	static func == (lhs: HomeFailedCellConfigurator, rhs: HomeFailedCellConfigurator) -> Bool {
		lhs.previousRiskLevel == rhs.previousRiskLevel &&
		lhs.lastUpdateDate == rhs.lastUpdateDate
	}

	// MARK: - Private

	private var previousRiskLevel: RiskLevel?
	private var lastUpdateDate: Date?

	private let titleColor: UIColor = .enaColor(for: .textPrimary1)
	private let iconTintColor: UIColor = .enaColor(for: .riskNeutral)
	private let color: UIColor = .enaColor(for: .background)
	private let separatorColor: UIColor = .enaColor(for: .hairline)

	private static let lastUpdateDateFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.doesRelativeDateFormatting = true
		dateFormatter.dateStyle = .short
		dateFormatter.timeStyle = .short
		return dateFormatter
	}()

	private var lastUpdateDateString: String {
		if let lastUpdateDate = lastUpdateDate {
			return Self.lastUpdateDateFormatter.string(from: lastUpdateDate)
		} else {
			return AppStrings.Home.riskCardNoDateTitle
		}
	}

	/// Adjusts the UI for the given cell, including setting text and adjusting colors.
	private func configureUI(for cell: RiskFailedCollectionViewCell) {
		switch riskProviderState {
		case .downloading:
			cell.configureTitle(title: AppStrings.Home.riskCardStatusDownloadingTitle, titleColor: titleColor)
			cell.configureBackgroundColor(color: .enaColor(for: .background))
			cell.bodyLabel.isHidden = true
			cell.activeButton.isHidden = true

			let itemCellConfigurator = makeConfiguratorsForProcessingState()
			cell.configureRiskViews(cellConfigurators: [itemCellConfigurator])
		case .detecting:
			cell.configureTitle(title: AppStrings.Home.riskCardStatusDetectingTitle, titleColor: titleColor)
			cell.configureBackgroundColor(color: .enaColor(for: .background))
			cell.configureActiveButton(title: buttonTitle)
			cell.bodyLabel.isHidden = true
			cell.activeButton.isHidden = true

			let itemCellConfigurator = makeConfiguratorsForProcessingState()
			cell.configureRiskViews(cellConfigurators: [itemCellConfigurator])
		default:
			cell.configureTitle(title: title, titleColor: .enaColor(for: .textPrimary1))
			cell.configureBody(text: body, bodyColor: .enaColor(for: .textPrimary1))
			cell.configureBackgroundColor(color: .enaColor(for: .background))
			cell.configureActiveButton(title: buttonTitle)
			cell.activeButton.isHidden = false
			cell.bodyLabel.isHidden = false

			let itemCellConfigurators = makeConfiguratorsForNormalState()
			cell.configureRiskViews(cellConfigurators: itemCellConfigurators)
		}

	}

	private func makeConfiguratorsForNormalState() -> [HomeRiskImageItemViewConfigurator] {
		let activateItemTitle = String(format: AppStrings.Home.riskCardLastActiveItemTitle, previousRiskTitle)
		let dateTitle = String(format: AppStrings.Home.riskCardDateItemTitle, lastUpdateDateString)

		let itemCellConfigurators = [
			// Card for the last state of the risk state.
			HomeRiskImageItemViewConfigurator(
				title: activateItemTitle,
				titleColor: titleColor,
				iconImageName: "Icons_LetzteErmittlung-Light",
				iconTintColor: iconTintColor,
				color: color,
				separatorColor: separatorColor
			),

			// Card for the last exposure date.
			HomeRiskImageItemViewConfigurator(
				title: dateTitle,
				titleColor: titleColor,
				iconImageName: "Icons_Aktualisiert",
				iconTintColor: iconTintColor,
				color: color,
				separatorColor: separatorColor
			)

		]

		return itemCellConfigurators
	}

	private func makeConfiguratorsForProcessingState() -> HomeRiskLoadingItemViewConfigurator {
		return HomeRiskLoadingItemViewConfigurator(
			title: AppStrings.Home.riskCardStatusDetectingBody,
			titleColor: titleColor,
			isActivityIndicatorOn: true,
			color: color,
			separatorColor: separatorColor
		)
	}
}

// MARK: - Protocol RiskFailedCollectionViewCellDelegate

extension HomeFailedCellConfigurator: RiskFailedCollectionViewCellDelegate {
	func activeButtonTapped(cell: RiskFailedCollectionViewCell) {
		activeAction?()
	}
}
