//
// 🦠 Corona-Warn-App
//

import UIKit

struct HomeThankYouCellModel {

	// MARK: - Internal

	let title = AppStrings.Home.thankYouCardTitle
	let titleColor: UIColor = .enaColor(for: .textPrimary1)

	let imageName = "Illu_Submission_VielenDank"

	let body = AppStrings.Home.thankYouCardBody
	let noteTitle = AppStrings.Home.thankYouCardNoteTitle
	let furtherInfoTitle = AppStrings.Home.thankYouCardFurtherInfoItemTitle

	let backgroundColor = UIColor.enaColor(for: .background)
	let iconColor: UIColor = .enaColor(for: .riskHigh)

	let reenableTitle = AppStrings.Home.reenableCardTitle
	let reenableBody = AppStrings.Home.reenableCardBody
	let reenableButtonTitle = AppStrings.Home.reenableCardButtonTitle

	let reenableTestResultTitle = AppStrings.Home.reenableCardTestResultTitle
	let reenableTestResultSubtitle = AppStrings.Home.reenableCardTestResultSubtitle
	let reenableTestResultRegistration = AppStrings.Home.reenableCardTestResultRegistration

	let testResultTimestamp: Int64?

	var homeItemViewModels: [HomeItemViewModel] {
		[
			HomeImageItemViewModel(
				title: AppStrings.Home.thankYouCardPhoneItemTitle,
				titleColor: titleColor,
				iconImageName: "Icons - Hotline",
				iconTintColor: iconColor,
				color: .clear,
				separatorColor: .clear,
				containerInsets: .init(top: 10.0, left: 0.0, bottom: 10.0, right: 0)
			),
			HomeImageItemViewModel(
				title: AppStrings.Home.thankYouCardHomeItemTitle,
				titleColor: titleColor,
				iconImageName: "Icons - Home",
				iconTintColor: iconColor,
				color: .clear,
				separatorColor: .clear,
				containerInsets: .init(top: 10.0, left: 0.0, bottom: 10.0, right: 0)
			)
		]
	}

	var furtherHomeItemViewModels: [HomeItemViewModel] {
		[
			HomeListItemViewModel(text: AppStrings.Home.thankYouCard14DaysItemTitle, textColor: titleColor),
			HomeListItemViewModel(text: AppStrings.Home.thankYouCardContactsItemTitle, textColor: titleColor),
			HomeListItemViewModel(text: AppStrings.Home.thankYouCardAppItemTitle, textColor: titleColor),
			HomeListItemViewModel(text: AppStrings.Home.thankYouCardNoSymptomsItemTitle, textColor: titleColor)
		]
	}

}
