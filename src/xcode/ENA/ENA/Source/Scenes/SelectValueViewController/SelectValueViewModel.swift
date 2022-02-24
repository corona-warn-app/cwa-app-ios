////
// 🦠 Corona-Warn-App
//

import Foundation
import OpenCombine

final class SelectValueViewModel {

	// MARK: - Init

	init(
		_ allowedValues: [SelectableValue],
		presorted: Bool = false,
		title: String,
		preselected: String? = nil,
		isInitialCellWithValue: Bool = false,
		initialValue: SelectableValue?,
		accessibilityIdentifier: String,
		selectionCellIconType: SelectionCellIcon
	) {
		self.selectionCellIconType = selectionCellIconType
        self.isInitialCellEnabled = initialValue?.isEnabled ?? true
		self.isInitialCellWithValue = isInitialCellWithValue
        var firstElementArray = [SelectableValue]()
        if let firstElement = initialValue {
            firstElementArray.append(firstElement)
        }
        
		switch presorted {
		case false:
            self.allValues = firstElementArray + allowedValues.sorted()
		default:
			self.allValues = firstElementArray + allowedValues
		}
		self.title = title
		self.accessibilityIdentifier = accessibilityIdentifier
		guard let preselected = preselected,
			  let selectedIndex = self.allValues.firstIndex(where: { $0.title == preselected }) else {
			self.selectedTupel = (nil, 0)
			self.selectedValue = nil
			return
		}
		self.selectedTupel = (nil, selectedIndex)
		self.selectedValue = self.allValues[selectedIndex]
	}

	// MARK: - Internal

	let title: String
	let accessibilityIdentifier: String
	// the following two flags are for configuration of the first cell
	// only in the case of choosing districts in the local statistics do we return a value from the first cell
	// in PPA the first cell is enabled but it returns nil value, in local statistics federal states it is disabled
	let isInitialCellWithValue: Bool
	let isInitialCellEnabled: Bool
	
	/// this tuple represents the change (oldValue, currentValue)
	@OpenCombine.Published private (set) var selectedTupel: (Int?, Int)
	@OpenCombine.Published private (set) var selectedValue: SelectableValue?

	var numberOfSelectableValues: Int {
		return allValues.count
	}

	func cellViewModel(for indexPath: IndexPath) -> SelectValueCellViewModel {
		return SelectValueCellViewModel(
			text: allValues[indexPath.row].title,
			subtitle: allValues[indexPath.row].subtitle,
			isSelected: selectedTupel.1 == indexPath.row,
			cellIconType: selectionCellIconType,
			isEnabled: allValues[indexPath.row].isEnabled
		)
	}

	func selectValue(at indexPath: IndexPath) {
		guard allValues.indices.contains(indexPath.row) else {
			Log.debug("unpossible value selection found, ignored it", log: .ppac)
			return
		}
		selectedTupel = (selectedTupel.1, indexPath.row)
		
		if indexPath.row == 0 && !isInitialCellWithValue {
			selectedValue = nil
		} else {
			selectedValue = allValues[indexPath.row]
		}
	}

	// MARK: - Private

	private let allValues: [SelectableValue]
	private let selectionCellIconType: SelectionCellIcon
}
