////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class CheckinEncryptionTests: XCTestCase {

	func test_decryptCheckin_1() {
		guard let locationId = Data(base64Encoded: "m686QDEvOYSfRtrRBA8vA58c/6EjjEHp22dTFc+tObY="),
			  let encryptedCheckinRecord = Data(base64Encoded: "t5TWYYc/kn4vbWRd677L3g=="),
			  let mac = Data(base64Encoded: "BJX/KwAXo3vQBMlycMxNxiwlrNyzWdD2LeF9KCrzt/I="),
			  let iv = Data(base64Encoded: "+VNLZEr+j6qotkv8v1ASlQ==") else {
			XCTFail("Could not create test data for checkin decryption")
			return
		}

		let checkinEncryption = CheckinEncryption()

		let decryptedCheckinRecord = checkinEncryption.decrypt(
			locationId: locationId,
			encryptedCheckinRecord: encryptedCheckinRecord,
			initializationVector: iv,
			messageAuthenticationCode: mac
		)

		var expectedCheckinRecord = SAP_Internal_Pt_CheckInRecord()
		expectedCheckinRecord.startIntervalNumber = 2710445
		expectedCheckinRecord.period = 28
		expectedCheckinRecord.transmissionRiskLevel = 7

		XCTAssertEqual(expectedCheckinRecord, decryptedCheckinRecord)
	}

	func test_decryptCheckin_2() {
		guard let locationId = Data(base64Encoded: "A61rMz1EUJnH3+D/dF7FzBMw0UnvdS82w67U7+oT9yU="),
			  let encryptedCheckinRecord = Data(base64Encoded: "axfEwnDGz7r4c/n65DVDaw=="),
			  let mac = Data(base64Encoded: "vfjGr8pJ2F+IhGfHl4Audcrjhhcgr9qJ9hl176S/Il8="),
			  let iv = Data(base64Encoded: "SM6n2ApMmwWCEVwex9yrmA==") else {
			XCTFail("Could not create test data for checkin decryption")
			return
		}

		let checkinEncryption = CheckinEncryption()

		let decryptedCheckinRecord = checkinEncryption.decrypt(
			locationId: locationId,
			encryptedCheckinRecord: encryptedCheckinRecord,
			initializationVector: iv,
			messageAuthenticationCode: mac
		)

		var expectedCheckinRecord = SAP_Internal_Pt_CheckInRecord()
		expectedCheckinRecord.startIntervalNumber = 2710117
		expectedCheckinRecord.period = 10
		expectedCheckinRecord.transmissionRiskLevel = 8

		XCTAssertEqual(expectedCheckinRecord, decryptedCheckinRecord)
	}

	func test_encryptCheckins() {
		
	}
}
