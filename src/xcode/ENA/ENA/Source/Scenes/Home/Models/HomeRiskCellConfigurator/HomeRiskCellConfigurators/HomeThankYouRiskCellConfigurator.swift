//
// 🦠 Corona-Warn-App
//

import UIKit

final class HomeThankYouRiskCellConfigurator: HomeRiskCellConfigurator {
	
	// MARK: Configuration

	func configure(cell: RiskThankYouCollectionViewCell) {

		let title = AppStrings.Home.thankYouCardTitle
		let titleColor: UIColor = .enaColor(for: .textPrimary1)
		cell.configureTitle(title: title, titleColor: titleColor)

		let imageName = "Illu_Submission_VielenDank"
		cell.configureImage(imageName: imageName)

		let body = AppStrings.Home.thankYouCardBody
		cell.configureBody(text: body, bodyColor: titleColor)

		let noteTitle = AppStrings.Home.thankYouCardNoteTitle
		cell.configureNoteLabel(title: noteTitle)

		let iconColor: UIColor = .enaColor(for: .riskHigh)
		let phoneTitle = AppStrings.Home.thankYouCardPhoneItemTitle
		let phoneItem = HomeRiskImageItemViewConfigurator(title: phoneTitle, titleColor: titleColor, iconImageName: "Icons - Hotline", iconTintColor: iconColor, color: .clear, separatorColor: .clear)
		phoneItem.containerInsets = .init(top: 10.0, left: 0.0, bottom: 10.0, right: 0)

		let homeTitle = AppStrings.Home.thankYouCardHomeItemTitle
		let homeItem = HomeRiskImageItemViewConfigurator(title: homeTitle, titleColor: titleColor, iconImageName: "Icons - Home", iconTintColor: iconColor, color: .clear, separatorColor: .clear)
		homeItem.containerInsets = .init(top: 10.0, left: 0.0, bottom: 10.0, right: 0)
		cell.configureNoteRiskViews(cellConfigurators: [phoneItem, homeItem])


		let furtherInfoTitle = AppStrings.Home.thankYouCardFurtherInfoItemTitle
		cell.configureFurtherInfoLabel(title: furtherInfoTitle)

		let info1Text = AppStrings.Home.thankYouCard14DaysItemTitle
		let info1 = HomeRiskListItemViewConfigurator(text: info1Text, titleColor: titleColor)
		let info2Text = AppStrings.Home.thankYouCardContactsItemTitle
		let info2 = HomeRiskListItemViewConfigurator(text: info2Text, titleColor: titleColor)
		let info3Text = AppStrings.Home.thankYouCardAppItemTitle
		let info3 = HomeRiskListItemViewConfigurator(text: info3Text, titleColor: titleColor)
		let info4Text = AppStrings.Home.thankYouCardNoSymptomsItemTitle
		let info4 = HomeRiskListItemViewConfigurator(text: info4Text, titleColor: titleColor)
		cell.configureFurtherInfoRiskViews(cellConfigurators: [info1, info2, info3, info4])

		let backgroundColor = UIColor.enaColor(for: .background)
		cell.configureBackgroundColor(color: backgroundColor)

		setupAccessibility(cell)
	}

	func setupAccessibility(_ cell: RiskThankYouCollectionViewCell) {
		cell.titleLabel.isAccessibilityElement = true
		cell.viewContainer.isAccessibilityElement = false
		cell.stackView.isAccessibilityElement = false
		cell.bodyLabel.isAccessibilityElement = true

		cell.titleLabel.accessibilityTraits = .header
	}

	// MARK: Hashable

	func hash(into hasher: inout Swift.Hasher) {
		// this class has no stored properties, that's why hash function is empty here
	}

	static func == (lhs: HomeThankYouRiskCellConfigurator, rhs: HomeThankYouRiskCellConfigurator) -> Bool {
		// instances of this class have no differences between each other
		true
	}
}
