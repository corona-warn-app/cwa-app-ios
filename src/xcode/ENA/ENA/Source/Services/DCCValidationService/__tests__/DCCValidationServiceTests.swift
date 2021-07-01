////
// 🦠 Corona-Warn-App
//

@testable import ENA
import XCTest

class DCCValidationServiceTests: XCTestCase {
	
	func testGIVEN_ValidationService_WHEN_GetOnbaordedCountriesHappyCase_THEN_CountriesAreReturned() {
		// GIVEN
		let client = ClientMock()
		let store = MockTestStore()
		let validationService = DCCValidationService(
			store: store,
			client: client
		)
		
		// WHEN
		
		
		// THEN
		
		
	}
}
