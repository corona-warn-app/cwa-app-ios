//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class RevocationProviderTests: CWATestCase {

	func testUpdatingCacheSuccessfully() throws {
		let restService = RestServiceProviderStub(
			loadResources: [
				// KID list update
				LoadResource(
					result: .success(self.revocationKidList),
					willLoadResource: nil
				),
				// Update KID-Type index for recovery certificate key identifier, hash type 0a
				// As the requests are done sorted by type, 0a should be requested first
				LoadResource(
					result: .success(try self.kidTypeIndex()),
					willLoadResource: { resource in
						guard let resource = resource as? KIDTypeIndexResource else {
							XCTFail("wrong resource type")
							return
						}

						XCTAssertEqual(resource.locator.paths, ["version", "v1", "dcc-rl", "\(self.recoveryCertificateKeyIdentifier)0a"])
					}
				),
				// Update KID-Type chunk for recovery certificate, recovery certificate is revoked
				LoadResource(
					result: .success(try self.revocationChunk()),
					willLoadResource: { resource in
						guard let resource = resource as? KIDTypeChunkResource else {
							XCTFail("wrong resource type, KIDTypeChunkResource expected")
							return
						}

						XCTAssertEqual(resource.locator.paths, ["version", "v1", "dcc-rl", "\(self.recoveryCertificateKeyIdentifier)0a", "e3", "d6", "chunk"])
					}
				),
				// As recovery certificate is revoked after checking with hash type 0a already, 0b KID-Type index update is skipped for recovery certificate
				// Continue with update of KID-Type index for booster certificate key identifier, hash type 0b
				LoadResource(
					result: .success(try self.kidTypeIndex()),
					willLoadResource: { resource in
						guard let resource = resource as? KIDTypeIndexResource else {
							XCTFail("wrong resource type")
							return
						}

						XCTAssertEqual(resource.locator.paths, ["version", "v1", "dcc-rl", "\(self.boosterCertificateKeyIdentifier)0b"])
					}
				),
				// Update KID-Type chunk for booster certificate, booster certificate is not revoked for hash type 0b
				LoadResource(
					result: .success(try self.revocationChunk()),
					willLoadResource: { resource in
						guard let resource = resource as? KIDTypeChunkResource else {
							XCTFail("wrong resource type, KIDTypeChunkResource expected")
							return
						}

						XCTAssertEqual(resource.locator.paths, ["version", "v1", "dcc-rl", "\(self.boosterCertificateKeyIdentifier)0b", "70", "12", "chunk"])
					}
				),
				// Update of KID-Type index for booster certificate key identifier, hash type 0c
				LoadResource(
					result: .success(try self.kidTypeIndex()),
					willLoadResource: { resource in
						guard let resource = resource as? KIDTypeIndexResource else {
							XCTFail("wrong resource type")
							return
						}

						XCTAssertEqual(resource.locator.paths, ["version", "v1", "dcc-rl", "\(self.boosterCertificateKeyIdentifier)0c"])
					}
				),
				// Update KID-Type chunk for booster certificate, booster certificate is revoked for hash type 0c
				LoadResource(
					result: .success(try self.revocationChunk()),
					willLoadResource: { resource in
						guard let resource = resource as? KIDTypeChunkResource else {
							XCTFail("wrong resource type, KIDTypeChunkResource expected")
							return
						}

						XCTAssertEqual(resource.locator.paths, ["version", "v1", "dcc-rl", "\(self.boosterCertificateKeyIdentifier)0c", "25", "89", "chunk"])
					}
				)
			]
		)

		let revocationProvider = RevocationProvider(restService: restService, store: MockTestStore(), signatureVerifier: MockVerifier())

		let expectation = expectation(description: "success expectation")

		revocationProvider.updateCache(with: certificates) { result in
			guard case .success(let revokedCertificates) = result else {
				XCTFail("Expected result")
				return
			}

			XCTAssertEqual(revokedCertificates.count, 2)
			XCTAssertTrue(revokedCertificates.contains(self.certificates[3]))
			XCTAssertTrue(revokedCertificates.contains(self.certificates[4]))

			expectation.fulfill()
		}

		waitForExpectations(timeout: .greatestFiniteMagnitude)
	}

	func testIsRevokedFromRevocationList() throws {
		let revokedVaccinationCertificate = try vaccinationCertificate()
		let revokedRecoveryCertificate = try recoveryCertificate()
		let unrevokedCertificate = try testCertificate()

		let store = MockTestStore()
		store.revokedCertificates = [revokedVaccinationCertificate.base45, revokedRecoveryCertificate.base45]

		let revocationProvider = RevocationProvider(
			restService: RestServiceProviderStub(),
			store: store,
			signatureVerifier: MockVerifier()
		)

		XCTAssertTrue(revocationProvider.isRevokedFromRevocationList(healthCertificate: revokedVaccinationCertificate))
		XCTAssertTrue(revocationProvider.isRevokedFromRevocationList(healthCertificate: revokedRecoveryCertificate))
		XCTAssertFalse(revocationProvider.isRevokedFromRevocationList(healthCertificate: unrevokedCertificate))
	}

	// MARK: - Helpers

	private let testCertificateKeyIdentifier = "0123456789abcdef"
	private let recoveryCertificateKeyIdentifier = "f5c5970c3039d854"
	private let boosterCertificateKeyIdentifier = "abcdef0123456789"

	private lazy var certificates: [HealthCertificate] = {
		[
			try? vaccinationCertificate(
				doseNumber: 1,
				totalSeriesOfDoses: 2,
				keyIdentifier: "8c4ae0ed458b67f1".dataWithHexString(),
				signature: "8c4ae0ed458b67f1".dataWithHexString()
			),
			try? vaccinationCertificate(
				doseNumber: 2,
				totalSeriesOfDoses: 2,
				keyIdentifier: "f50159a32d84e89d".dataWithHexString(),
				signature: "f50159a32d84e89d".dataWithHexString()
			),
			try? testCertificate(
				keyIdentifier: testCertificateKeyIdentifier.dataWithHexString(),
				signature: testCertificateKeyIdentifier.dataWithHexString()
			),
			try? recoveryCertificate(
				keyIdentifier: recoveryCertificateKeyIdentifier.dataWithHexString(),
				signature: recoveryCertificateKeyIdentifier.dataWithHexString()
			),
			try? vaccinationCertificate(
				doseNumber: 3,
				totalSeriesOfDoses: 3,
				keyIdentifier: boosterCertificateKeyIdentifier.dataWithHexString(),
				signature: boosterCertificateKeyIdentifier.dataWithHexString()
			)
		].compactMap { $0 }
	}()

	private var revocationKidList: SAP_Internal_Dgc_RevocationKidList {
		// recoveryCertificate
		var item1 = SAP_Internal_Dgc_RevocationKidListItem()
		item1.kid = recoveryCertificateKeyIdentifier.dataWithHexString()
		item1.hashTypes = ["0b".dataWithHexString(), "0a".dataWithHexString()]

		// dummy
		var item2 = SAP_Internal_Dgc_RevocationKidListItem()
		item2.kid = "fedcba9876543210".dataWithHexString()
		item2.hashTypes = ["0c".dataWithHexString()]

		// testCertificate
		var item3 = SAP_Internal_Dgc_RevocationKidListItem()
		item3.kid = testCertificateKeyIdentifier.dataWithHexString()
		item3.hashTypes = ["0a".dataWithHexString(), "0c".dataWithHexString()]

		// boosterCertificate
		var item4 = SAP_Internal_Dgc_RevocationKidListItem()
		item4.kid = boosterCertificateKeyIdentifier.dataWithHexString()
		item4.hashTypes = ["0b".dataWithHexString(), "0c".dataWithHexString()]

		var kidList = SAP_Internal_Dgc_RevocationKidList()
		kidList.items = [item1, item2, item3, item4].shuffled()
		return kidList
	}

	private func kidTypeIndex() throws -> SAP_Internal_Dgc_RevocationKidTypeIndex {
		let recoveryCoordinate0b = try coordinate(for: certificates[3], hashType: "0b")
		var item0 = SAP_Internal_Dgc_RevocationKidTypeIndexItem()
		item0.x = recoveryCoordinate0b.x.dataWithHexString()
		item0.y = [recoveryCoordinate0b.y.dataWithHexString(), "ad".dataWithHexString()]

		let recoveryCoordinate0a = try coordinate(for: certificates[3], hashType: "0a")
		var item1 = SAP_Internal_Dgc_RevocationKidTypeIndexItem()
		item1.x = recoveryCoordinate0a.x.dataWithHexString()
		item1.y = [recoveryCoordinate0a.y.dataWithHexString(), "ad".dataWithHexString()]

		let testCertificateCoordinate = try coordinate(for: certificates[2], hashType: "0a")
		var item2 = SAP_Internal_Dgc_RevocationKidTypeIndexItem()
		item2.x = testCertificateCoordinate.x.dataWithHexString()
		item2.y = [testCertificateCoordinate.y.dataWithHexString()]

		let vaccinationCoordinate = try coordinate(for: certificates[0], hashType: "0a")
		var item3 = SAP_Internal_Dgc_RevocationKidTypeIndexItem()
		item3.x = vaccinationCoordinate.x.dataWithHexString()
		item3.y = [vaccinationCoordinate.y.dataWithHexString()]

		var item4 = SAP_Internal_Dgc_RevocationKidTypeIndexItem()
		item4.x = "11".dataWithHexString()
		item4.y = ["12".dataWithHexString()]

		let boosterCoordinate0b = try coordinate(for: certificates[4], hashType: "0b")
		var item5 = SAP_Internal_Dgc_RevocationKidTypeIndexItem()
		item5.x = boosterCoordinate0b.x.dataWithHexString()
		item5.y = [boosterCoordinate0b.y.dataWithHexString()]

		let boosterCoordinate0c = try coordinate(for: certificates[4], hashType: "0c")
		var item6 = SAP_Internal_Dgc_RevocationKidTypeIndexItem()
		item6.x = boosterCoordinate0c.x.dataWithHexString()
		item6.y = [boosterCoordinate0c.y.dataWithHexString()]

		var kidTypeIndex = SAP_Internal_Dgc_RevocationKidTypeIndex()
		kidTypeIndex.items = [
			item0,
			item1,
			item2,
			item3,
			item4,
			item5,
			item6
		].shuffled()
		return kidTypeIndex
	}

	private func coordinate(for certificate: HealthCertificate, hashType: String) throws -> RevocationCoordinate {
		let recoveryHash = try XCTUnwrap(certificate.hash(by: hashType))
		return RevocationCoordinate(hash: recoveryHash)
	}

	private func revocationChunk() throws -> SAP_Internal_Dgc_RevocationChunk {
		let recoveryHash0a = try XCTUnwrap(certificates[3].hash(by: "0a"))
		let recoveryHash0b = try XCTUnwrap(certificates[3].hash(by: "0b"))
		let boosterHash0c = try XCTUnwrap(certificates[4].hash(by: "0c"))
		let vaccinationHash = try XCTUnwrap(certificates[1].hash(by: "0a"))

		var revocationChunk = SAP_Internal_Dgc_RevocationChunk()
		revocationChunk.hashes = [
			recoveryHash0a.dataWithHexString(),
			recoveryHash0b.dataWithHexString(),
			vaccinationHash.dataWithHexString(),
			boosterHash0c.dataWithHexString()
		]

		return revocationChunk
	}

}
