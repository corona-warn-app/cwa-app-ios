////
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

final class SelectValueCellViewModel {

	// MARK: - Init

	init(text: String, subtitle: String? = nil, isSelected: Bool, cellIconType: SelectionCellIcon, isEnabled: Bool = true) {
		self.text = text
		self.subtitle = subtitle
		self.isEnabled = isEnabled
		
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
	let subtitle: String?
	let image: UIImage?
	let isEnabled: Bool
}

enum SelectionCellIcon {
	case checkmark
	case discloseIndicator
	case none
}
