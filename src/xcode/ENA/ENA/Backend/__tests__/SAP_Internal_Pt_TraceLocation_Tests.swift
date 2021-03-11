////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class SAP_Internal_Pt_TraceLocation_Tests: XCTestCase {


    func testDecodingFromBase32StringSample1() throws {
		let base32String = "BISDGMBVGUZTGMLDFUZDGMBWFU2DGZRTFU4TONBSFU3GIODGMFRDKNDFHA2DQEABDABCEEKNPEQEE2LSORUGIYLZEBIGC4TUPEVAWYLUEBWXSIDQNRQWGZJQ2OD2IAJY66D2IAKAAA"
		guard let data = base32String.base32DecodedData else {
			XCTFail("Failed to decode Data")
			return
		}
		let traceLocation = try SAP_Internal_Pt_TraceLocation(serializedData: data)
		XCTAssertEqual(traceLocation.guid, "3055331c-2306-43f3-9742-6d8fab54e848")
		XCTAssertEqual(traceLocation.version, 1)
		XCTAssertEqual(traceLocation.type, SAP_Internal_Pt_TraceLocationType(rawValue: 2))
		XCTAssertEqual(traceLocation.description_p, "My Birthday Party")
		XCTAssertEqual(traceLocation.address, "at my place")
		XCTAssertEqual(traceLocation.startTimestamp, 2687955)
		XCTAssertEqual(traceLocation.endTimestamp, 2687991)
		XCTAssertEqual(traceLocation.defaultCheckInLengthInMinutes, 0)
		
    }
	
	
	func testDecodingFromBase32StringSample2() throws {
		let base32String = "BISGMY3BHA2GEMZXFU3DCYZQFU2GCN3DFVRDEZRYFU4DENLDMFSGINJQGZRWMEABDAASEDKJMNSWG4TFMFWSAU3IN5YCUDKNMFUW4ICTORZGKZLUEAYTAABYABAAU"
		guard let data = base32String.base32DecodedData else {
			XCTFail("Failed to decode Data")
			return
		}
		let traceLocation = try SAP_Internal_Pt_TraceLocation(serializedData: data)
		XCTAssertEqual(traceLocation.guid, "fca84b37-61c0-4a7c-b2f8-825cadd506cf")
		XCTAssertEqual(traceLocation.version, 1)
		XCTAssertEqual(traceLocation.type, SAP_Internal_Pt_TraceLocationType(rawValue: 1))
		XCTAssertEqual(traceLocation.description_p, "Icecream Shop")
		XCTAssertEqual(traceLocation.address, "Main Street 1")
		XCTAssertEqual(traceLocation.startTimestamp, 0)
		XCTAssertEqual(traceLocation.endTimestamp, 0)
		XCTAssertEqual(traceLocation.defaultCheckInLengthInMinutes, 10)
		
	}

}
