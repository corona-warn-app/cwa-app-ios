//
// 🦠 Corona-Warn-App
//

import UIKit

struct HomeShownPositiveTestResultCellModel {

	// MARK: - Internal

	let backgroundColor = UIColor.enaColor(for: .background)

	let title = AppStrings.Home.findingPositiveCardTitle
	let titleColor: UIColor = .enaColor(for: .textPrimary1)

	let statusTitle = AppStrings.Home.findingPositiveCardStatusTitle
	let statusSubtitle = AppStrings.Home.findingPositiveCardStatusSubtitle
	let statusTitleColor: UIColor = .enaColor(for: .textPrimary1)
	let statusLineColor: UIColor = .enaColor(for: .riskHigh)
	let statusImageName = "Illu_Home_PositivTestErgebnis"

	let noteTitle = AppStrings.Home.findingPositiveCardNoteTitle

	let buttonTitle = AppStrings.Home.findingPositiveCardButton

	let iconColor: UIColor = .enaColor(for: .riskHigh)

	var homeItemViewModels: [HomeItemViewModel] {
		[
			HomeImageItemViewModel(
				title: AppStrings.Home.findingPositivePhoneItemTitle,
				titleColor: titleColor,
				iconImageName: "Icons - Hotline",
				iconTintColor: iconColor,
				color: .clear,
				separatorColor: .clear,
				containerInsets: .init(top: 10.0, left: 0.0, bottom: 10.0, right: 0)
			),
			HomeImageItemViewModel(
				title: AppStrings.Home.findingPositiveHomeItemTitle,
				titleColor: titleColor,
				iconImageName: "Icons - Home",
				iconTintColor: iconColor,
				color: .clear,
				separatorColor: .clear,
				containerInsets: .init(top: 10.0, left: 0.0, bottom: 10.0, right: 0)
			),
			HomeImageItemViewModel(
				title: AppStrings.Home.findingPositiveShareItemTitle,
				titleColor: titleColor,
				iconImageName: "Icons - Warnen",
				iconTintColor: iconColor,
				color: .clear,
				separatorColor: .clear,
				containerInsets: .init(top: 10.0, left: 0.0, bottom: 10.0, right: 0)
			)
		]
	}

}
