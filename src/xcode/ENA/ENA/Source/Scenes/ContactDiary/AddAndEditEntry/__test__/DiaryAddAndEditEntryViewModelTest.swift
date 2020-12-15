////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA


class DiaryAddAndEditEntryViewModelTest: XCTestCase {

	func testGIVEN_ContactPerson_WHEN_createEditModeViewModel_THEN_NameIsTextInput() {
		// GIVEN
		let entry: DiaryEntry = .contactPerson(DiaryContactPerson(id: 0, name: "Kai Teuber", encounterId: nil))
		let viewModel = DiaryAddAndEditEntryViewModel(
			mode: .edit(entry),
			store: MockDiaryStore()
		)

		// WHEN
		let text = viewModel.textInput

		// THEN
		XCTAssertEqual(text, "Kai Teuber")
	}

	func testGIVEN_ContactPerson_WHEN_getTitleAndPlacholder_THEN_TextIsCorrcet() {
		// GIVEN
		let entry: DiaryEntry = .contactPerson(DiaryContactPerson(id: 0, name: "Kai Teuber"))
		let viewModel = DiaryAddAndEditEntryViewModel(
			mode: .edit(entry),
			store: MockDiaryStore()
		)

		// WHEN
		let text = viewModel.title
		let placeholder = viewModel.placeholderText

		// THEN
		XCTAssertEqual(text, "Person")
		XCTAssertEqual(placeholder, "Person")
	}

	func testGIVEN_ContactPerson_WHEN_createEditModeViewModelAndUpdateText_THEN_UpdatedTextIsTextInput() {
		// GIVEN
		let entry: DiaryEntry = .contactPerson(DiaryContactPerson(id: 0, name: "Kai Teuber", encounterId: nil))
		let viewModel = DiaryAddAndEditEntryViewModel(
			mode: .edit(entry),
			store: MockDiaryStore()
		)

		// WHEN
		let originalText = viewModel.textInput
		viewModel.update("Kai-Marcel Teuber")
		let updatedText = viewModel.textInput
		viewModel.update(nil)
		let updatedNilText = viewModel.textInput

		// THEN
		XCTAssertEqual(originalText, "Kai Teuber")
		XCTAssertEqual(updatedText, "Kai-Marcel Teuber")
		XCTAssertEqual(updatedNilText, "")
	}

	func testGIVEN_Location_WHEN_createEditModeViewModel_THEN_NameIsTextInput() {
		// GIVEN
		let entry: DiaryEntry = .location(DiaryLocation(id: 0, name: "Office"))
		let viewModel = DiaryAddAndEditEntryViewModel(
			mode: .edit(entry),
			store: MockDiaryStore()
		)

		// WHEN
		let text = viewModel.textInput

		// THEN
		XCTAssertEqual(text, "Office")
	}

	func testGIVEN_Location_WHEN_getTitleAndPlacholder_THEN_TextIsCorrcet() {
		// GIVEN
		let viewModel = DiaryAddAndEditEntryViewModel(
			mode: .add(makeDay(), .location),
			store: MockDiaryStore()
		)

		// WHEN
		let text = viewModel.title
		let placeholder = viewModel.placeholderText

		// THEN
		XCTAssertEqual(text, "Ort")
		XCTAssertEqual(placeholder, "Ort")
	}

	func testGIVEN_addContactPerson_WHEN_createViewModel_THEN_TextInputIsEmpty() {
		// GIVEN
		let diaryDay = makeDay()
		let viewModel = DiaryAddAndEditEntryViewModel(
			mode: .add(diaryDay, .contactPerson),
			store: MockDiaryStore()
		)

		// WHEN
		let text = viewModel.textInput

		// THEN
		XCTAssertTrue(text.isEmpty, "Add model should be empty")
	}

	func testGIVEN_Location_WHEN_createEditModeViewModelAndUpdateText_THEN_UpdatedTextIsTextInput() {
		// GIVEN
		let entry: DiaryEntry = .contactPerson(DiaryContactPerson(id: 0, name: "Office", encounterId: nil))
		let viewModel = DiaryAddAndEditEntryViewModel(
			mode: .edit(entry),
			store: MockDiaryStore()
		)

		// WHEN
		let originalText = viewModel.textInput
		viewModel.update("Homeoffice")
		let updatedText = viewModel.textInput

		// THEN
		XCTAssertEqual(originalText, "Office")
		XCTAssertEqual(updatedText, "Homeoffice")
	}


	func testGIVEN_ContactPerson_WHEN_reset_THEN_TextIsEmpty() {
		// GIVEN
		let entry: DiaryEntry = .contactPerson(DiaryContactPerson(id: 0, name: "Kai Teuber"))
		let viewModel = DiaryAddAndEditEntryViewModel(
			mode: .edit(entry),
			store: MockDiaryStore()
		)

		// WHEN
		let originalText = viewModel.textInput
		viewModel.reset()
		let updatedText = viewModel.textInput


		// THEN
		XCTAssertEqual(originalText, "Kai Teuber")
		XCTAssertEqual(updatedText, "")
	}



	// MARK: - Helpers
	func makeDay() -> DiaryDay {
		return DiaryDay(
			dateString: "2020-12-11",
			entries: [
				.contactPerson(DiaryContactPerson(id: 7, name: "Andreas Vogel")),
				.contactPerson(DiaryContactPerson(id: 2, name: "Artur Friesen")),
				.contactPerson(DiaryContactPerson(id: 6, name: "Carsten Knoblich")),
				.contactPerson(DiaryContactPerson(id: 4, name: "Kai Teuber")),
				.contactPerson(DiaryContactPerson(id: 5, name: "Karsten Gahn")),
				.contactPerson(DiaryContactPerson(id: 1, name: "Marcus Scherer")),
				.contactPerson(DiaryContactPerson(id: 0, name: "Nick Gündling")),
				.contactPerson(DiaryContactPerson(id: 9, name: "Omar Ahmed")),
				.contactPerson(DiaryContactPerson(id: 3, name: "Pascal Brause")),
				.contactPerson(DiaryContactPerson(id: 8, name: "Puneet Mahali"))			]
		)
	}

}
