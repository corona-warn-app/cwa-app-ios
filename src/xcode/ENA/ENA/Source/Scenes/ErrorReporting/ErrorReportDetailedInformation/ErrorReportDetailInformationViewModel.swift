////
// 🦠 Corona-Warn-App
//

import UIKit

final class ErrorReportDetailInformationViewModel {
		
	var dynamicTableViewModel: DynamicTableViewModel {
		DynamicTableViewModel.with {
			$0.add(
				.section(
					cells: [
						.title1(text: AppStrings.ErrorReport.detailedInformationTitle, accessibilityIdentifier: "AppStrings.ErrorReport.detailedInformationTitle"),
						.space(height: 20),
						.custom(
							withIdentifier: DataDonationDetailsViewController.CustomCellReuseIdentifiers.roundedCell,
							configure: { _, cell, _ in
								guard let cell = cell as? DynamicTableViewRoundedCell else { return }
								// grey box with legal text:
								cell.configure(
									title: NSMutableAttributedString(
										string: AppStrings.ErrorReport.detailedInfo_Headline
									),
									body: NSMutableAttributedString(
										string: AppStrings.ErrorReport.detailedInfo_Content1
									),
									textColor: .textPrimary1,
									bgColor: .separator
								)
							}
						),
						.space(height: 20),
						.headline(text: AppStrings.ErrorReport.detailedInfo_Subheadline, accessibilityIdentifier: "AppStrings.ErrorReport.detailedInfo_Subheadline"),
						.body(text: AppStrings.ErrorReport.detailedInfo_Content2, accessibilityIdentifier: "AppStrings.ErrorReport.detailedInfo_Content2")
					]
				)
			)
		}
	}
	
}
