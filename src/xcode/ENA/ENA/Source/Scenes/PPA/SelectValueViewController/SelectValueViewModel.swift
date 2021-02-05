////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

final class SelectValueViewModel {

	// MARK: - Init

	init(_ allValues: [String], preselected: String?) {
		self.allValues = ["keine Angabe"] + allValues
		guard let preselected = preselected,
			  let selectedIndex = self.allValues.firstIndex(of: preselected) else {
			self.selectedIndex = (nil, 0)
			return
		}
		self.selectedIndex = (nil, selectedIndex)
	}

	// MARK: - Internal

	/// this tupel represents the change (oldVlaue, currentValue)
	@OpenCombine.Published private (set) var selectedIndex: (Int?, Int)

	var numberOfSelectableValues: Int {
		return allValues.count
	}

	func cellViewModel(for indexPath: IndexPath) -> SelectValueCellViewModel {
		SelectValueCellViewModel(
			text: allValues[indexPath.row],
			isSelected: selectedIndex.1 == indexPath.row
		)
	}

	func selectValue(at indexPath: IndexPath) {
		guard allValues.indices.contains(indexPath.row) else {
			Log.debug("unpossible value selection found, ignored it", log: .ppac)
			return
		}
		selectedIndex = (selectedIndex.1, indexPath.row)
	}

	// MARK: - Private

	private let allValues: [String]

}
