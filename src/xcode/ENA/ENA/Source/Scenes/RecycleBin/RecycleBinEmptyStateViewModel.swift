////
// 🦠 Corona-Warn-App
//

import UIKit

struct RecycleBinEmptyStateViewModel: EmptyStateViewModel {

	// MARK: - Internal

	let image = UIImage(named: "Illu_RecycleBin_Empty")
	let title = AppStrings.RecycleBin.EmptyState.title
	let description = AppStrings.RecycleBin.EmptyState.description
	let imageDescription = AppStrings.RecycleBin.EmptyState.imageDescription

}
