//
// 🦠 Corona-Warn-App
//

import UIKit

struct AntigenTestProfileOverviewEmptyStateViewModel: EmptyStateViewModel {
	
	// MARK: - Internal

	let image = UIImage(named: "Illu_Certificate_Empty")
	let title = AppStrings.AntigenProfile.Overview.emptyTitle
	let description = AppStrings.AntigenProfile.Overview.emptyDescription
	let imageDescription = AppStrings.AntigenProfile.Overview.emptyImageDescription

}
