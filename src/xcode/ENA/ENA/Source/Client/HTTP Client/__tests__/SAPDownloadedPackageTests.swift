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

	// MARK: Signature Verification Tests

	func testVerifySignature_SingleSignature() throws {
		// Test the package signature verification process
		let package = try makePackage()
		XCTAssertTrue(package.verifySignature(with: MockKeyStore(keys: [defaultBundleId: publicKey])))
	}

	func testVerifySignature_RejectModifiedBin() throws {
		// Test the package signature verification process - rejecting when the signature does not match
		let bytes = [0xA, 0xB, 0xC, 0xD]
		// The bin and signature were  made for different data sets
		let package = try makePackage(bin: Data(bytes: bytes, count: 4),
									  signature: try makeSignature(data: Data(bytes: bytes, count: 3)).asList() //swiftlint:disable:this vertical_parameter_alignment_on_call
		)

		XCTAssertFalse(package.verifySignature(with: MockKeyStore(keys: [defaultBundleId: publicKey])))
	}

	func testVerifySignature_RejectCorruptSignature() throws {
		let package = SAPDownloadedPackage(
			keysBin: Data(bytes: [0xA, 0xB, 0xC, 0xD], count: 4),
			// This cannot be decoded into a SAP_TEKSignatureList
			signature: Data(bytes: [0xA, 0xB, 0xC, 0xD], count: 4)
		)

		XCTAssertFalse(package.verifySignature(with: MockKeyStore(keys: [defaultBundleId: publicKey])))
	}

	func testVerifySignature_OneKeyMatchesBundleId() throws {
		// Test the case where there are multiple signatures, and one has a non-matching bundleID
		// As long as there is one valid signature for the bin data, it should pass
		let data = Data(bytes: [0xA, 0xB, 0xC, 0xD], count: 4)
		let signatures = [
			try makeSignature(data: data, bundleId: "hello"),
			try makeSignature(data: data)
		].asList()

		let package = try makePackage(bin: data, signature: signatures)
		// When no public key to sign is found, the verification should fail
		XCTAssertTrue(package.verifySignature(with: MockKeyStore(keys: [defaultBundleId: publicKey])))
	}

	func testVerifySignature_OneSignatureFails() throws {
		// Test the case where there are multiple signatures, and one is invalid
		// As long as one is valid, we should still pass.
		let data = Data(bytes: [0xA, 0xB, 0xC, 0xD], count: 4)
		var invalidSignature = try makeSignature(data: data)
		invalidSignature.signature.append(Data(bytes: [0xE], count: 1))

		let signatures = [
			invalidSignature,
			try makeSignature(data: data)
		].asList()

		let package = try makePackage(bin: data, signature: signatures)
		// When no public key to sign is found, the verification should fail
		XCTAssertTrue(package.verifySignature(with: MockKeyStore(keys: [defaultBundleId: publicKey])))
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

// MARK: - Helpers

private extension SAPDownloadedPackageTests {

	/// - note: Will SHA256 hash the data
	func makeSignature(data: Data, bundleId: String = "de.rki.coronawarnapp") throws -> SAP_TEKSignature {
		var signature = SAP_TEKSignature()
		signature.signature = try signingKey.signature(for: data).derRepresentation
		signature.signatureInfo = makeSignatureInfo(bundleId: bundleId)

		return signature
	}

	func makeSignatureInfo(bundleId: String = "de.rki.coronawarnapp") -> SAP_SignatureInfo {
		var info = SAP_SignatureInfo()
		info.appBundleID = bundleId

		return info
	}

	func makePackage(bin: Data, signature: SAP_TEKSignatureList) throws -> SAPDownloadedPackage {
		return SAPDownloadedPackage(
			keysBin: bin,
			signature: try signature.serializedData()
		)
	}

	func makePackage(bin: Data = Data(bytes: [0xA, 0xB, 0xC], count: 3)) throws -> SAPDownloadedPackage {
		let signature = try makeSignature(data: bin).asList()
		return try makePackage(bin: bin, signature: signature)
	}
}

private extension SAP_TEKSignature {
	func asList() -> SAP_TEKSignatureList {
		var signatureList = SAP_TEKSignatureList()
		signatureList.signatures = [self]

		return signatureList
	}
}

private extension Array where Element == SAP_TEKSignature {
	func asList() -> SAP_TEKSignatureList {
		var signatureList = SAP_TEKSignatureList()
		signatureList.signatures = self

		return signatureList
	}
}

private struct MockKeyStore: PublicKeyStore {
	let keys: [String: P256.Signing.PublicKey]

	func publicKey(for bundleID: String) throws -> P256.Signing.PublicKey {
		guard let key = keys[bundleID] else {
			throw KeyError.environmentError
		}

		return key
	}
}
