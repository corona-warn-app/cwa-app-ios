//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

struct DeltaOnboardingNewVersionFeaturesViewModel {
	
	// MARK: - Init

	init() {
		// Exposure History Feature
		self.newVersionFeatures.append(
			NewVersionFeature(title: AppStrings.NewVersionFeatures.feature112ExposureHistoryTitle, description: AppStrings.NewVersionFeatures.feature112ExposureHistoryDescription)
		)
		
		// iOS 12.5 Support
		self.newVersionFeatures.append(
			NewVersionFeature( title: AppStrings.NewVersionFeatures.feature112iOS125SupportTitle, description: AppStrings.NewVersionFeatures.feature112iOS125SupportDescription)
		)
		
		// Statistics
		self.newVersionFeatures.append(
			NewVersionFeature(title: AppStrings.NewVersionFeatures.feature112StatisticsTitle, description: AppStrings.NewVersionFeatures.feature112StatisticsDescription)
		)
	}

	// MARK: - Internal
	
	typealias DynamicNewVersionFeatureCell = DynamicLegalCell

	var dynamicTableViewModel: DynamicTableViewModel {
		DynamicTableViewModel.with {
			$0.add(
				.section(
					cells: [
						.body(text: AppStrings.NewVersionFeatures.release + " " + Bundle.main.appVersion)
					]
				)
			)
			$0.add(
				.section(
					header: .image(
						UIImage(named: "Illu_NewVersion_Features"),
						accessibilityLabel: AppStrings.NewVersionFeatures.accImageLabel,
						accessibilityIdentifier: AccessibilityIdentifiers.DeltaOnboarding.newVersionFeaturesAccImageDescription,
						height: 250
					),
					cells: [
						.body(text: AppStrings.NewVersionFeatures.generalDescription)
					]
				)
			)
			$0.add(
				.section(
					separators: .none,
//					cells: [
//						.bulletPoint(text: AppStrings.ExposureSubmissionResult.furtherInfos_ListItem1, spacing: .large),
//					]
					cells: buildNewFeaturesCells()
				)
			)
			
		}
	}

	// MARK: - Private
	
	private var newVersionFeatures: [NewVersionFeature] = []
	
	private func buildNewFeaturesCells() -> [DynamicCell] {
		var cells: [DynamicCell] = []
		let boldTextAttribute: [NSAttributedString.Key: Any] = [
			NSAttributedString.Key.font: UIFont.enaFont(for: .body, weight: .bold)
		]
		let normalTextAttribute: [NSAttributedString.Key: Any] = [
			NSAttributedString.Key.font: UIFont.enaFont(for: .body)
		]
		
		for feature in newVersionFeatures {
			let featureBulletPoint = NSMutableAttributedString(string: feature.title+"\n\t", attributes: boldTextAttribute)
			featureBulletPoint.append(NSAttributedString(string: feature.description, attributes: normalTextAttribute))
			cells.append(.bulletPoint(attributedText: featureBulletPoint))
		}
		return cells
	}
}
