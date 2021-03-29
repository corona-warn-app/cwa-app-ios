////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class SAP_Internal_Pt_TraceLocation_Tests: XCTestCase {


    func testDecodingFromBase32StringSample1() throws {
		let base32String = "BAAREEKNPEQEE2LSORUGIYLZEBIGC4TUPENAWYLUEBWXSIDQNRQWGZJI2OD2IAJQ66D2IAI"
		guard let data = base32String.base32DecodedData else {
			XCTFail("Failed to decode Data")
			return
		}
		let traceLocation = try SAP_Internal_Pt_TraceLocation(serializedData: data)
		XCTAssertEqual(traceLocation.version, 1)
		XCTAssertEqual(traceLocation.description_p, "My Birthday Party")
		XCTAssertEqual(traceLocation.address, "at my place")
		XCTAssertEqual(traceLocation.startTimestamp, 2687955)
		XCTAssertEqual(traceLocation.endTimestamp, 2687991)
		
    }
	
	
	func testDecodingFromBase32StringSample2() throws {
		let base32String = "BAAREDKJMNSWG4TFMFWSAU3IN5YBUDKNMFUW4ICTORZGKZLUEAYQ"
		guard let data = base32String.base32DecodedData else {
			XCTFail("Failed to decode Data")
			return
		}
		let traceLocation = try SAP_Internal_Pt_TraceLocation(serializedData: data)
		XCTAssertEqual(traceLocation.version, 1)
		XCTAssertEqual(traceLocation.description_p, "Icecream Shop")
		XCTAssertEqual(traceLocation.address, "Main Street 1")
		XCTAssertEqual(traceLocation.startTimestamp, 0)
		XCTAssertEqual(traceLocation.endTimestamp, 0)	
	}

}
