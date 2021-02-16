////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA
import OpenCombine

class DiaryAddAndEditEntryViewModelTest: XCTestCase {
	
	// MARK: - ContactPerson
	
	func testGIVEN_ContactPerson_WHEN_createEditModeViewModel_THEN_NameIsTextInput() {
		// GIVEN
		let entry: DiaryEntry = .contactPerson(DiaryContactPerson(id: 0, name: "Kai Teuber"))
		let viewModel = DiaryAddAndEditEntryViewModel(
			mode: .edit(entry),
			store: MockDiaryStore()
		)
		
		// WHEN
		let text = viewModel.entryModel.name
		
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
		let placeholder = viewModel.namePlaceholer
		
		// THEN
		XCTAssertEqual(text, AppStrings.ContactDiary.AddEditEntry.person.title)
		XCTAssertEqual(placeholder, AppStrings.ContactDiary.AddEditEntry.person.placeholders.name)
	}
	
	func testGIVEN_ContactPerson_WHEN_createEditModeViewModelAndUpdateText_THEN_UpdatedTextIsTextInput() {
		// GIVEN
		let entry: DiaryEntry = .contactPerson(DiaryContactPerson(id: 0, name: "Kai Teuber"))
		let viewModel = DiaryAddAndEditEntryViewModel(
			mode: .edit(entry),
			store: MockDiaryStore()
		)
		
		// WHEN
		let originalText = viewModel.entryModel.name
		viewModel.update("Kai-Marcel Teuber", keyPath: \DiaryAddAndEditEntryModel.name)
		let updatedText = viewModel.entryModel.name
		viewModel.update(nil, keyPath: \DiaryAddAndEditEntryModel.name)
		let updatedNilText = viewModel.entryModel.name
		
		// THEN
		XCTAssertEqual(originalText, "Kai Teuber")
		XCTAssertEqual(updatedText, "Kai-Marcel Teuber")
		XCTAssertEqual(updatedNilText, "")
	}
	
	func testGIVEN_addContactPerson_WHEN_createViewModel_THEN_TextInputIsEmpty() {
		// GIVEN
		let diaryDay = makeDay()
		let viewModel = DiaryAddAndEditEntryViewModel(
			mode: .add(diaryDay, .contactPerson),
			store: MockDiaryStore()
		)
		
		// WHEN
		let text = viewModel.entryModel.name
		
		// THEN
		XCTAssertTrue(text.isEmpty, "Add model should be empty")
	}
	
	func testGIVEN_ContactPerson_WHEN_reset_THEN_TextIsEmpty() {
		// GIVEN
		let entry: DiaryEntry = .contactPerson(DiaryContactPerson(id: 0, name: "Kai Teuber"))
		let viewModel = DiaryAddAndEditEntryViewModel(
			mode: .edit(entry),
			store: MockDiaryStore()
		)
		
		// WHEN
		let originalText = viewModel.entryModel.name
		viewModel.reset(keyPath: \DiaryAddAndEditEntryModel.name)
		let updatedText = viewModel.entryModel.name
		
		// THEN
		XCTAssertEqual(originalText, "Kai Teuber")
		XCTAssertEqual(updatedText, "")
	}
	
	func testGIVEN_addContactPerson_WHEN_UpdateTextAndSave_THEN_StoreModelIsEqual() {
		// GIVEN
		let emptyDiaryDay = DiaryDay(
			dateString: "2020-12-11",
			entries: []
		)
		
		let store = emptyMockStore()
		let viewModel = DiaryAddAndEditEntryViewModel(
			mode: .add(emptyDiaryDay, .contactPerson),
			store: store
		)
		
		// WHEN
		viewModel.update("Kai Teuber", keyPath: \DiaryAddAndEditEntryModel.name)
		viewModel.save()
		
		// THEN
		let contactPersonStored = store.diaryDaysPublisher.value.first?.entries.first
		
		if case let .contactPerson(diaryEntry) = contactPersonStored {
			XCTAssertEqual(diaryEntry.name, "Kai Teuber")
		} else {
			XCTFail("unexpected diary entry")
		}
	}
	
	func testGIVEN_editContactPerson_WHEN_UpdateTextAndSave_THEN_StoreModelIsEqual() {
		// GIVEN
		let store = emptyMockStore()
		let name = "Kai Teuber"
		let result = store.addContactPerson(name: name)

		guard case let .success(id) = result else {
			fatalError("Failure not expected")
		}
		
		let entry: DiaryEntry = .contactPerson(DiaryContactPerson(id: id, name: name))
		
		let viewModel = DiaryAddAndEditEntryViewModel(
			mode: .edit(entry),
			store: store
		)
		
		// WHEN
		viewModel.update("Kai-Marcel Teuber", keyPath: \DiaryAddAndEditEntryModel.name)
		viewModel.save()
		
		// THEN
		let contactPersonStored = store.diaryDaysPublisher.value.first?.entries.first
		
		if case let .contactPerson(diaryEntry) = contactPersonStored {
			XCTAssertEqual(diaryEntry.name, "Kai-Marcel Teuber")
		} else {
			XCTFail("unexpected diary entry")
		}
	}
	
	// MARK: Location
	
	func testGIVEN_Location_WHEN_createEditModeViewModel_THEN_NameIsTextInput() {
		// GIVEN
		let entry: DiaryEntry = .location(DiaryLocation(id: 0, name: "Office"))
		let viewModel = DiaryAddAndEditEntryViewModel(
			mode: .edit(entry),
			store: MockDiaryStore()
		)
		
		// WHEN
		let text = viewModel.entryModel.name
		
		// THEN
		XCTAssertEqual(text, "Office")
	}
	
	func testGIVEN_Location_WHEN_getTitleAndPlaceholder_THEN_TextIsCorrect() {
		// GIVEN
		let viewModel = DiaryAddAndEditEntryViewModel(
			mode: .add(makeDay(), .location),
			store: MockDiaryStore()
		)
		
		// WHEN
		let text = viewModel.title
		let placeholder = viewModel.namePlaceholer
		
		// THEN
		XCTAssertEqual(text, AppStrings.ContactDiary.AddEditEntry.location.title)
		XCTAssertEqual(placeholder, AppStrings.ContactDiary.AddEditEntry.location.placeholders.name)
	}
	
	func testGIVEN_Location_WHEN_createEditModeViewModelAndUpdateText_THEN_UpdatedTextIsTextInput() {
		// GIVEN
		let entry: DiaryEntry = .contactPerson(DiaryContactPerson(id: 0, name: "Office"))
		let viewModel = DiaryAddAndEditEntryViewModel(
			mode: .edit(entry),
			store: MockDiaryStore()
		)
		
		// WHEN
		let originalText = viewModel.entryModel.name
		viewModel.update("Homeoffice", keyPath: \DiaryAddAndEditEntryModel.name)
		let updatedText = viewModel.entryModel.name
		
		// THEN
		XCTAssertEqual(originalText, "Office")
		XCTAssertEqual(updatedText, "Homeoffice")
	}
	
	func testGIVEN_addLocation_WHEN_UpdateTextAndSave_THEN_StoreModelIsEqual() {
		// GIVEN
		let emptyDiaryDay = DiaryDay(
			dateString: "2020-12-11",
			entries: []
		)
		
		let store = emptyMockStore()
		let viewModel = DiaryAddAndEditEntryViewModel(
			mode: .add(emptyDiaryDay, .location),
			store: store
		)
		
		// WHEN
		viewModel.update("Office", keyPath: \DiaryAddAndEditEntryModel.name)
		viewModel.save()
		
		let locationStored = store.diaryDaysPublisher.value.first?.entries.first
		
		if case let .location(diaryEntry) = locationStored {
			XCTAssertEqual(diaryEntry.name, "Office")
		} else {
			XCTFail("unexpected diary entry")
		}
	}
	
	func testGIVEN_editlocation_WHEN_UpdateTextAndSave_THEN_StoreModelIsEqual() {
		// GIVEN
		let mockStore = emptyMockStore()
		let name = "Office"
		let result = mockStore.addLocation(name: name)

		guard case let .success(id) = result else {
			fatalError("Failure not expected")
		}

		let entry: DiaryEntry = .location(.init(id: id, name: name))
		
		let viewModel = DiaryAddAndEditEntryViewModel(
			mode: .edit(entry),
			store: mockStore
		)
		
		// WHEN
		viewModel.update("Homeoffice", keyPath: \DiaryAddAndEditEntryModel.name)
		viewModel.save()
		
		// THEN
		let locationStored = mockStore.diaryDaysPublisher.value.first?.entries.first
		
		if case let .location(diaryEntry) = locationStored {
			XCTAssertEqual(diaryEntry.name, "Homeoffice")
		} else {
			XCTFail("unexpected diary entry")
		}
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
				.contactPerson(DiaryContactPerson(id: 8, name: "Puneet Mahali"))
			]
		)
	}
	
	func emptyMockStore() -> MockDiaryStore {
		let mockStore = MockDiaryStore()
		mockStore.removeAllLocations()
		mockStore.removeAllContactPersons()
		return mockStore
	}
	
}
