//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

struct DeltaOnboardingNewVersionFeaturesViewModel {
	
	// MARK: - Init

	init() {
		
		// ADD NEW FEATURES HERE
		
		self.featureVersion = "2.7"
		
		// Signature Check
		self.newVersionFeatures.append(
			NewVersionFeature(title: AppStrings.NewVersionFeatures.feature27SigCheckTitle, description: AppStrings.NewVersionFeatures.feature27SigCheckDescription)
		)
		
		// Technical Validity
		self.newVersionFeatures.append(
			NewVersionFeature(title: AppStrings.NewVersionFeatures.feature27technicalValidityTitle, description: AppStrings.NewVersionFeatures.feature27technicalValidityDescription, internalId: "27FAQ_URL")
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

if feature.internalId != nil && feature.internalId == "27FAQ_URL" {
				let featureBulletPoint = NSMutableAttributedString(string: feature.title + "\n\t", attributes: boldTextAttribute)
				featureBulletPoint.append(NSAttributedString(string: feature.description, attributes: normalTextAttribute))
				cells.append(.bulletPoint(attributedText: featureBulletPoint))
				cells.append(.link(placeholder: "\t\(AppStrings.NewVersionFeatures.feature27FAQ_URLDisplayText)", link: AppStrings.NewVersionFeatures.feature27FAQ_URL, font: .body, style: .body, accessibilityIdentifier: ""))
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
