////
// 🦠 Corona-Warn-App
//

import UIKit

struct RecycleBinEmptyStateViewModel: EmptyStateViewModel {

	// MARK: - Internal

	let image = UIImage(named: "Illu_RecycleBin_Empty")
	let title = AppStrings.TraceLocations.Overview.emptyTitle
	let description = AppStrings.TraceLocations.Overview.emptyDescription
	let imageDescription = AppStrings.TraceLocations.Overview.emptyImageDescription

}
