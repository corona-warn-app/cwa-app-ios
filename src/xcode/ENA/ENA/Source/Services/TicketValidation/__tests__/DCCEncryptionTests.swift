//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
@testable import ENA

final class DCCEncryptionTests: XCTestCase {
	
	func test_encryptAndSignDCC() throws {
		let publicKeyData = try XCTUnwrap(Data(base64Encoded: publicKeyBase64))
		let privatKeyData = try XCTUnwrap(Data(base64Encoded: privateKeyBase64))

		let publicKeyAttributes: [String: Any] = [
					kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
					kSecAttrKeyClass as String: kSecAttrKeyClassPublic
				]
		var publicKeyError: Unmanaged<CFError>?
		guard let publicKey = SecKeyCreateWithData(
			publicKeyData as CFData,
			publicKeyAttributes as CFDictionary,
			&publicKeyError
		) else {
			XCTFail("Failed to create key.")
			return
		}
		guard publicKeyError == nil else {
			XCTFail("Key generation failed with error: \(String(describing: publicKeyError))")
			return
		}

		guard let privatKey = SecKey.privateECKey(from: privatKeyData as CFData) else {
			XCTFail("Failed to create key.")
			return
		}
		
		let dccEncryption = DCCEncryption()
		let result = dccEncryption.encryptAndSignDCC(
			dccBarcodeData: "U29tZQ==",
			nonceBase64: "MTIzNDU2Nzg5MTIzNDU2Nw==",
			encryptionScheme: .RSAOAEPWithSHA256AESCBC,
			publicKeyForEncryption: publicKey,
			privateKeyForSigning: privatKey
		)
		
		if case .failure(let error) = result {
			XCTFail("Failed with error: \(error)")
		}
	}
	
	// swiftlint:disable:next line_length
	let publicKeyBase64 = "MIIBojANBgkqhkiG9w0BAQEFAAOCAY8AMIIBigKCAYEAvaAibNOuVrhGI1WWAka8WVuroFiX1hoAJ7fR6wjL4Kuw1rHedWfpjF7Su/YWqoS//o5GeYPTFGaTIivsTzPrDiGYQRNyC0VpOG6IKoSbN9yRuMxNrOZLIeL0bov79Mz6+3ce5mIRFbKMguaW5wvSOulJMnP/FowZmb8Qplg0jH8H5tywTDct3n7CLiTH/StIdGOf9G6ncqFrNIAmAymP0rX3pAmFGszM52IuaNh8bhoyByocHN+ub2VXCwgNYopOq/6iyit9dsnO1dY9YAHZUzM6MFfOhNoposPxORWlL8Lr0i7TPvWpffWHuPOdcMN5KcKfSmOnWjsLa944w56QN5le+8Pqk4qSuDtty+bN3HRv5ZL1laMEpmzvzs6M8c13HvvfBrhBlnLCES+WXbYlWtLorpExpJ3SCfUtvKp/rD6VQT49idQrHVAquj9+2z7k/GhCO7h2WDs/4vx+T4wLMEDcuwI92tipc7mJBZNAuH85kmk0P1x3Y20J9MJAzZvRAgMBAAE="
	let privateKeyBase64 = "MHcCAQEEIIIihYR7g405IESCjzqoUBTVi10rw+KoI4GA40QOrGCroAoGCCqGSM49AwEHoUQDQgAEqrIRZyw2XD7RhUAMXn/2gm9S1Z8BFrQd+peTEixW+jT3gzErD9a7hyZQXHHspqgwwmgUY6VX4NxR1puM43FTPQ=="
	
}
