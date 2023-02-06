//
// 🦠 Corona-Warn-App
//

import UIKit

struct AntigenTestProfileOverviewEmptyStateViewModel: EmptyStateViewModel {
	
	// MARK: - Internal

	let image = UIImage(named: "Illu_AntigenTestProfile_Empty")
	let title = AppStrings.AntigenProfile.Overview.emptyTitle
	let description = AppStrings.AntigenProfile.Overview.emptyDescription
	let imageDescription = AppStrings.AntigenProfile.Overview.emptyImageDescription
	let titleAccessibilityIdentifier: String? = AccessibilityIdentifiers.AntigenProfile.Overview.emptyStateTitle
	let descriptionAccessibilityIdentifier: String? = AccessibilityIdentifiers.AntigenProfile.Overview.emptyStateDescription
	let imageAccessibilityIdentifier: String? = AccessibilityIdentifiers.AntigenProfile.Overview.emptyStateImage

}
