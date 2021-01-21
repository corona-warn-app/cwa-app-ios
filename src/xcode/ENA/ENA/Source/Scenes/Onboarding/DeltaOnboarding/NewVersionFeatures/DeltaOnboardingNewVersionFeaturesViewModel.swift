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

	var dynamicTableViewModel: DynamicTableViewModel {
		DynamicTableViewModel.with {
			$0.add(
				.section(
					cells: [
						.title1(
							text: AppStrings.NewVersionFeatures.title,
							accessibilityIdentifier: AccessibilityIdentifiers.DeltaOnboarding.sectionTitle
						),
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
					cells: buildNewFeaturesCells()
				)
			)
			
		}
	}

	// MARK: - Private
	
	private var newVersionFeatures: [NewVersionFeature] = []

	private func buildNewFeaturesCells() -> [DynamicCell] {
		var cells: [DynamicCell] = []
		for feature in newVersionFeatures {
			cells.append(.headline(text: feature.title))
			cells.append(.body(text: feature.description))
		}
		return cells
	}

//	private func buildCountryCells() -> [DynamicCell] {
//		var cells: [DynamicCell] = []
//		if supportedCountries.isEmpty {
//			cells = [
//				.headline(
//					text: AppStrings.DeltaOnboarding.participatingCountriesListUnavailableTitle,
//					accessibilityIdentifier: AccessibilityIdentifiers.DeltaOnboarding.participatingCountriesListUnavailableTitle
//				),
//				.body(
//					text: AppStrings.DeltaOnboarding.participatingCountriesListUnavailable,
//						 accessibilityIdentifier: AccessibilityIdentifiers.DeltaOnboarding.participatingCountriesListUnavailable
//					 )
//			]
//		} else {
//			cells.append(.headline(
//				text: AppStrings.ExposureSubmissionWarnOthers.supportedCountriesTitle,
//						 accessibilityIdentifier: nil
//					 ))
//		}
//		return cells
//	}
}
