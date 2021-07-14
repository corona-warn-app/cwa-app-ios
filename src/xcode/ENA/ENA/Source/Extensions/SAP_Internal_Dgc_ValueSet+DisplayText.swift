//
// 🦠 Corona-Warn-App
//

import Foundation

extension SAP_Internal_Dgc_ValueSet {

	func displayText(forKey key: String) -> String? {
		let displayText = items
			.first { $0.key == key }
			.map { $0.displayText }

		return displayText
	}

}
