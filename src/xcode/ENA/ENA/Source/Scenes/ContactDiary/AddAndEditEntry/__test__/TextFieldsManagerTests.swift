////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class TextFieldsManagerTests: XCTestCase {

	func testGIVEN_TextFieldManager_WHEN_GetKeyPath_THEN_IsFound() {
		// GIVEN
		let manager = TextFieldsManager()
		let textField = UITextField()
		manager.appendTextField(textfiledWithKayPath: (textField, \DiaryAddAndEditEntryModel.name))

		// WHEN
		let foundKeyPath = manager.keyPath(for: textField)

		// THEN
		XCTAssertEqual(\DiaryAddAndEditEntryModel.name, foundKeyPath)
	}

	func testGIVEN_TextFieldManager_WHEN_GetKeyPath_THEN_IsNotFound() {
		// GIVEN
		let manager = TextFieldsManager()
		let textField = UITextField()

		// WHEN
		let foundKeyPath = manager.keyPath(for: textField)

		// THEN
		XCTAssertNil(foundKeyPath)
	}

	func testGIVEN_TextFieldManager_WHEN_CheckFirstResponder_THEN_NoneIsSet() {
		// GIVEN
		let manager = TextFieldsManager()
		let textField1 = UITextField()
		let textField2 = UITextField()

		manager.appendTextField(textfiledWithKayPath: (textField1, \DiaryAddAndEditEntryModel.name))
		manager.appendTextField(textfiledWithKayPath: (textField2, \DiaryAddAndEditEntryModel.phoneNumber))

		// WHEN
		let firstResponder1 = textField1.isFirstResponder
		let firstResponder2 = textField2.isFirstResponder

		// THEN
		XCTAssertFalse(firstResponder1)
		XCTAssertFalse(firstResponder2)
	}

	func testGIVEN_TextFieldManager_WHEN_nextFirstResponderAndResign_THEN_NoneIsSet() {
		// GIVEN
		let manager = TextFieldsManager()
		let textField1 = UITextField()
		let textField2 = UITextField()

		manager.appendTextField(textfiledWithKayPath: (textField1, \DiaryAddAndEditEntryModel.name))
		manager.appendTextField(textfiledWithKayPath: (textField2, \DiaryAddAndEditEntryModel.phoneNumber))

		// WHEN
		manager.nextFirstResponder()
		let firstResponder1 = textField1.isFirstResponder
		let firstResponder2 = textField2.isFirstResponder
		manager.resignFirstResponder()

		// THEN
		XCTAssertFalse(firstResponder1)
		XCTAssertFalse(firstResponder2)
	}

	func testGIVEN_TextFieldManager_WHEN_AddTwiceATextFiled_THEN_OnlyAddedOnce() {
		// GIVEN
		let manager = TextFieldsManager()
		let textField = UITextField()
		manager.appendTextField(textfiledWithKayPath: (textField, \DiaryAddAndEditEntryModel.name))
		manager.appendTextField(textfiledWithKayPath: (textField, \DiaryAddAndEditEntryModel.emailAddress))

		// WHEN
		let textfields = manager.textFiledsOnly

		// THEN
		XCTAssertEqual(textfields.count, 1)
	}


}
