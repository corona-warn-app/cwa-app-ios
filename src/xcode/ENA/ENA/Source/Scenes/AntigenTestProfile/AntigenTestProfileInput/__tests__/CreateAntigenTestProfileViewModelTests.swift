////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class CreateAntigenTestProfileViewModelTests: CWATestCase {
	
	func testGIVEN_EmptyAntigenTestProfile_THEN_SetValues() {
		// GIVEN
		let store = MockTestStore()
		let antigenTestProfile = AntigenTestProfile(
			firstName: "",
			lastName: "",
			dateOfBirth: nil,
			addressLine: "",
			zipCode: "",
			city: "",
			phoneNumber: "",
			email: ""
		)
		store.antigenTestProfiles = [antigenTestProfile]
		let viewModel = AntigenTestProfileInputViewModel(store: store, antigenTestProfile: antigenTestProfile)
		
		// THEN
		AntigenTestProfile.CodingKeys.allCases.forEach { key in
			switch key {
			case .firstName:
				viewModel.update("Max", keyPath: \.firstName)
				XCTAssertNotNil(viewModel.antigenTestProfile.firstName)
			case .lastName:
				viewModel.update("Mustermann", keyPath: \.lastName)
				XCTAssertNotNil(viewModel.antigenTestProfile.lastName)
			case .dateOfBirth:
				viewModel.update(Date(timeIntervalSince1970: 390047238), keyPath: \.dateOfBirth)
				XCTAssertNotNil(viewModel.antigenTestProfile.dateOfBirth)
			case .addressLine:
				viewModel.update("Blumenstraße 2", keyPath: \.addressLine)
				XCTAssertNotNil(viewModel.antigenTestProfile.addressLine)
			case .zipCode:
				viewModel.update("43923", keyPath: \.zipCode)
				XCTAssertNotNil(viewModel.antigenTestProfile.zipCode)
			case .city:
				viewModel.update("Berlin", keyPath: \.city)
				XCTAssertNotNil(viewModel.antigenTestProfile.city)
			case .phoneNumber:
				viewModel.update("0165434563", keyPath: \.phoneNumber)
				XCTAssertNotNil(viewModel.antigenTestProfile.phoneNumber)
			case .email:
				viewModel.update("sabine.schulz@gmx.com", keyPath: \.email)
				XCTAssertNotNil(viewModel.antigenTestProfile.email)
			case .id:
				break
			}
		}
	}
	
	func testGIVEN_EmptyAntigenTestProfile_THEN_SetOneValueAndCheckIfEligibleToSave() {
		// GIVEN
		let store = MockTestStore()
		let antigenTestProfile = AntigenTestProfile(
			firstName: "",
			lastName: "",
			dateOfBirth: nil,
			addressLine: "",
			zipCode: "",
			city: "",
			phoneNumber: "",
			email: ""
		)
		store.antigenTestProfiles = [antigenTestProfile]
		let viewModel = AntigenTestProfileInputViewModel(store: store, antigenTestProfile: antigenTestProfile)
		
		// THEN
		AntigenTestProfile.CodingKeys.allCases.forEach { key in
			switch key {
			case .firstName:
				viewModel.update("Max", keyPath: \.firstName)
				XCTAssertTrue(viewModel.antigenTestProfile.isEligibleToSave)
				viewModel.update(nil, keyPath: \.firstName)
			case .lastName:
				viewModel.update("Mustermann", keyPath: \.lastName)
				XCTAssertTrue(viewModel.antigenTestProfile.isEligibleToSave)
				viewModel.update(nil, keyPath: \.lastName)
			case .dateOfBirth:
				viewModel.update(Date(timeIntervalSince1970: 390047238), keyPath: \.dateOfBirth)
				XCTAssertTrue(viewModel.antigenTestProfile.isEligibleToSave)
				viewModel.update(nil, keyPath: \.dateOfBirth)
			case .addressLine:
				viewModel.update("Blumenstraße 2", keyPath: \.addressLine)
				XCTAssertTrue(viewModel.antigenTestProfile.isEligibleToSave)
				viewModel.update(nil, keyPath: \.addressLine)
			case .zipCode:
				viewModel.update("43923", keyPath: \.zipCode)
				XCTAssertTrue(viewModel.antigenTestProfile.isEligibleToSave)
				viewModel.update(nil, keyPath: \.zipCode)
			case .city:
				viewModel.update("Berlin", keyPath: \.city)
				XCTAssertTrue(viewModel.antigenTestProfile.isEligibleToSave)
				viewModel.update(nil, keyPath: \.city)
			case .phoneNumber:
				viewModel.update("0165434563", keyPath: \.phoneNumber)
				XCTAssertTrue(viewModel.antigenTestProfile.isEligibleToSave)
				viewModel.update(nil, keyPath: \.phoneNumber)
			case .email:
				viewModel.update("sabine.schulz@gmx.com", keyPath: \.email)
				XCTAssertTrue(viewModel.antigenTestProfile.isEligibleToSave)
				viewModel.update(nil, keyPath: \.email)
			case .id:
				break
			}
		}
	}
	
	func testGIVEN_EmptyAntigenTestProfile_THEN_SetOneValueAndSave() {
		// GIVEN
		let store = MockTestStore()
		let antigenTestProfile = AntigenTestProfile(
			firstName: "",
			lastName: "",
			dateOfBirth: nil,
			addressLine: "",
			zipCode: "",
			city: "",
			phoneNumber: "",
			email: ""
		)
		store.antigenTestProfiles = [antigenTestProfile]
		let viewModel = AntigenTestProfileInputViewModel(store: store, antigenTestProfile: antigenTestProfile)
		
		// THEN
		viewModel.update("Max", keyPath: \.firstName)
		viewModel.save()
		
		do {
			let savedAntigenTestProfile = try XCTUnwrap(store.antigenTestProfiles[0])
			XCTAssertTrue(savedAntigenTestProfile.firstName == viewModel.antigenTestProfile.firstName)
		} catch {
			XCTFail(error.localizedDescription)
		}
	}
	
	func testGIVEN_AntigenTestProfile_THENEncodeAndDecode() {
		// GIVEN
		let store = MockTestStore()
		let antigenTestProfile = AntigenTestProfile(
			firstName: "Max",
			lastName: "Mustermann",
			dateOfBirth: Date(timeIntervalSince1970: 390047238),
			addressLine: "Blumenstraße 2",
			zipCode: "43923",
			city: "Berlin",
			phoneNumber: "0165434563",
			email: "sabine.schulz@gmx.com"
		)
		store.antigenTestProfiles = [antigenTestProfile]
		let viewModel = AntigenTestProfileInputViewModel(store: store, antigenTestProfile: antigenTestProfile)
		
		// THEN
		let calendar = Calendar.current
		let day: Int = 17
		var components = DateComponents()
		components.day = day
		components.month = 5
		components.year = 1900
		components.hour = 0
		components.minute = 30
		components.calendar = calendar
		components.timeZone = TimeZone(secondsFromGMT: 7200)
		
		do {
			let date = try XCTUnwrap(components.date)
			
			viewModel.update(date, keyPath: \.dateOfBirth)
			viewModel.save()
			
			let savedAntigenTestProfile = try XCTUnwrap(store.antigenTestProfiles[0])
			
			let encoder = JSONEncoder()
			let encodedData = try encoder.encode(savedAntigenTestProfile)
			
			let decoder = JSONDecoder()
			let decodedAntigenTestProfile = try decoder.decode(AntigenTestProfile.self, from: encodedData)
			let decodedDate = try XCTUnwrap(decodedAntigenTestProfile.dateOfBirth)
			
			XCTAssertTrue(calendar.isDate(decodedDate, equalTo: date, toGranularity: .day))
			
		} catch {
			XCTFail(error.localizedDescription)
		}
	}

	func testAntigenTestProfileSorting() {
		// GIVEN
		let store = MockTestStore()
		let antigenTestProfile1 = AntigenTestProfile(
			firstName: "Max",
			lastName: "Mustermann",
			dateOfBirth: Date(timeIntervalSince1970: 390047238),
			addressLine: "Blumenstraße 2",
			zipCode: "43923",
			city: "Berlin",
			phoneNumber: "0165434563",
			email: "sabine.schulz@gmx.com"
		)
		
		let antigenTestProfile2 = AntigenTestProfile(
			firstName: "Sabine",
			lastName: "Schulz",
			dateOfBirth: Date(timeIntervalSince1970: 390047238),
			addressLine: "Blumenstraße 2",
			zipCode: "43923",
			city: "Berlin",
			phoneNumber: "0165434563",
			email: "sabine.schulz@gmx.com"
		)
		
		let antigenTestProfile3 = AntigenTestProfile(
			firstName: "Anna",
			lastName: "Schulz",
			dateOfBirth: Date(timeIntervalSince1970: 390047238),
			addressLine: "Blumenstraße 2",
			zipCode: "43923",
			city: "Berlin",
			phoneNumber: "0165434563",
			email: "sabine.schulz@gmx.com"
		)
		
		store.antigenTestProfiles = [antigenTestProfile2, antigenTestProfile1]
		let viewModel = AntigenTestProfileInputViewModel(store: store, antigenTestProfile: antigenTestProfile3)
		
		// THEN
		viewModel.save()
		
		do {
			// should be Anna
			let storedAntigenTestProfile1 = try XCTUnwrap(store.antigenTestProfiles[0])
			XCTAssertTrue(storedAntigenTestProfile1.fullName == antigenTestProfile3.fullName)
			
			// should be Max
			let storedAntigenTestProfile2 = try XCTUnwrap(store.antigenTestProfiles[1])
			XCTAssertTrue(storedAntigenTestProfile2.fullName == antigenTestProfile1.fullName)
			
			// should Sabine
			let storedAntigenTestProfile3 = try XCTUnwrap(store.antigenTestProfiles[2])
			XCTAssertTrue(storedAntigenTestProfile3.fullName == antigenTestProfile2.fullName)
			
		} catch {
			XCTFail(error.localizedDescription)
		}
	}
}
