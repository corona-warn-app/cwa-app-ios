//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
import HealthCertificateToolkit
@testable import ENA

class HealthCertificateValidatorTests: XCTestCase {
	
	func test_emptyRevocationChunk() {
		let restServiceStub = RestServiceProviderStub(
			cachedResults: [
				.success(SAP_Internal_Dgc_RevocationChunk())
			]
		)
		let validator = HealthCertificateValidator(restServiceProvider: restServiceStub)
		let isRevoked = validator.isRevokedFromRevocationList(healthCertificate: HealthCertificate.mock())
		
		XCTAssertFalse(isRevoked)
	}
	
	func test_signatureRevocationChunk() throws {
		var revocationChunk = SAP_Internal_Dgc_RevocationChunk()
		revocationChunk.hashes = [
			try XCTUnwrap("0000".dataWithHexString())
		]
		let restServiceStub = RestServiceProviderStub(
			cachedResults: [
				// Result for signature
				.success(revocationChunk),
				// Result for uci
				.success(revocationChunk),
				// Result for countryCodeUCI
				.success(revocationChunk)
			]
		)
		let validator = HealthCertificateValidator(restServiceProvider: restServiceStub)
		let isRevoked = validator.isRevokedFromRevocationList(
			healthCertificate: HealthCertificate.mock(
				revocationEntries: HealthCertificateRevocationEntries(
					uci: "1111",
					countryCodeUCI: "1111",
					signature: "0000"
				)
			)
		)
		
		XCTAssertTrue(isRevoked)
	}
	
	func test_uciRevocationChunk() throws {
		var revocationChunk = SAP_Internal_Dgc_RevocationChunk()
		revocationChunk.hashes = [
			try XCTUnwrap("0000".dataWithHexString())
		]
		let restServiceStub = RestServiceProviderStub(
			cachedResults: [
				// Result for signature
				.success(revocationChunk),
				// Result for uci
				.success(revocationChunk),
				// Result for countryCodeUCI
				.success(revocationChunk)
			]
		)
		let validator = HealthCertificateValidator(restServiceProvider: restServiceStub)
		let isRevoked = validator.isRevokedFromRevocationList(
			healthCertificate: HealthCertificate.mock(
				revocationEntries: HealthCertificateRevocationEntries(
					uci: "0000",
					countryCodeUCI: "1111",
					signature: "1111"
				)
			)
		)
		
		XCTAssertTrue(isRevoked)
	}
	
	func test_countryCodeUCIRevocationChunk() throws {
		var revocationChunk = SAP_Internal_Dgc_RevocationChunk()
		revocationChunk.hashes = [
			try XCTUnwrap("0000".dataWithHexString())
		]
		let restServiceStub = RestServiceProviderStub(
			cachedResults: [
				// Result for signature
				.success(revocationChunk),
				// Result for uci
				.success(revocationChunk),
				// Result for countryCodeUCI
				.success(revocationChunk)
			]
		)
		let validator = HealthCertificateValidator(restServiceProvider: restServiceStub)
		let isRevoked = validator.isRevokedFromRevocationList(
			healthCertificate: HealthCertificate.mock(
				revocationEntries: HealthCertificateRevocationEntries(
					uci: "1111",
					countryCodeUCI: "0000",
					signature: "1111"
				)
			)
		)
		
		XCTAssertTrue(isRevoked)
	}
	
	func test_AllMatchinhRevocationChunks() throws {
		var revocationChunk = SAP_Internal_Dgc_RevocationChunk()
		revocationChunk.hashes = [
			try XCTUnwrap("0000".dataWithHexString())
		]
		let restServiceStub = RestServiceProviderStub(
			cachedResults: [
				// Result for signature
				.success(revocationChunk),
				// Result for uci
				.success(revocationChunk),
				// Result for countryCodeUCI
				.success(revocationChunk)
			]
		)
		let validator = HealthCertificateValidator(restServiceProvider: restServiceStub)
		let isRevoked = validator.isRevokedFromRevocationList(
			healthCertificate: HealthCertificate.mock(
				revocationEntries: HealthCertificateRevocationEntries(
					uci: "0000",
					countryCodeUCI: "0000",
					signature: "0000"
				)
			)
		)
		
		XCTAssertTrue(isRevoked)
	}
	
	func test_AllNotMatchingRevocationChunks() throws {
		var revocationChunk = SAP_Internal_Dgc_RevocationChunk()
		revocationChunk.hashes = [
			try XCTUnwrap("0000".dataWithHexString())
		]
		let restServiceStub = RestServiceProviderStub(
			cachedResults: [
				// Result for signature
				.success(revocationChunk),
				// Result for uci
				.success(revocationChunk),
				// Result for countryCodeUCI
				.success(revocationChunk)
			]
		)
		let validator = HealthCertificateValidator(restServiceProvider: restServiceStub)
		let isRevoked = validator.isRevokedFromRevocationList(
			healthCertificate: HealthCertificate.mock(
				revocationEntries: HealthCertificateRevocationEntries(
					uci: "1111",
					countryCodeUCI: "1111",
					signature: "1111"
				)
			)
		)
		
		XCTAssertFalse(isRevoked)
	}
}
