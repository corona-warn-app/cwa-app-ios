////
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

final class TextFieldsManager {

	// MARK: - Init

	/** Manager to handle multiple TextFiled, each gets an associated WritableKeyPath */
	init() {
		self.textFieldsWithKeyPaths = []
	}

	// MARK: - Internal

	// helper to get all textfields without attached KeyPath
	var textFieldsOnly: [UITextField] {
		textFieldsWithKeyPaths.map { textFiled, _ -> UITextField in
			return textFiled
		}
	}

	// get the associated WritableKeyPath for a textfield - if known
	func keyPath(for searchTextField: UITextField) -> WritableKeyPath<DiaryAddAndEditEntryModel, String>? {
		textFieldsWithKeyPaths.first { textField, _ -> Bool in
			searchTextField == textField
		}?.keyPath
	}

	func resignFirstResponder() {
		firstResponder?.resignFirstResponder()
	}

	// get the current first responder and set the next textfield in the array
	// as new first responder
	// if no current first responder is found, the first textfield available
	// will become the new first responder
	func nextFirstResponder() {
		guard let currentFirstResponder = firstResponder,
			  let index = textFieldsOnly.firstIndex(of: currentFirstResponder) else {
			textFieldsOnly.first?.becomeFirstResponder()
			return
		}
		let nextIndex = index + 1
		guard textFieldsOnly.indices.contains(nextIndex) else {
			Log.debug("there is no next textfield to enable as first responder", log: .default)
			return
		}
		textFieldsOnly[nextIndex].becomeFirstResponder()
	}

	// method to add a new textfield to the known array of TextFields with attached KeyPath
	func appendTextField(textfieldWithKayPath: (textField: UITextField, WritableKeyPath<DiaryAddAndEditEntryModel, String>)) {
		guard !textFieldsOnly.contains(textfieldWithKayPath.textField) else {
			Log.debug("Text filed already known - stop here", log: .default)
			return
		}
		textFieldsWithKeyPaths.append(textfieldWithKayPath)
	}

	// MARK: - Private

	private var textFieldsWithKeyPaths: [(textField: UITextField, keyPath: WritableKeyPath<DiaryAddAndEditEntryModel, String>)]

	/// look for the current first responder and return if available
	private var firstResponder: UITextField? {
		return textFieldsOnly.first { textField -> Bool in
			textField.isFirstResponder
		}
	}

}
