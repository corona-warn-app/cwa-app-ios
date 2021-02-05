////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

final class SelectValueViewModel {

	// MARK: - Init

	init(_ allValues: [String], preselected: String?) {
		self.allValues = ["keine Angabe"] + allValues
		if let preselected = preselected {
			self.selectedIndex = self.allValues.firstIndex(of: preselected)
		} else {
			self.selectedIndex = 0
		}
	}

	// MARK: - Overrides

	// MARK: - Protocol <#Name#>

	// MARK: - Public

	// MARK: - Internal

	var numberOfSelectableValues: Int {
		return allValues.count
	}

	func cellViewModel(for indexPath: IndexPath) -> SelectValueCellViewModel {
		SelectValueCellViewModel(
			text: allValues[indexPath.row],
			isSelected: selectedIndex == indexPath.row
		)
	}

	// MARK: - Private

	private let allValues: [String]
	private var selectedIndex: Int?

}
