////
// 🦠 Corona-Warn-App
//

import UIKit

struct TraceLocationsOverviewEmptyStateViewModel: EmptyStateViewModel {

	// MARK: - Internal

	let image = UIImage(named: "Illu_TraceLocations_Empty")
	let title = AppStrings.TraceLocations.Overview.emptyTitle
	let description = AppStrings.TraceLocations.Overview.emptyDescription
	let imageDescription = AppStrings.TraceLocations.Overview.emptyImageDescription

}
