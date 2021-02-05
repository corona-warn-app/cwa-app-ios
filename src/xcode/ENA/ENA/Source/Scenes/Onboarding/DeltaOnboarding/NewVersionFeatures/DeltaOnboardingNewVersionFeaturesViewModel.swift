//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

struct DeltaOnboardingNewVersionFeaturesViewModel {
	
	// MARK: - Init

	init() {
		
		// ADD NEW FEATURES HERE
		
		self.featureVersion = "1.13"
		
		// RKI Survey
		self.newVersionFeatures.append(
			NewVersionFeature(title: AppStrings.NewVersionFeatures.feature113RkiSurveyTitle, description: AppStrings.NewVersionFeatures.feature113RkiSurveyDescription)
		)
		
		// Data Donation
		self.newVersionFeatures.append(
			NewVersionFeature(title: AppStrings.NewVersionFeatures.feature113DataDonationTitle, description: AppStrings.NewVersionFeatures.feature113DataDonationDescription)
		)
		
		// Enhanced Risk Cards
		self.newVersionFeatures.append(
			NewVersionFeature(title: AppStrings.NewVersionFeatures.feature113RiskCardTitle, description: AppStrings.NewVersionFeatures.feature113RiskCardDescription)
		)
		
		// Risk Determination Random ID
		self.newVersionFeatures.append(
			NewVersionFeature(title: AppStrings.NewVersionFeatures.feature113RiskDeterminationRandomIdTitle, description: AppStrings.NewVersionFeatures.feature113RiskDeterminationRandomIdDescription)
		)
		
		// Introduction of the tab bar
		self.newVersionFeatures.append(
			NewVersionFeature(title: AppStrings.NewVersionFeatures.feature113NewTabBarTitle, description: AppStrings.NewVersionFeatures.feature113NewTabBarDescription)
		)
		
		// Additional Information about test procedure
		self.newVersionFeatures.append(
			NewVersionFeature(title: AppStrings.NewVersionFeatures.feature113AddInfoAboutTestProcedureTitle, description: AppStrings.NewVersionFeatures.feature113AddInfoAboutTestProcedureDescription)
		)
	}

	// MARK: - Internal
	
	typealias DynamicNewVersionFeatureCell = DynamicLegalCell
	
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
			let featureBulletPoint = NSMutableAttributedString(string: feature.title + "\n\t", attributes: boldTextAttribute)
			featureBulletPoint.append(NSAttributedString(string: feature.description, attributes: normalTextAttribute))
			featureBulletPoint.append(NSAttributedString(string: "\n", attributes: normalTextAttribute))
			cells.append(.bulletPoint(attributedText: featureBulletPoint))
		}
		return cells
	}
}
