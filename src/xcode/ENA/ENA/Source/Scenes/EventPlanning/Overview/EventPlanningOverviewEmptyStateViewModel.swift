////
// 🦠 Corona-Warn-App
//

import UIKit

struct EventPlanningOverviewEmptyStateViewModel: EmptyStateViewModel {

	// MARK: - Internal

	let image = UIImage(named: "Illu_EventPlanning_Empty")
	let title = AppStrings.EventPlanning.Overview.emptyTitle
	let description = AppStrings.EventPlanning.Overview.emptyDescription
	let imageDescription = AppStrings.EventPlanning.Overview.emptyImageDescription

}
