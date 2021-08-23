////
// 🦠 Corona-Warn-App
//

import UIKit

struct CheckinsOverviewEmptyStateViewModel: EmptyStateViewModel {

	// MARK: - Internal

	let image = UIImage(named: "Illu_Checkins_Empty")
	let title = AppStrings.Checkins.Overview.emptyTitle
	let description = AppStrings.Checkins.Overview.emptyDescription
	let imageDescription = AppStrings.Checkins.Overview.emptyImageDescription

}
