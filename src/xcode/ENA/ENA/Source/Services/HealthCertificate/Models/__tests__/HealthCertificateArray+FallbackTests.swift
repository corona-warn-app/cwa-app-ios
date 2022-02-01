//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
@testable import ENA
import HealthCertificateToolkit

class HealthCertificateArrayFallbackTests: CWATestCase {

	func test_Fallback_To_MostRecentRecoveryCertificate() throws {
		let testRecoveryCertificate = try recoveryCertificate(ageInDays: 2)
		
		let certificates = [
			testRecoveryCertificate,
			try recoveryCertificate(ageInDays: 10),
			try testCertificate(coronaTestType: .pcr, ageInHours: 1)
		]
		
		XCTAssertNotNil(certificates.fallback)
		XCTAssertEqual(testRecoveryCertificate, certificates.fallback)
	}
	
	func test_Fallback_To_MostRecentVaccinationCertificate() throws {
		let testVaccinationCertificate = try vaccinationCertificate(type: .seriesCompletingOrBooster, ageInDays: 2)
		
		let certificates = [
			testVaccinationCertificate,
			try testCertificate(coronaTestType: .pcr, ageInHours: 1),
			try recoveryCertificate(ageInDays: 10)
		]
		
		XCTAssertNotNil(certificates.fallback)
		XCTAssertEqual(testVaccinationCertificate, certificates.fallback)
	}
	
	func test_Fallback_To_ExpiringSoonCertificate() throws {
		let testCertificate = try testCertificate(coronaTestType: .pcr, ageInHours: 1, validityState: .expiringSoon)

		let certificates = [
			testCertificate,
			try recoveryCertificate(ageInDays: 1, validityState: .invalid)
		]
		
		XCTAssertNotNil(certificates.fallback)
		XCTAssertEqual(testCertificate, certificates.fallback)
	}
	
	func test_Fallback_To_ValidCertificate() throws {
		let testCertificate = try testCertificate(coronaTestType: .pcr, ageInHours: 1, validityState: .valid)

		let certificates = [
			testCertificate,
			try recoveryCertificate(ageInDays: 1, validityState: .invalid)
		]
		
		XCTAssertNotNil(certificates.fallback)
		XCTAssertEqual(testCertificate, certificates.fallback)
	}
	
	func test_Fallback_To_FirstCertificate() throws {
		let testCertificate = try testCertificate(coronaTestType: .pcr, ageInHours: 1, validityState: .invalid)

		let certificates = [
			testCertificate,
			try self.testCertificate(coronaTestType: .pcr, ageInHours: 3, validityState: .invalid)
		]
		
		XCTAssertNotNil(certificates.fallback)
		XCTAssertEqual(testCertificate, certificates.fallback)
	}

}
