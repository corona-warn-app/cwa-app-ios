//
// 🦠 Corona-Warn-App
//

import UIKit

struct HomeShownPositiveTestResultCellModel {

	// MARK: - Internal

	let coronaTestType: CoronaTestType

	let backgroundColor = UIColor.enaColor(for: .background)

	var title: String {
		switch coronaTestType {
		case .pcr:
			return AppStrings.Home.TestResult.pcrTitle
		case .antigen:
			return AppStrings.Home.TestResult.antigenTitle
		}
	}

	let titleColor: UIColor = .enaColor(for: .textPrimary1)

	let statusTitle = AppStrings.Home.TestResult.ShownPositive.statusTitle
	let statusSubtitle = AppStrings.Home.TestResult.ShownPositive.statusSubtitle
	let statusTitleColor: UIColor = .enaColor(for: .textPrimary1)
	let statusLineColor: UIColor = .enaColor(for: .riskHigh)
	let statusImageName = "Illu_Home_PositivTestErgebnis"

	let noteTitle = AppStrings.Home.TestResult.ShownPositive.noteTitle

	let buttonTitle = AppStrings.Home.TestResult.ShownPositive.button

	let iconColor: UIColor = .enaColor(for: .riskHigh)

	var homeItemViewModels: [HomeItemViewModel] {
		[
			HomeImageItemViewModel(
				title: AppStrings.Home.TestResult.ShownPositive.phoneItemTitle,
				titleColor: titleColor,
				iconImageName: "Icons - Hotline",
				iconTintColor: iconColor,
				color: .clear,
				separatorColor: .clear,
				containerInsets: .init(top: 10.0, left: 0.0, bottom: 10.0, right: 0)
			),
			HomeImageItemViewModel(
				title: AppStrings.Home.TestResult.ShownPositive.homeItemTitle,
				titleColor: titleColor,
				iconImageName: "Icons - Home",
				iconTintColor: iconColor,
				color: .clear,
				separatorColor: .clear,
				containerInsets: .init(top: 10.0, left: 0.0, bottom: 10.0, right: 0)
			),
			HomeImageItemViewModel(
				title: AppStrings.Home.TestResult.ShownPositive.shareItemTitle,
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
