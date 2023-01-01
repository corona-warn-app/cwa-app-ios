//
// 🦠 Corona-Warn-App
//

@testable import ENA

class CountrySelectionCellPickerSelectionPreventableMock: CountrySelectionCellPickerSelectionPreventable {
	
	var isAllowedCountrySelectionMock = false
	
	var isAllowedCountrySelection: Bool {
		isAllowedCountrySelectionMock
	}
}
