////
// 🦠 Corona-Warn-App
//

import Foundation

final class SelectValueCellViewModel {

	// MARK: - Init

	init(text: String, isSelected: Bool) {
		self.text = text
		self.isSelected = isSelected
	}

	// MARK: - Internal

	let text: String
	let isSelected: Bool
}
