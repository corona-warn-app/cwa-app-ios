////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class SAP_Internal_Evreg_Event_Tests: XCTestCase {


    func testDecodingFromString() throws {
		let base32String = "BIIERN7QBM6EQXDAMWF2BCZ26TQYCEQQINLUCICMMF2W4Y3IEBIGC4TUPEMNHB5EAEQPPB5EAEUB4==="
		guard let data = base32String.base32DecodedData else {
			XCTFail("Failed to decode Data")
			return
		}
		let event = try SAP_Internal_Evreg_Event(serializedData: data)
		XCTAssertEqual(event.description_p, "CWA Launch Party")
		XCTAssertEqual(event.start, 2687955)
		XCTAssertEqual(event.end, 2687991)
		XCTAssertEqual(event.defaultCheckInLengthInMinutes, 30)
		
    }

}
