////
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

final class TextFieldsManager {

	// MARK: - Init

	/** Manager to handle multiple TextFiled
		each TextFiled will get a KeyPath attached
	*/
	init() {
		self.textFieldsWithKeyPaths = []
	}

	// MARK: - Internal

	// get the associated keyPath for a textfield - if known
	func keyPath(for searchTextField: UITextField) -> WritableKeyPath<DiaryAddAndEditEntryModel, String>? {
		textFieldsWithKeyPaths.first { textField, _ -> Bool in
			searchTextField == textField
		}?.1
	}

	func resignFirstResponder() {
		firstResponder?.resignFirstResponder()
	}

	// get the current first responder and set the next textfield in the array
	// as new first responder
	// if no current first resonders is found, the first TextFiled available
	// will become the new first responder
	func nextFirtResponder() {
		guard let currentFirstResponder = firstResponder,
			  let index = textFiledsOnly.firstIndex(of: currentFirstResponder) else {
			textFiledsOnly.first?.becomeFirstResponder()
			return
		}
		let nextIndex = index + 1
		guard textFiledsOnly.indices.contains(nextIndex) else {
			Log.debug("there is no next textfiled to enable as first responder", log: .default)
			return
		}
		textFiledsOnly[nextIndex].becomeFirstResponder()
	}

	// method to add a new textfiled to the known array of TextFields with attatched KeyPath
	func appendTextField(textfiledWithKayPath: (UITextField, WritableKeyPath<DiaryAddAndEditEntryModel, String>)) {
		guard !textFiledsOnly.contains(textfiledWithKayPath.0) else {
			Log.debug("Textfiled already known - stop here", log: .default)
			return
		}
		textFieldsWithKeyPaths.append(textfiledWithKayPath)
	}

	// MARK: - Private

	private var textFieldsWithKeyPaths: [(UITextField, WritableKeyPath<DiaryAddAndEditEntryModel, String>)]

	// helper to get all textfiled without attached KeyPath
	private var textFiledsOnly: [UITextField] {
		textFieldsWithKeyPaths.map { textFiled, _ -> UITextField in
			return textFiled
		}
	}

	/// look for the current first responder and return if available
	private var firstResponder: UITextField? {
		return textFiledsOnly.first { textfield -> Bool in
			textfield.isFirstResponder
		}
	}

}
