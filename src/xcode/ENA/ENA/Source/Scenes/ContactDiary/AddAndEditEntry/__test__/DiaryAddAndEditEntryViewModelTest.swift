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
		let entry: DiaryEntry = .contactPerson(DiaryContactPerson(id: 0, name: "Kai Teuber", phoneNumber: "+123456789", emailAddress: "test@sap.com"))
		let viewModel = DiaryAddAndEditEntryViewModel(
			mode: .edit(entry),
			store: MockDiaryStore()
		)
		
		// WHEN
		let name = viewModel.entryModel.name
		let phoneNumber = viewModel.entryModel.phoneNumber
		let email = viewModel.entryModel.emailAddress

		// THEN
		XCTAssertEqual(name, "Kai Teuber")
		XCTAssertEqual(phoneNumber, "+123456789")
		XCTAssertEqual(email, "test@sap.com")
	}
	
	func testGIVEN_ContactPerson_WHEN_getTitleAndPlacholder_THEN_TextIsCorrcet() {
		// GIVEN
		let entry: DiaryEntry = .contactPerson(DiaryContactPerson(id: 0, name: "Kai Teuber", phoneNumber: "+123456789", emailAddress: "test@sap.com"))
		let viewModel = DiaryAddAndEditEntryViewModel(
			mode: .edit(entry),
			store: MockDiaryStore()
		)
		
		// WHEN
		let text = viewModel.title
		let namePlaceholder = viewModel.namePlaceholder
		let phonePlaceholder = viewModel.phoneNumberPlaceholder
		let emailPlaceholder = viewModel.emailAddressPlaceholder

		// THEN
		XCTAssertEqual(text, AppStrings.ContactDiary.AddEditEntry.person.title)
		XCTAssertEqual(namePlaceholder, AppStrings.ContactDiary.AddEditEntry.person.placeholders.name)
		XCTAssertEqual(phonePlaceholder, AppStrings.ContactDiary.AddEditEntry.person.placeholders.phonenumber)
		XCTAssertEqual(emailPlaceholder, AppStrings.ContactDiary.AddEditEntry.person.placeholders.email)
	}
	
	func testGIVEN_ContactPerson_WHEN_createEditModeViewModelAndUpdateText_THEN_UpdatedTextIsTextInput() {
		// GIVEN
		let entry: DiaryEntry = .contactPerson(DiaryContactPerson(id: 0, name: "Kai Teuber", phoneNumber: "+123456789", emailAddress: "test@sap.com"))
		let viewModel = DiaryAddAndEditEntryViewModel(
			mode: .edit(entry),
			store: MockDiaryStore()
		)
		
		// WHEN
		let originalName = viewModel.entryModel.name
		let originalPhone = viewModel.entryModel.phoneNumber
		let originalEmail = viewModel.entryModel.emailAddress

		viewModel.update("Kai-Marcel Teuber", keyPath: \DiaryAddAndEditEntryModel.name)
		viewModel.update("+4915121248249", keyPath: \DiaryAddAndEditEntryModel.phoneNumber)
		viewModel.update("kai.marcel.teuber@sap.com", keyPath: \DiaryAddAndEditEntryModel.emailAddress)
		let updatedName = viewModel.entryModel.name
		let updatedPhone = viewModel.entryModel.phoneNumber
		let updatedEmail = viewModel.entryModel.emailAddress

		viewModel.update(nil, keyPath: \DiaryAddAndEditEntryModel.name)
		viewModel.update(nil, keyPath: \DiaryAddAndEditEntryModel.phoneNumber)
		viewModel.update(nil, keyPath: \DiaryAddAndEditEntryModel.emailAddress)

		let updatedNilName = viewModel.entryModel.name
		let updatedNilPhone = viewModel.entryModel.phoneNumber
		let updatedNilEmail = viewModel.entryModel.emailAddress

		// THEN
		XCTAssertEqual(originalName, "Kai Teuber")
		XCTAssertEqual(originalPhone, "+123456789")
		XCTAssertEqual(originalEmail, "test@sap.com")

		XCTAssertEqual(updatedName, "Kai-Marcel Teuber")
		XCTAssertEqual(updatedPhone, "+4915121248249")
		XCTAssertEqual(updatedEmail, "kai.marcel.teuber@sap.com")

		XCTAssertTrue(updatedNilName.isEmpty, "updated with nil should result in empty name")
		XCTAssertTrue(updatedNilPhone.isEmpty, "updated with nil should result in empty phonenumber")
		XCTAssertTrue(updatedNilEmail.isEmpty, "updated with nil should result in empty email address")
	}
	
	func testGIVEN_addContactPerson_WHEN_createViewModel_THEN_TextInputIsEmpty() {
		// GIVEN
		let diaryDay = makeDay()
		let viewModel = DiaryAddAndEditEntryViewModel(
			mode: .add(diaryDay, .contactPerson),
			store: MockDiaryStore()
		)
		
		// WHEN
		let name = viewModel.entryModel.name
		let phone = viewModel.entryModel.phoneNumber
		let email = viewModel.entryModel.emailAddress

		// THEN
		XCTAssertTrue(name.isEmpty, "should init with empty name")
		XCTAssertTrue(phone.isEmpty, "should init with empty phonenumber")
		XCTAssertTrue(email.isEmpty, "should init with empty email addess")
	}
	
	func testGIVEN_ContactPerson_WHEN_resetName_THEN_TextIsEmpty() {
		// GIVEN
		let entry: DiaryEntry = .contactPerson(DiaryContactPerson(id: 0, name: "Kai Teuber", phoneNumber: "+123456789", emailAddress: "test@sap.com"))
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

	func testGIVEN_ContactPerson_WHEN_resetPhoneNumber_THEN_TextIsEmpty() {
		// GIVEN
		let entry: DiaryEntry = .contactPerson(DiaryContactPerson(id: 0, name: "Kai Teuber", phoneNumber: "+123456789", emailAddress: "test@sap.com"))
		let viewModel = DiaryAddAndEditEntryViewModel(
			mode: .edit(entry),
			store: MockDiaryStore()
		)

		// WHEN
		let originalText = viewModel.entryModel.phoneNumber
		viewModel.reset(keyPath: \DiaryAddAndEditEntryModel.phoneNumber)
		let updatedText = viewModel.entryModel.phoneNumber

		// THEN
		XCTAssertEqual(originalText, "+123456789")
		XCTAssertEqual(updatedText, "")
	}

	func testGIVEN_ContactPerson_WHEN_resetEmail_THEN_TextIsEmpty() {
		// GIVEN
		let entry: DiaryEntry = .contactPerson(DiaryContactPerson(id: 0, name: "Kai Teuber", phoneNumber: "+123456789", emailAddress: "test@sap.com"))
		let viewModel = DiaryAddAndEditEntryViewModel(
			mode: .edit(entry),
			store: MockDiaryStore()
		)

		// WHEN
		let originalText = viewModel.entryModel.emailAddress
		viewModel.reset(keyPath: \DiaryAddAndEditEntryModel.emailAddress)
		let updatedText = viewModel.entryModel.emailAddress

		// THEN
		XCTAssertEqual(originalText, "test@sap.com")
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
		viewModel.update("+123456789", keyPath: \DiaryAddAndEditEntryModel.phoneNumber)
		viewModel.update("test@sap.com", keyPath: \DiaryAddAndEditEntryModel.emailAddress)
		viewModel.save()
		
		// THEN
		let contactPersonStored = store.diaryDaysPublisher.value.first?.entries.first
		
		if case let .contactPerson(diaryEntry) = contactPersonStored {
			XCTAssertEqual(diaryEntry.name, "Kai-Marcel Teuber")
			XCTAssertEqual(diaryEntry.phoneNumber, "+123456789")
			XCTAssertEqual(diaryEntry.emailAddress, "test@sap.com")
		} else {
			XCTFail("unexpected diary entry")
		}
	}
	
	// MARK: Location
	
	func testGIVEN_Location_WHEN_createEditModeViewModel_THEN_NameIsTextInput() {
		// GIVEN
		let entry: DiaryEntry = .location(DiaryLocation(id: 0, name: "Office", phoneNumber: "+49123456789", emailAddress: "office@office.test"))
		let viewModel = DiaryAddAndEditEntryViewModel(
			mode: .edit(entry),
			store: MockDiaryStore()
		)
		
		// WHEN
		let name = viewModel.entryModel.name
		let phone = viewModel.entryModel.phoneNumber
		let email = viewModel.entryModel.emailAddress

		// THEN
		XCTAssertEqual(name, "Office")
		XCTAssertEqual(phone, "+49123456789")
		XCTAssertEqual(email, "office@office.test")
	}
	
	func testGIVEN_Location_WHEN_getTitleAndPlaceholder_THEN_TextIsCorrect() {
		// GIVEN
		let viewModel = DiaryAddAndEditEntryViewModel(
			mode: .add(makeDay(), .location),
			store: MockDiaryStore()
		)
		
		// WHEN
		let text = viewModel.title
		let namePlaceholder = viewModel.namePlaceholder
		let phonePlaceholder = viewModel.phoneNumberPlaceholder
		let emailPlaceholder = viewModel.emailAddressPlaceholder

		// THEN
		XCTAssertEqual(text, AppStrings.ContactDiary.AddEditEntry.location.title)
		XCTAssertEqual(namePlaceholder, AppStrings.ContactDiary.AddEditEntry.location.placeholders.name)
		XCTAssertEqual(phonePlaceholder, AppStrings.ContactDiary.AddEditEntry.location.placeholders.phonenumber)
		XCTAssertEqual(emailPlaceholder, AppStrings.ContactDiary.AddEditEntry.location.placeholders.email)
	}
	
	func testGIVEN_Location_WHEN_createEditModeViewModelAndUpdateText_THEN_UpdatedTextIsTextInput() {
		// GIVEN
		let entry: DiaryEntry = .contactPerson(DiaryContactPerson(id: 0, name: "Office", emailAddress: "email@sap.ch"))
		let viewModel = DiaryAddAndEditEntryViewModel(
			mode: .edit(entry),
			store: MockDiaryStore()
		)
		
		// WHEN
		let originalNameText = viewModel.entryModel.name
		let originalPhoneText = viewModel.entryModel.phoneNumber
		let originalEmailText = viewModel.entryModel.emailAddress

		viewModel.update("Homeoffice", keyPath: \DiaryAddAndEditEntryModel.name)
		viewModel.update("+414411223255", keyPath: \DiaryAddAndEditEntryModel.phoneNumber)
		viewModel.update("mail@ch.sap", keyPath: \DiaryAddAndEditEntryModel.emailAddress)

		let updatedName = viewModel.entryModel.name
		let updatedPhone = viewModel.entryModel.phoneNumber
		let updatedEmail = viewModel.entryModel.emailAddress

		// THEN
		XCTAssertEqual(originalNameText, "Office")
		XCTAssertEqual(originalPhoneText, "")
		XCTAssertEqual(originalEmailText, "email@sap.ch")

		XCTAssertEqual(updatedName, "Homeoffice")
		XCTAssertEqual(updatedPhone, "+414411223255")
		XCTAssertEqual(updatedEmail, "mail@ch.sap")
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
		viewModel.update("+4444444", keyPath: \DiaryAddAndEditEntryModel.phoneNumber)
		viewModel.update("email@mail.ed", keyPath: \DiaryAddAndEditEntryModel.emailAddress)
		viewModel.save()
		
		let locationStored = store.diaryDaysPublisher.value.first?.entries.first
		
		if case let .location(diaryEntry) = locationStored {
			XCTAssertEqual(diaryEntry.name, "Office")
			XCTAssertEqual(diaryEntry.phoneNumber, "+4444444")
			XCTAssertEqual(diaryEntry.emailAddress, "email@mail.ed")
		} else {
			XCTFail("unexpected diary entry")
		}
	}
	
	func testGIVEN_editlocation_WHEN_UpdateTextAndSave_THEN_StoreModelIsEqual() {
		// GIVEN
		let mockStore = emptyMockStore()
		let name = "Office"
		let phone = "+1"
		let email = "office@test.ui"
		let result = mockStore.addLocation(name: name, phoneNumber: phone, emailAddress: email)

		guard case let .success(id) = result else {
			fatalError("Failure not expected")
		}

		let entry: DiaryEntry = .location(.init(id: id, name: name, phoneNumber: phone, emailAddress: email))
		
		let viewModel = DiaryAddAndEditEntryViewModel(
			mode: .edit(entry),
			store: mockStore
		)
		
		// WHEN
		viewModel.update("Homeoffice", keyPath: \DiaryAddAndEditEntryModel.name)
		viewModel.update("+2", keyPath: \DiaryAddAndEditEntryModel.phoneNumber)
		viewModel.update("home@test.ui", keyPath: \DiaryAddAndEditEntryModel.emailAddress)
		viewModel.save()
		
		// THEN
		let locationStored = mockStore.diaryDaysPublisher.value.first?.entries.first
		
		if case let .location(diaryEntry) = locationStored {
			XCTAssertEqual(diaryEntry.name, "Homeoffice")
			XCTAssertEqual(diaryEntry.phoneNumber, "+2")
			XCTAssertEqual(diaryEntry.emailAddress, "home@test.ui")
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
				.contactPerson(DiaryContactPerson(id: 4, name: "Kai Teuber", phoneNumber: "+491512221457", emailAddress: "kai@test.de")),
				.contactPerson(DiaryContactPerson(id: 5, name: "Karsten Gahn")),
				.contactPerson(DiaryContactPerson(id: 1, name: "Marcus Scherer")),
				.contactPerson(DiaryContactPerson(id: 0, name: "Nick Gündling", emailAddress: "email@test.de")),
				.contactPerson(DiaryContactPerson(id: 9, name: "Omar Ahmed", phoneNumber: "987456")),
				.contactPerson(DiaryContactPerson(id: 3, name: "Pascal Brause", phoneNumber: "123456")),
				.contactPerson(DiaryContactPerson(id: 8, name: "Puneet Mahali", emailAddress: "unkown"))
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
