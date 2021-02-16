////
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

final class InputManager {

	// MARK: - Init

	init(_ textFields: [UITextField] = []) {
		self.textFields = textFields
	}

	// MARK: - Overrides

	// MARK: - Protocol <#Name#>

	// MARK: - Public

	// MARK: - Internal

	func resignFirstResponder() {
		firstResponder?.resignFirstResponder()
	}

	func makeFirstResponder(_ textField: UITextField) {
		textField.becomeFirstResponder()
		guard textFields.contains(textField) else {
			appendTextField(textField)
			return
		}
	}

	func nextFirtResponder() {
		guard let currentFirstResponder = firstResponder,
			  let index = textFields.firstIndex(of: currentFirstResponder) else {
			textFields.first?.becomeFirstResponder()
			return
		}
		let nextIndex = index + 1
		guard textFields.indices.contains(nextIndex) else {
			Log.debug("there is no next textfiled to enable as first responder", log: .default)
			return
		}
		textFields[nextIndex].becomeFirstResponder()
	}

	func appendTextField(_ textField: UITextField) {
		guard !textFields.contains(textField) else {
			Log.debug("Textfiled already known - stop here", log: .default)
			return
		}
		textFields.append(textField)
	}

	// MARK: - Private

	private var textFields: [UITextField]

	private var firstResponder: UITextField? {
		return textFields.first { textfield -> Bool in
			textfield.isFirstResponder
		}
	}

}
