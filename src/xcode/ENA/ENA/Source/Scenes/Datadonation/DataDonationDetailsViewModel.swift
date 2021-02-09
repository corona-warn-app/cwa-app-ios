////
// 🦠 Corona-Warn-App
//

import UIKit

final class DataDonationDetailsViewModel {
	// MARK: - Init
	init() {
		setUp()
	}
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
						.title2(text: AppStrings.DataDonation.DetailedInfo.headline, accessibilityIdentifier: "XXX"),
						.space(height: 8),
						.body(text: AppStrings.DataDonation.DetailedInfo.paragraph1, accessibilityIdentifier: "XXX"),
						.space(height: 8),
						self.cells[0],
						self.cells[1],
						self.cells[2],
						self.cells[3]
					]
				)
			)
		}
	}
	
	// MARK: - Private
	
//	private var newVersionFeatures: [NewVersionFeature] = []
	var cells: [DynamicCell] = []
	let boldTextAttribute: [NSAttributedString.Key: Any] = [
		NSAttributedString.Key.font: UIFont.enaFont(for: .body, weight: .bold)
	]
	let normalTextAttribute: [NSAttributedString.Key: Any] = [
		NSAttributedString.Key.font: UIFont.enaFont(for: .body)
	]
	
	func setUp() {
		var featureBulletPoint = NSMutableAttributedString(string: "\(AppStrings.DataDonation.DetailedInfo.bullet01_title)" + "\n\t", attributes: boldTextAttribute)
		featureBulletPoint.append(NSAttributedString(string: AppStrings.DataDonation.DetailedInfo.bullet01_text, attributes: normalTextAttribute))
		featureBulletPoint.append(NSAttributedString(string: "\n", attributes: normalTextAttribute))
		cells.append(.bulletPoint(attributedText: featureBulletPoint))
		
		featureBulletPoint = NSMutableAttributedString(string: "\(AppStrings.DataDonation.DetailedInfo.bullet02_title)" + "\n\t", attributes: boldTextAttribute)
		featureBulletPoint.append(NSAttributedString(string: AppStrings.DataDonation.DetailedInfo.bullet02_text, attributes: normalTextAttribute))
		featureBulletPoint.append(NSAttributedString(string: "\n", attributes: normalTextAttribute))
		cells.append(.bulletPoint(attributedText: featureBulletPoint))
		
		featureBulletPoint = NSMutableAttributedString(string: "\(AppStrings.DataDonation.DetailedInfo.bullet03_title)" + "\n\t", attributes: boldTextAttribute)
		featureBulletPoint.append(NSAttributedString(string: AppStrings.DataDonation.DetailedInfo.bullet03_text, attributes: normalTextAttribute))
		featureBulletPoint.append(NSAttributedString(string: "\n", attributes: normalTextAttribute))
		cells.append(.bulletPoint(attributedText: featureBulletPoint))
		
		featureBulletPoint = NSMutableAttributedString(string: "\(AppStrings.DataDonation.DetailedInfo.bullet04_title)" + "\n\t", attributes: boldTextAttribute)
		featureBulletPoint.append(NSAttributedString(string: AppStrings.DataDonation.DetailedInfo.bullet04_text, attributes: normalTextAttribute))
		featureBulletPoint.append(NSAttributedString(string: "\n", attributes: normalTextAttribute))
		cells.append(.bulletPoint(attributedText: featureBulletPoint))
		
	}
	
}
