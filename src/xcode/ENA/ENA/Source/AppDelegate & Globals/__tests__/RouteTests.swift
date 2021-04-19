////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class RouteTests: XCTestCase {

	func testGIVEN_validRATUrl_WHEN_parseRoute_THEN_isValid() {
		// GIVEN
		let validRATTestURL = "https://s.coronawarn.app?v=1#eyJ0aW1lc3RhbXAiOjE2MTg4MjQwNjIsInNhbHQiOiI1NjkxMDIzMTAyNkEzQ0Y3RDg5MTk3RkI4MjFDRDg3RDNFNDc1NEJCMDIwMzI1REU1MjA3RDcxNDM5OEI0MTlBIiwidGVzdElkIjoiM2U0YWQ1OGQtOWY5MS00NTgyLThhMmUtYWI5ZjkzMTg3YTBlIiwiaGFzaCI6IjI3N2ZiZDBhYzFlMTBjNWVmZDMxOTU1M2NlYmVmZjljODM3NGY4MGM1MTg3NmRhMDNjZjQxYWRkMmIzZmE3YWYiLCJmbiI6IkR1c3RpbiIsImxuIjoiRmVycmkiLCJkb2IiOiIxOTkxLTA3LTIxIn0="

		// WHEN
		let route = Route(validRATTestURL)
		guard case let .rapidAntigen(result) = route else {
			XCTFail("unexpected route type")
			return
		}

		// THEN
		switch result {
		case .success:
			break
		case .failure:
			XCTFail("Error was nor intended")
		}
	}

	func testGIVEN_invalidRATUrl_WHEN_parseRoute_THEN_isValid() {
		// GIVEN
		let validRATTestURL = "https://s.coronawarn.app?v=1#eJ0aW1lc3RhbXAiOjE2MTg0ODI2MzksImd1aWQiOiIzM0MxNDNENS0yMTgyLTQ3QjgtOTM4NS02ODBGMzE4RkU0OTMiLCJmbiI6IlJveSIsImxuIjoiRnJhc3NpbmV0aSIsImRvYiI6IjE5ODEtMTItMDEifQ=="

		// WHEN
		let route = Route(validRATTestURL)
		guard case let .rapidAntigen(result) = route else {
			XCTFail("unexpected route type")
			return
		}

		// THEN
		switch result {
		case .success:
			XCTFail("Route parse success wasn't expected")
		case .failure:
			break
		}
	}

}
