// Corona-Warn-App
//
// SAP SE and all other contributors
// copyright owners license this file to you under the Apache
// License, Version 2.0 (the "License"); you may not use this
// file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

@testable import ENA
import XCTest
import CryptoKit
import ZIPFoundation

final class SAPDownloadedPackageTests: XCTestCase {

	private lazy var signingKey = P256.Signing.PrivateKey()
	private lazy var publicKey = signingKey.publicKey
	private let defaultBundleId = Bundle.main.bundleIdentifier ?? "de.rki.coronawarnapp"
	private lazy var mockKeyProvider: PublicKeyProviding = { _ in return self.publicKey }
	private lazy var verifier = SAPDownloadedPackage.Verifier(key: mockKeyProvider)

	// MARK: Signature Verification Tests

	func testVerifySignature_SingleSignature() throws {
		// Test the package signature verification process
		let package = try SAPDownloadedPackage.makePackage(key: signingKey)
		XCTAssertTrue(verifier(package))
	}

	func testVerifySignature_RejectModifiedBin() throws {
		// Test the package signature verification process - rejecting when the signature does not match
		let bytes = [0xA, 0xB, 0xC, 0xD]
		// The bin and signature were  made for different data sets
		let package = try SAPDownloadedPackage.makePackage(bin: Data(bytes: bytes, count: 4),
														   signature: try SAPDownloadedPackage.makeSignature(data: Data(bytes: bytes, count: 3), key: signingKey).asList() //swiftlint:disable:this vertical_parameter_alignment_on_call
		)

		XCTAssertFalse(verifier(package))
	}

	func testVerifySignature_RejectCorruptSignature() throws {
		let package = SAPDownloadedPackage(
			keysBin: Data(bytes: [0xA, 0xB, 0xC, 0xD], count: 4),
			// This cannot be decoded into a SAP_TEKSignatureList
			signature: Data(bytes: [0xA, 0xB, 0xC, 0xD], count: 4)
		)

		XCTAssertFalse(verifier(package))
	}

	func testVerifySignature_OneKeyMatchesBundleId() throws {
		// Test the case where there are multiple signatures, and one has a non-matching bundleID
		// As long as there is one valid signature for the bin data, it should pass
		let data = Data(bytes: [0xA, 0xB, 0xC, 0xD], count: 4)
		let signatures = [
			try SAPDownloadedPackage.makeSignature(data: data, key: signingKey, bundleId: "hello"),
			try SAPDownloadedPackage.makeSignature(data: data, key: signingKey)
		].asList()

		let package = try SAPDownloadedPackage.makePackage(bin: data, signature: signatures)
		// When no public key to sign is found, the verification should fail
		XCTAssertTrue(verifier(package))
	}

	func testVerifySignature_OneSignatureFails() throws {
		// Test the case where there are multiple signatures, and one is invalid
		// As long as one is valid, we should still pass.
		let data = Data(bytes: [0xA, 0xB, 0xC, 0xD], count: 4)
		var invalidSignature = try SAPDownloadedPackage.makeSignature(data: data, key: signingKey)
		invalidSignature.signature.append(Data(bytes: [0xE], count: 1))

		let signatures = [
			invalidSignature,
			try SAPDownloadedPackage.makeSignature(data: data, key: signingKey)
		].asList()

		let package = try SAPDownloadedPackage.makePackage(bin: data, signature: signatures)
		// Only one signature is necessary to pass the check
		XCTAssertTrue(verifier(package))
	}

	// MARK: - Init from ZIP Tests

	func testInitFromZIP() throws {
		guard
			let someData = "Some string!".data(using: .utf8),
			let archive = Archive(accessMode: .create)
		else {
			XCTFail("Guard failed!")
			return
		}

		try archive.addEntry(with: "export.bin", type: .file, uncompressedSize: 12, bufferSize: 4, provider: { position, size -> Data in
			return someData.subdata(in: position..<position + size)
		})

		try archive.addEntry(with: "export.sig", type: .file, uncompressedSize: 12, bufferSize: 4, provider: { position, size -> Data in
			return someData.subdata(in: position..<position + size)
		})
		let archiveData = archive.data ?? Data()

		XCTAssertNotNil(SAPDownloadedPackage(compressedData: archiveData))
	}

	func testInitFromZIP_binNotFound() throws {
		guard
			let someData = "Some string!".data(using: .utf8),
			let archive = Archive(accessMode: .create)
		else {
			XCTFail("Guard failed!")
			return
		}

		try archive.addEntry(with: "export.bin", type: .file, uncompressedSize: 12, bufferSize: 4, provider: { position, size -> Data in
			return someData.subdata(in: position..<position + size)
		})
		let archiveData = archive.data ?? Data()

		XCTAssertNil(SAPDownloadedPackage(compressedData: archiveData))
	}

	func testInitFromZIP_sigNotFound() throws {
		guard
			let someData = "Some string!".data(using: .utf8),
			let archive = Archive(accessMode: .create)
		else {
			XCTFail("Guard failed!")
			return
		}

		try archive.addEntry(with: "export.sig", type: .file, uncompressedSize: 12, bufferSize: 4, provider: { position, size -> Data in
			return someData.subdata(in: position..<position + size)
		})
		let archiveData = archive.data ?? Data()

		XCTAssertNil(SAPDownloadedPackage(compressedData: archiveData))
	}

	func testInitFromZIP_extractFailed() throws {
		XCTAssertNil(SAPDownloadedPackage(compressedData: Data()))
	}
}
