////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class CheckinEncryptionTests: XCTestCase {

	func test_hmac_alwaysGeneratesSameHash() throws {

		let checkinEncryption = CheckinEncryption()
		let data: Data = try XCTUnwrap(Data(base64Encoded: "XyOp85hPBY51G5l4VuJ9QdxtT0HAXs+ul8spFwGj8912Tp3igoLu1L4TtpL/KaXN"))
		let key: Data = try XCTUnwrap(Data(base64Encoded: "T4jqEMtrtkhQmn+mDXoFBTji4LDiVIZNtP83axUz+bA="))
		let hash = try XCTUnwrap(checkinEncryption.hmac(data: data, key: key)).base64EncodedString()

		let otherHashes = [
			try XCTUnwrap(checkinEncryption.hmac(data: data, key: key)).base64EncodedString(),
			try XCTUnwrap(checkinEncryption.hmac(data: data, key: key)).base64EncodedString(),
			try XCTUnwrap(checkinEncryption.hmac(data: data, key: key)).base64EncodedString()
		]

		XCTAssertEqual(otherHashes.filter { $0 == hash }.count, 3)
	}

	func test_decryptCheckin_1() {
		guard let locationId = Data(base64Encoded: "m686QDEvOYSfRtrRBA8vA58c/6EjjEHp22dTFc+tObY="),
			  let encryptedCheckinRecord = Data(base64Encoded: "t5TWYYc/kn4vbWRd677L3g=="),
			  let mac = Data(base64Encoded: "BJX/KwAXo3vQBMlycMxNxiwlrNyzWdD2LeF9KCrzt/I="),
			  let iv = Data(base64Encoded: "+VNLZEr+j6qotkv8v1ASlQ==") else {
			XCTFail("Could not create test data for checkin decryption")
			return
		}

		let checkinEncryption = CheckinEncryption()

		let decryptionResult = checkinEncryption.decrypt(
			locationId: locationId,
			encryptedCheckinRecord: encryptedCheckinRecord,
			initializationVector: iv,
			messageAuthenticationCode: mac
		)

		guard case let .success(decryptedCheckinRecord) = decryptionResult else {
			XCTFail("Success expected.")
			return
		}

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

		let decryptionResult = checkinEncryption.decrypt(
			locationId: locationId,
			encryptedCheckinRecord: encryptedCheckinRecord,
			initializationVector: iv,
			messageAuthenticationCode: mac
		)

		guard case let .success(decryptedCheckinRecord) = decryptionResult else {
			XCTFail("Success expected.")
			return
		}

		var expectedCheckinRecord = SAP_Internal_Pt_CheckInRecord()
		expectedCheckinRecord.startIntervalNumber = 2710117
		expectedCheckinRecord.period = 10
		expectedCheckinRecord.transmissionRiskLevel = 8

		XCTAssertEqual(expectedCheckinRecord, decryptedCheckinRecord)
	}

	func test_encryptCheckin_1() {
		guard let locationId = Data(base64Encoded: "m686QDEvOYSfRtrRBA8vA58c/6EjjEHp22dTFc+tObY="),
			  let encryptedCheckinRecord = Data(base64Encoded: "t5TWYYc/kn4vbWRd677L3g=="),
			  let mac = Data(base64Encoded: "BJX/KwAXo3vQBMlycMxNxiwlrNyzWdD2LeF9KCrzt/I="),
			  let iv = Data(base64Encoded: "+VNLZEr+j6qotkv8v1ASlQ==") else {
			XCTFail("Could not create test data for checkin decryption")
			return
		}

		let checkinEncryption = CheckinEncryption()

		let result = checkinEncryption.encrypt(
			locationId: locationId,
			startInterval: 2710445,
			endInterval: 2710473,
			riskLevel: 7,
			initializationVector: iv
		)

		guard case let .success(encryptionResult) = result else {
			XCTFail("Success expected.")
			return
		}

		XCTAssertEqual(encryptedCheckinRecord, encryptionResult.encryptedCheckInRecord)
		XCTAssertEqual(mac, encryptionResult.messageAuthenticationCode)
	}

	func test_encryptCheckin_2() {
		guard let locationId = Data(base64Encoded: "A61rMz1EUJnH3+D/dF7FzBMw0UnvdS82w67U7+oT9yU="),
			  let encryptedCheckinRecord = Data(base64Encoded: "axfEwnDGz7r4c/n65DVDaw=="),
			  let mac = Data(base64Encoded: "vfjGr8pJ2F+IhGfHl4Audcrjhhcgr9qJ9hl176S/Il8="),
			  let iv = Data(base64Encoded: "SM6n2ApMmwWCEVwex9yrmA==") else {
			XCTFail("Could not create test data for checkin decryption")
			return
		}

		let checkinEncryption = CheckinEncryption()

		let result = checkinEncryption.encrypt(
			locationId: locationId,
			startInterval: 2710117,
			endInterval: 2710127,
			riskLevel: 8,
			initializationVector: iv
		)

		guard case let .success(encryptionResult) = result else {
			XCTFail("Success expected.")
			return
		}

		XCTAssertEqual(encryptedCheckinRecord, encryptionResult.encryptedCheckInRecord)
		XCTAssertEqual(mac, encryptionResult.messageAuthenticationCode)
	}
}
