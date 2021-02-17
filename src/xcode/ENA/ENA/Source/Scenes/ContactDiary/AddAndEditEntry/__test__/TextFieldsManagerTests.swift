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
		manager.appendTextField(textfieldWithKayPath: (textField, \DiaryAddAndEditEntryModel.name))

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

		manager.appendTextField(textfieldWithKayPath: (textField1, \DiaryAddAndEditEntryModel.name))
		manager.appendTextField(textfieldWithKayPath: (textField2, \DiaryAddAndEditEntryModel.phoneNumber))

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

		// this is required because become first responder will only work if the textfield is inside the current view hirachie
		let dummyViewController = UIViewController()
		let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
		window.makeKeyAndVisible()
		window.rootViewController = dummyViewController
		dummyViewController.view.addSubview(textField1)
		dummyViewController.view.addSubview(textField2)

		manager.appendTextField(textfieldWithKayPath: (textField1, \DiaryAddAndEditEntryModel.name))
		manager.appendTextField(textfieldWithKayPath: (textField2, \DiaryAddAndEditEntryModel.phoneNumber))

		dummyViewController.loadViewIfNeeded()

		// WHEN
		manager.nextFirstResponder()
		let firstResponder1 = textField1.isFirstResponder
		let firstResponder2 = textField2.isFirstResponder
		manager.resignFirstResponder()

		// THEN
		XCTAssertFalse(firstResponder1)
		XCTAssertTrue(firstResponder2)
	}

	func testGIVEN_TextfieldManager_WHEN_FirstRespomderChange_THEN_isSelected() {
		// GIVEN
		let manager = TextFieldsManager()
		let textField1 = UITextField()
		let textField2 = UITextField()

		// this is required because become first responder will only work if the textfield is inside the current view hirachie
		let dummyViewController = UIViewController()
		let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
		window.makeKeyAndVisible()
		window.rootViewController = dummyViewController
		dummyViewController.view.addSubview(textField1)
		dummyViewController.view.addSubview(textField2)

		manager.appendTextField(textfieldWithKayPath: (textField1, \DiaryAddAndEditEntryModel.name))
		manager.appendTextField(textfieldWithKayPath: (textField2, \DiaryAddAndEditEntryModel.phoneNumber))

		dummyViewController.loadViewIfNeeded()

		// WHEN
		manager.nextFirstResponder()
		manager.nextFirstResponder()
		let firstResponder1 = textField1.isFirstResponder
		let firstResponder2 = textField2.isFirstResponder

		// THEN
		XCTAssertFalse(firstResponder1)
		XCTAssertTrue(firstResponder2)
	}

	func testGIVEN_TextFieldManager_WHEN_AddTwiceATextFiled_THEN_OnlyAddedOnce() {
		// GIVEN
		let manager = TextFieldsManager()
		let textField = UITextField()
		manager.appendTextField(textfieldWithKayPath: (textField, \DiaryAddAndEditEntryModel.name))
		manager.appendTextField(textfieldWithKayPath: (textField, \DiaryAddAndEditEntryModel.emailAddress))

		// WHEN
		let textfields = manager.textFieldsOnly

		// THEN
		XCTAssertEqual(textfields.count, 1)
	}


}
