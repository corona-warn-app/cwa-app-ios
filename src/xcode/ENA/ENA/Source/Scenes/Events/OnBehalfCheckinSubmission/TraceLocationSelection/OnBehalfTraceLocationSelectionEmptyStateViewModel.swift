////
// 🦠 Corona-Warn-App
//

import UIKit

struct OnBehalfTraceLocationSelectionEmptyStateViewModel: EmptyStateViewModel {

	// MARK: - Internal

	let image = UIImage(named: "Illu_OnBehalf_Empty")
	let title = AppStrings.OnBehalfCheckinSubmission.TraceLocationSelection.EmptyState.title
	let description = AppStrings.OnBehalfCheckinSubmission.TraceLocationSelection.EmptyState.description
	let imageDescription = AppStrings.OnBehalfCheckinSubmission.TraceLocationSelection.EmptyState.imageDescription

}
