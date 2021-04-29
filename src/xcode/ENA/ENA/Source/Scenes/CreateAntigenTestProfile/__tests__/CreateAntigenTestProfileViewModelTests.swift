////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class CreateAntigenTestProfileViewModelTests: XCTestCase {
	
	func testGIVEN_EmptyAntigenTestProfile_THEN_SetValues() {
		// GIVEN
		let store = MockTestStore()
		let viewModel = CreateAntigenTestProfileViewModel(store: store)
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
			}
		}
	}
	
	func testGIVEN_EmptyAntigenTestProfile_THEN_SetOneValueAndCheckIfEligibleToSave() {
		// GIVEN
		let store = MockTestStore()
		let viewModel = CreateAntigenTestProfileViewModel(store: store)
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
			}
		}
	}
	
	func testGIVEN_EmptyAntigenTestProfile_THEN_SetOneValueAndSave() {
		// GIVEN
		let store = MockTestStore()
		let viewModel = CreateAntigenTestProfileViewModel(store: store)
		// THEN
		viewModel.update("Max", keyPath: \.firstName)
		viewModel.save()
		
		do {
			let savedAntigenTestProfile = try XCTUnwrap(store.antigenTestProfile)
			XCTAssertTrue(savedAntigenTestProfile.firstName == viewModel.antigenTestProfile.firstName)
		} catch {
			XCTFail(error.localizedDescription)
		}
	}
}
