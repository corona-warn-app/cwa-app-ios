//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

final class CountrySelectionCellTests: XCTestCase {

    func testPickerViewDidSelectRow_delegate_isAllowedCountrySelection_true_selectCountry() throws {
		// GIVEN
		let sut = CountrySelectionCell(style: .default, reuseIdentifier: nil)
		let delegateMock = CountrySelectionCellPickerSelectionPreventableMock()
		sut.delegate = delegateMock
		
		guard let germany = Country(countryCode: "DE"), let unitedKingdom = Country(countryCode: "UK") else {
			return XCTFail("Expect countries as available test data for test.")
		}
		
		sut.countries = [germany, unitedKingdom]
		
		delegateMock.isAllowedCountrySelectionMock = true
		
		// WHEN
		sut.pickerView(UIPickerView(), didSelectRow: 1, inComponent: 0)
		
		// THEN
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
			XCTAssertEqual(sut.selectedCountry, sut.countries[1])
		}
    }
	
	func testPickerViewDidSelectRow_delegate_isAllowedCountrySelection_false_selectCountry() throws {
		// GIVEN
		let sut = CountrySelectionCell(style: .default, reuseIdentifier: nil)
		let delegateMock = CountrySelectionCellPickerSelectionPreventableMock()
		sut.delegate = delegateMock
		
		guard let germany = Country(countryCode: "DE"), let unitedKingdom = Country(countryCode: "UK") else {
			return XCTFail("Expect countries as available test data for test.")
		}
		
		sut.countries = [germany, unitedKingdom]
		
		delegateMock.isAllowedCountrySelectionMock = false
		
		// WHEN
		sut.pickerView(UIPickerView(), didSelectRow: 1, inComponent: 0)
		
		// THEN
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
			XCTAssertNil(sut.selectedCountry)
		}
	}

}
