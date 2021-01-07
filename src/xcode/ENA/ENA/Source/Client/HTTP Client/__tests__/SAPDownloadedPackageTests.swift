//
// 🦠 Corona-Warn-App
//

@testable import ENA
import XCTest
import ZIPFoundation


final class SAPDownloadedPackageTests: XCTestCase {

	private let defaultBundleId = Bundle.main.bundleIdentifier ?? "de.rki.coronawarnapp"

	private lazy var signingKey: PrivateKeyProvider = CryptoProvider.createPrivateKey()
	private lazy var mockKeyProvider: PublicKeyProtocol = CryptoProvider.createPublicKey(from: signingKey)
	private lazy var verifier = SAPDownloadedPackage.Verifier(key: { self.mockKeyProvider })
	

	// MARK: Signature Verification Tests

	func testVerifySignature_SingleSignature() throws {
		// Test the package signature verification process
		let package = try SAPDownloadedPackage.makePackage(key: signingKey)
		XCTAssertTrue(verifier(package))
	}

	func testVerifySignature_RejectModifiedBin() throws {
		// Test the package signature verification process - rejecting when the signature does not match
		let bytes = [0xA, 0xB, 0xC, 0xD] as [UInt8]
		// The bin and signature were  made for different data sets

		let package = try SAPDownloadedPackage.makePackage(
			bin: Data(bytes: bytes, count: 4),
			signature: try SAPDownloadedPackage.makeSignature(
				data: Data(bytes: bytes, count: 3),
				key: signingKey
			).asList()
		)

		XCTAssertFalse(verifier(package))
	}

	func testVerifySignature_RejectCorruptSignature() throws {
		let package = SAPDownloadedPackage(
			keysBin: Data(bytes: [0xA, 0xB, 0xC, 0xD] as [UInt8], count: 4),
			// This cannot be decoded into a SAP_External_Exposurenotification_TEKSignatureList
			signature: Data(bytes: [0xA, 0xB, 0xC, 0xD] as [UInt8], count: 4)
		)

		XCTAssertFalse(verifier(package))
	}

	func testVerifySignature_OneKeyMatchesBundleId() throws {
		// Test the case where there are multiple signatures, and one has a non-matching bundleID
		// As long as there is one valid signature for the bin data, it should pass
		let data = Data(bytes: [0xA, 0xB, 0xC, 0xD] as [UInt8], count: 4)
		let signatures = [
			try SAPDownloadedPackage.makeSignature(data: data, key: signingKey, bundleId: "hello"),
			try SAPDownloadedPackage.makeSignature(data: data, key: signingKey)
		].asList()

		let package = try SAPDownloadedPackage.makePackage(bin: data, signature: signatures)
		// When no public key to sign is found, the verification should fail
		XCTAssertTrue(verifier(package))
	}

	func testVerifySignature_OneSignatureFails() throws {
		// Create and invalidate signature
		let data = Data(bytes: [0xA, 0xB, 0xC, 0xD] as [UInt8], count: 4)
		var invalidSignature = try SAPDownloadedPackage.makeSignature(data: data, key: signingKey)
		invalidSignature.signature.append(Data(bytes: [0xE] as [UInt8], count: 1))

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
