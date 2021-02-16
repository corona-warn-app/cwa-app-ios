////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

final class SelectValueViewModel {

	// MARK: - Init

	init(
		_ allowedValues: [String],
		title: String,
		preselected: String? = nil
	) {
		self.allValues = [AppStrings.DataDonation.ValueSelection.noValue] + allowedValues.sorted()
		self.title = title
		guard let preselected = preselected,
			  let selectedIndex = self.allValues.firstIndex(of: preselected) else {
			self.selectedTupel = (nil, 0)
			self.selectedValue = nil
			return
		}
		self.selectedTupel = (nil, selectedIndex)
		self.selectedValue = self.allValues[selectedIndex]
	}

	// MARK: - Internal

	let title: String

	/// this tupel represents the change (oldValue, currentValue)
	@OpenCombine.Published private (set) var selectedTupel: (Int?, Int)
	@OpenCombine.Published private (set) var selectedValue: String?

	var numberOfSelectableValues: Int {
		return allValues.count
	}

	func cellViewModel(for indexPath: IndexPath) -> SelectValueCellViewModel {
		SelectValueCellViewModel(
			text: allValues[indexPath.row],
			isSelected: selectedTupel.1 == indexPath.row
		)
	}

	func selectValue(at indexPath: IndexPath) {
		guard allValues.indices.contains(indexPath.row) else {
			Log.debug("unpossible value selection found, ignored it", log: .ppac)
			return
		}
		selectedTupel = (selectedTupel.1, indexPath.row)
		selectedValue = indexPath.row == 0 ? nil : allValues[indexPath.row]
	}

	// MARK: - Private

	private let allValues: [String]

}
