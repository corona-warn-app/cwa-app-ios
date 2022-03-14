//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

struct DeltaOnboardingNewVersionFeaturesViewModel {
	
	// MARK: - Init

	init() {
		
		// ADD NEW FEATURES HERE
		
		self.featureVersion = "2.20"
		
		self.newVersionFeatures.append(
			// High Risk Indicator Shortened
			NewVersionFeature(title: AppStrings.NewVersionFeatures.feature220HighRiskShortenedTitle, description: AppStrings.NewVersionFeatures.feature220HighRiskShortenedTitle)
		)
		
		self.newVersionFeatures.append(
			// Display Risk Positive Result
			NewVersionFeature(title: AppStrings.NewVersionFeatures.feature220DisplayRiskPositiveResultTitle, description: AppStrings.NewVersionFeatures.feature220DisplayRiskPositiveResultDescription)
		)
		
		self.newVersionFeatures.append(
			// Notification Risk Encounter
			NewVersionFeature(title: AppStrings.NewVersionFeatures.feature220NotificateRiskEncounterTitle, description: AppStrings.NewVersionFeatures.feature220NotificateRiskEncounterDescription)
		)
		
		self.newVersionFeatures.append(
			// Notification Status Change
			NewVersionFeature(title: AppStrings.NewVersionFeatures.feature220NotificationStatusChangeTitle, description: AppStrings.NewVersionFeatures.feature220NotificationStatusChangeDescription)
		)
		
		self.newVersionFeatures.append(
			// Recovery Certificates Details
			NewVersionFeature(title: AppStrings.NewVersionFeatures.feature220RecoveryCertificatesDetailsTitle, description: AppStrings.NewVersionFeatures.feature220RecoveryCertificatesDetailsDescription)
		)
		
		self.newVersionFeatures.append(
			// Remove QR Code
			NewVersionFeature(title: AppStrings.NewVersionFeatures.feature220RemoveQRCodeTitle, description: AppStrings.NewVersionFeatures.feature220RemoveQRCodeDescription)
		)
	}

	// MARK: - Internal
	
	let featureVersion: String

	var dynamicTableViewModel: DynamicTableViewModel {
		DynamicTableViewModel.with {
			$0.add(
				.section(
					cells: [
						.subheadline(
							text: "\(AppStrings.NewVersionFeatures.release) \(self.featureVersion)",
							color: UIColor.enaColor(for: .textPrimary1), accessibilityIdentifier: AccessibilityIdentifiers.DeltaOnboarding.newVersionFeaturesVersionInfo
						)
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
						.body(
							text: AppStrings.NewVersionFeatures.aboutAppInformation,
							color: .enaColor(for: .textPrimary1),
							accessibilityIdentifier: AccessibilityIdentifiers.DeltaOnboarding.newVersionFeaturesGeneralAboutAppInformation
						)
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
			let featureBulletPoint = NSMutableAttributedString(string: feature.title + "\n\t", attributes: boldTextAttribute)
			featureBulletPoint.addAttributes(boldTextAttribute, range: NSRange(location: 0, length: feature.title.count))
			featureBulletPoint.append(NSAttributedString(string: feature.description, attributes: normalTextAttribute))
			featureBulletPoint.append(NSAttributedString(string: "\n", attributes: normalTextAttribute))
			cells.append(.bulletPoint(attributedText: featureBulletPoint))
		}
		return cells
	}
}
