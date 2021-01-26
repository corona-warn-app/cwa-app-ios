//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

extension AppInformationViewController {

	static let imprintViewModel = AppInformationImprintViewModel(preferredLocalization: Bundle.main.preferredLocalizations.first ?? "de")

	static let model: [Category: AppInformationCellModel] = [
		.about: AppInformationCellModel(
			text: AppStrings.AppInformation.aboutNavigation,
			accessibilityIdentifier: AccessibilityIdentifiers.AppInformation.aboutNavigation,
			action: .push(model: AppInformationModel.aboutModel, withTitle:  AppStrings.AppInformation.aboutNavigation)
		),
		.faq: AppInformationCellModel(
			text: AppStrings.AppInformation.faqNavigation,
			accessibilityIdentifier: AccessibilityIdentifiers.AppInformation.faqNavigation,
			action: .safari
		),
		.terms: AppInformationCellModel(
			text: AppStrings.AppInformation.termsTitle,
			accessibilityIdentifier: AccessibilityIdentifiers.AppInformation.termsNavigation,
			action: .push(model: AppInformationModel.termsModel, withTitle: AppStrings.AppInformation.termsNavigation)
		),
		.privacy: AppInformationCellModel(
			text: AppStrings.AppInformation.privacyNavigation,
			accessibilityIdentifier: AccessibilityIdentifiers.AppInformation.privacyNavigation,
			action: .push(model: AppInformationModel.privacyModel, withTitle: AppStrings.AppInformation.privacyNavigation)
		),
		.legal: AppInformationCellModel(
			text: AppStrings.AppInformation.legalNavigation,
			accessibilityIdentifier: AccessibilityIdentifiers.AppInformation.legalNavigation,
			action: .push(model: legalModel, separators: true, withTitle: AppStrings.AppInformation.legalNavigation)
		),
		.contact: AppInformationCellModel(
			text: AppStrings.AppInformation.contactNavigation,
			accessibilityIdentifier: AccessibilityIdentifiers.AppInformation.contactNavigation,
			action: .push(model: AppInformationModel.contactModel, withTitle: AppStrings.AppInformation.contactNavigation)
		),
		.imprint: AppInformationCellModel(
			text: AppStrings.AppInformation.imprintNavigation,
			accessibilityIdentifier: AccessibilityIdentifiers.AppInformation.imprintNavigation,
			action: .push(model: imprintViewModel.dynamicTable, withTitle: AppStrings.AppInformation.imprintNavigation)
		),
		.versionInfo: AppInformationCellModel(
			text: AppStrings.AppInformation.newFeaturesNavigation,
			accessibilityIdentifier: AccessibilityIdentifiers.AppInformation.newFeaturesNavigation,
			action: .push(viewController: DeltaOnboardingNewVersionFeaturesViewController(hasCloseButton: false))
		)
	]

}
