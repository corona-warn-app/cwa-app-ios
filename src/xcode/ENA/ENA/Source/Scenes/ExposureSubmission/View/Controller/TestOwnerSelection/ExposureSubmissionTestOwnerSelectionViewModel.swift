//
// 🦠 Corona-Warn-App
//

import Foundation

class ExposureSubmissionTestOwnerSelectionViewModel {
	
	// MARK: - Init

	init(
		onTestOwnerSelection: @escaping(TestOwner) -> Void
	) {
		self.onTestOwnerSelection = onTestOwnerSelection
	}
	
	// MARK: - Internal

	var dynamicTableViewModel: DynamicTableViewModel = DynamicTableViewModel([])
	
	// MARK: - Private

	private let onTestOwnerSelection: (TestOwner) -> Void
}
