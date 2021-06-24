////
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

final class SelectValueCellViewModel {

	// MARK: - Init

	init(text: String, isSelected: Bool, cellIconType: SelectionCellIcon) {
		self.text = text
		switch cellIconType {
		case .checkmark:
			self.image = isSelected ? UIImage(imageLiteralResourceName: "Icons_Checkmark") : nil
		case .discloseIndicator:
			self.image = UIImage(imageLiteralResourceName: "Icons_Chevron_plain")
		case .none:
			self.image = nil
		}
	}

	// MARK: - Internal

	let text: String
	let image: UIImage?
}

enum SelectionCellIcon {
	case checkmark
	case discloseIndicator
	case none
}
