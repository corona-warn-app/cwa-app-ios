////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

final class SelectValueViewModel {

	// MARK: - Init

	init(
		_ allowedValues: [String],
		presorted: Bool = false,
		title: String,
		preselected: String? = nil,
		isInitialCellEnabled: Bool = true,
		initialString: String = AppStrings.DataDonation.ValueSelection.noValue,
		accessibilityIdentifier: String,
		selectionCellIconType: SelectionCellIcon
	) {
		self.selectionCellIconType = selectionCellIconType
		self.isInitialCellEnabled = isInitialCellEnabled
		
		switch presorted {
		case false:
			self.allValues = [initialString] + allowedValues.sorted()
		default:
			self.allValues = [initialString] + allowedValues
		}
		self.title = title
		self.accessibilityIdentifier = accessibilityIdentifier
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
	let isInitialCellEnabled: Bool
	let accessibilityIdentifier: String

	/// this tupel represents the change (oldValue, currentValue)
	@OpenCombine.Published private (set) var selectedTupel: (Int?, Int)
	@OpenCombine.Published private (set) var selectedValue: String?

	var numberOfSelectableValues: Int {
		return allValues.count
	}

	func cellViewModel(for indexPath: IndexPath) -> SelectValueCellViewModel {
		let isEnabled = indexPath.item > 0 ? true : isInitialCellEnabled
		return SelectValueCellViewModel(
			text: allValues[indexPath.row],
			isSelected: selectedTupel.1 == indexPath.row,
			cellIconType: selectionCellIconType,
			isEnabled: isEnabled
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
	private let selectionCellIconType: SelectionCellIcon
}
