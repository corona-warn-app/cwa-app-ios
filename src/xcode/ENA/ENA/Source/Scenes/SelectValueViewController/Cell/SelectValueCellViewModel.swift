////
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

final class SelectValueCellViewModel {

	// MARK: - Init

	init(text: String, isSelected: Bool) {
		self.text = text
		self.checkmarkImage = isSelected ? UIImage(imageLiteralResourceName: "Icons_Checkmark") : nil
	}

	// MARK: - Internal

	let text: String
	let checkmarkImage: UIImage?
}
