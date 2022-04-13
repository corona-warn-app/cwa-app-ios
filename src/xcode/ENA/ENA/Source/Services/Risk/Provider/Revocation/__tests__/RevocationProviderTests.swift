//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class RevocationProviderTests: CWATestCase {

	func testGIVEN_base64_WHEN_ToHexString_THEN_ResultIsValid() {
		// GIVEN
		let base64 = "yLHLNvSl428="

		// WHEN
		let hexString = Data(base64Encoded: base64)?.toHexString() ?? ""

		// THEN
		XCTAssertEqual(hexString, "c8b1cb36f4a5e36f")
	}

	func testGIVEN_base64_WHEN_HexEncodedString_THEN_ResultIsValid() {
		// GIVEN
		let base64 = "yLHLNvSl428="

		// WHEN
		let hexString = Data(base64Encoded: base64)?.hexEncodedString() ?? ""

		// THEN
		XCTAssertEqual(hexString, "c8b1cb36f4a5e36f".uppercased())
	}


	func testGIVEN_given_WHEN_when_THEN_then() throws {
		// GIVEN
		let certificates = try getCertificates()

		certificates.allSatisfy { certificate in
			!certificate.keyIdentifier.isEmpty
		}

//		let verifier = MockVerifier()
//		let restService = RestServiceProviderStub(
//			loadResources: [
//				LoadResource(
//					result: .success(<#T##Any#>),
//					willLoadResource: <#T##((Any) -> Void)?##((Any) -> Void)?##(Any) -> Void#>)
//
//			]
//		)

		// WHEN

		// THEN
	}

	private func getCertificates() throws -> [HealthCertificate] {
		[
			try vaccinationCertificate(doseNumber: 1, totalSeriesOfDoses: 2),
			try vaccinationCertificate(doseNumber: 2, totalSeriesOfDoses: 2),
			try testCertificate(),
			try recoveryCertificate()
		]
	}



}
