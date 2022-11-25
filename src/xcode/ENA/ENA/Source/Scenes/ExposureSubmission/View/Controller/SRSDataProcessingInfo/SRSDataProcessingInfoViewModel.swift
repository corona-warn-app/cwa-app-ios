//
// 🦠 Corona-Warn-App
//

import UIKit

struct SRSDataProcessingInfoViewModel {
	
	// MARK: - Internal
	
	var dynamicTableViewModel: DynamicTableViewModel {
		var model = DynamicTableViewModel([])
		model.add(
			.section(cells: [
				.title1(text: AppStrings.SRSConsentScreen.dataProcessingDetailInfo)
			])
		)
		model.add(
			.section(cells: [
				.legalExtendedDataDonation(
					title: NSAttributedString(string: AppStrings.SRSDataProcessingInfo.title),
					description: NSAttributedString(
						string: AppStrings.SRSDataProcessingInfo.description,
						attributes: [.font: UIFont.preferredFont(forTextStyle: .body)]
					),
					accessibilityIdentifier: AccessibilityIdentifiers.SRSDataProcessingDetailInfo.content,
					configure: { _, cell, _ in
						cell.backgroundColor = .enaColor(for: .background)
					}
				)
			])
		)
		
		return model
	}
}
