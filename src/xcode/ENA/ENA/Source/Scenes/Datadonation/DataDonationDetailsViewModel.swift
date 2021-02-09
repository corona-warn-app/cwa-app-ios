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
						self.cells[3],
						.body(text: AppStrings.DataDonation.DetailedInfo.paragraph2, accessibilityIdentifier: "XXX"),
						.bulletPoint(text: AppStrings.DataDonation.DetailedInfo.bullet05_text),
						.bulletPoint(text: AppStrings.DataDonation.DetailedInfo.bullet06_text),
						.bulletPoint(text: AppStrings.DataDonation.DetailedInfo.bullet07_text),
						.bulletPoint(text: AppStrings.DataDonation.DetailedInfo.bullet08_text),
						.body(text: AppStrings.DataDonation.DetailedInfo.paragraph3, accessibilityIdentifier: "XXX"),
						.bulletPoint(text: AppStrings.DataDonation.DetailedInfo.bullet09_text),
						.bulletPoint(text: AppStrings.DataDonation.DetailedInfo.bullet10_text),
						.bulletPoint(text: AppStrings.DataDonation.DetailedInfo.bullet11_text),
						.bulletPoint(text: AppStrings.DataDonation.DetailedInfo.bullet12_text),
						.bulletPoint(text: AppStrings.DataDonation.DetailedInfo.bullet13_text),
						.body(text: AppStrings.DataDonation.DetailedInfo.paragraph4, accessibilityIdentifier: "XXX"),
						.bulletPoint(text: AppStrings.DataDonation.DetailedInfo.bullet14_text),
						.bulletPoint(text: AppStrings.DataDonation.DetailedInfo.bullet15_text),
						.bulletPoint(text: AppStrings.DataDonation.DetailedInfo.bullet16_text),
						.bulletPoint(text: AppStrings.DataDonation.DetailedInfo.bullet17_text),
						.bulletPoint(text: AppStrings.DataDonation.DetailedInfo.bullet18_text),
						.bulletPoint(text: AppStrings.DataDonation.DetailedInfo.bullet19_text),
						.bulletPoint(text: AppStrings.DataDonation.DetailedInfo.bullet20_text),
						.body(text: AppStrings.DataDonation.DetailedInfo.paragraph5, accessibilityIdentifier: "XXX"),
						.bulletPoint(text: AppStrings.DataDonation.DetailedInfo.bullet21_text),
						.bulletPoint(text: AppStrings.DataDonation.DetailedInfo.bullet22_text),
						.bulletPoint(text: AppStrings.DataDonation.DetailedInfo.bullet23_text),
						.body(text: AppStrings.DataDonation.DetailedInfo.paragraph6, accessibilityIdentifier: "XXX")
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
