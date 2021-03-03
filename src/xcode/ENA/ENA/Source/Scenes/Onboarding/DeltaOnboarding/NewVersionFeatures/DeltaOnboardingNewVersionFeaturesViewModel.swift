//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

struct DeltaOnboardingNewVersionFeaturesViewModel {
	
	// MARK: - Init

	init() {
		
		// ADD NEW FEATURES HERE
		
		self.featureVersion = "1.14"
		
		// Additional Diary functions
		self.newVersionFeatures.append(
			NewVersionFeature(title: AppStrings.NewVersionFeatures.feature114AdditionalDiaryFunctionsTitle, description: AppStrings.NewVersionFeatures.feature114AdditionalDiaryFunctionsDescription)
		)
		
		// Direct diary access
		self.newVersionFeatures.append(
			NewVersionFeature(title: AppStrings.NewVersionFeatures.feature114DirectAccessDiaryTitle, description: AppStrings.NewVersionFeatures.feature114DirectAccessDiaryDescription)
		)
		
		// More Detais Risk Status
		self.newVersionFeatures.append(
			NewVersionFeature(title: AppStrings.NewVersionFeatures.feature114MoreDetailsRiskStatusTitle, description: AppStrings.NewVersionFeatures.feature114MoreDetailsRiskStatusDescription)
		)
		
		// Screenshots
		self.newVersionFeatures.append(
			NewVersionFeature(title: AppStrings.NewVersionFeatures.feature114ScreenshotsTitle, description: AppStrings.NewVersionFeatures.feature114ScreenshotsDescription, internalId: "114-screenshots")
		)
		
	}

	// MARK: - Internal
	
	let featureVersion: String

	var dynamicTableViewModel: DynamicTableViewModel {
		DynamicTableViewModel.with {
			$0.add(
				.section(
					cells: [
						.subheadline(text: "\(AppStrings.NewVersionFeatures.release) \(self.featureVersion)",
									 color: UIColor.enaColor(for: .textPrimary1), accessibilityIdentifier: AccessibilityIdentifiers.DeltaOnboarding.newVersionFeaturesVersionInfo)
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
						.subheadline(text: AppStrings.NewVersionFeatures.generalDescription, color: UIColor.enaColor(for: .textPrimary2), accessibilityIdentifier: AccessibilityIdentifiers.DeltaOnboarding.newVersionFeaturesGeneralDescription)
					]
				)
			)
			$0.add(
				.section(
					separators: .none,
					cells: buildNewFeaturesCells()
				)
			)
			$0.add(
				.section(
					cells: [
						.body(text: AppStrings.NewVersionFeatures.aboutAppInformation,
							  color: .enaColor(for: .textPrimary1),
							  accessibilityIdentifier: AccessibilityIdentifiers.DeltaOnboarding.newVersionFeaturesGeneralAboutAppInformation)
					]
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
			
			if feature.internalId != nil && feature.internalId == "114-screenshots" {
				let featureBulletPoint = NSMutableAttributedString(string: feature.title + "\n\t", attributes: boldTextAttribute)
				featureBulletPoint.append(NSAttributedString(string: feature.description, attributes: normalTextAttribute))
				cells.append(.bulletPoint(attributedText: featureBulletPoint))
				cells.append(.link(placeholder: "\t\(AppStrings.NewVersionFeatures.feature114ScreenshotWebSiteURLDisplayText)", link: AppStrings.NewVersionFeatures.feature114ScreenshotWebSiteURL, font: .body, style: .body, accessibilityIdentifier: ""))
				Log.debug("[App Screenshots feature] The screenshot URL is the following: \(AppStrings.NewVersionFeatures.feature114ScreenshotWebSiteURL)")
			} else {
				let featureBulletPoint = NSMutableAttributedString(string: feature.title + "\n\t", attributes: boldTextAttribute)
				featureBulletPoint.append(NSAttributedString(string: feature.description, attributes: normalTextAttribute))
				featureBulletPoint.append(NSAttributedString(string: "\n", attributes: normalTextAttribute))
				cells.append(.bulletPoint(attributedText: featureBulletPoint))
			}
		}
		return cells
	}
}
