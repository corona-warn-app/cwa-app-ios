////
// 🦠 Corona-Warn-App
//

import UIKit

final class DataDonationDetailsViewModel {
	// MARK: - Init
	
	// MARK: - Overrides
	
	// MARK: - Protocol <#Name#>
	
	// MARK: - Public
	
	// MARK: - Internal
	
	var dynamicTableViewModel: DynamicTableViewModel {
		DynamicTableViewModel.with {
			
			$0.add(
				.section(
					cells: [
						.title1(text: AppStrings.DataDonation.DetailedInfo.title, accessibilityIdentifier: "XXX"),
						.space(height: 20),
						.custom(
							withIdentifier: DataDonationDetailsViewController.CustomCellReuseIdentifiers.roundedCell,
							configure: { _, cell, _ in
								guard let cell = cell as? DynamicTableViewRoundedCell else { return }
								
								cell.configure(
									title: NSMutableAttributedString(
										string: AppStrings.DataDonation.DetailedInfo.legalHeadline
									),
									body: NSMutableAttributedString(
										string: AppStrings.DataDonation.DetailedInfo.legalParagraph
									),
									textColor: .textPrimary1,
									bgColor: .separator
								)
							}
						),
						.space(height: 8),
						.body(text: AppStrings.DeltaOnboarding.termsDescription1)
					]
				)
			)
		}
	}
	
	// MARK: - Private
}
