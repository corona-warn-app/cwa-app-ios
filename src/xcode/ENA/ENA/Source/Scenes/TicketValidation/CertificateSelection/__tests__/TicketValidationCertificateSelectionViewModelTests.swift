//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class TicketValidationCertificateSelectionViewModelTests: XCTestCase {

	func testGIVEN_Certificates_WHEN_CertificateSelectionModelIsCreatedWithTwoTypes_THEN_ModelIsSetupCorrectly() throws {
		let vaccinationCertificate = try HealthCertificate(
			base45: try base45Fake(from: .fake(name: .fake(familyName: "Schneider", givenName: "Andrea", standardizedFamilyName: "SCHNEIDER", standardizedGivenName: "ANDREA"), vaccinationEntries: [.fake()]))
		)

		let recoveryCertificate = try HealthCertificate(
			base45: try base45Fake(from: .fake(name: .fake(familyName: "Schneider", givenName: "Andrea", standardizedFamilyName: "SCHNEIDER", standardizedGivenName: "ANDREA"), recoveryEntries: [.fake()]))
		)
		
		let testCertificate = try HealthCertificate(
			base45: try base45Fake(from: .fake(name: .fake(familyName: "Schneider", givenName: "Andrea", standardizedFamilyName: "SCHNEIDER", standardizedGivenName: "ANDREA"), testEntries: [.fake()]))
		)
		
		let certifiedPerson = HealthCertifiedPerson(healthCertificates: [vaccinationCertificate, recoveryCertificate, testCertificate])
		
		let model = TicketValidationCertificateSelectionViewModel(
			validationConditions: ValidationConditions.fake(fnt: "SCHNEIDER", gnt: "ANDREA", dob: "1989-12-12", type: ["v", "r"]),
			healthCertifiedPersons: [certifiedPerson],
			onHealthCertificateCellTap: { _, _ in }
		)

		XCTAssertFalse(model.isSupportedCertificatesEmpty)
		XCTAssertEqual(model.dynamicTableViewModel.numberOfRows(section: 0), 5) // 3 Text fields + 2 Certificates
	}
	
	func testGIVEN_Certificates_WHEN_CertificateSelectionModelIsCreatedWithOneType_THEN_ModelIsSetupCorrectly() throws {
		let vaccinationCertificate = try HealthCertificate(
			base45: try base45Fake(from: .fake(name: .fake(familyName: "Schneider", givenName: "Andrea", standardizedFamilyName: "SCHNEIDER", standardizedGivenName: "ANDREA"), vaccinationEntries: [.fake()]))
		)

		let recoveryCertificate = try HealthCertificate(
			base45: try base45Fake(from: .fake(name: .fake(familyName: "Schneider", givenName: "Andrea", standardizedFamilyName: "SCHNEIDER", standardizedGivenName: "ANDREA"), recoveryEntries: [.fake()]))
		)
		
		let testCertificate = try HealthCertificate(
			base45: try base45Fake(from: .fake(name: .fake(familyName: "Schneider", givenName: "Andrea", standardizedFamilyName: "SCHNEIDER", standardizedGivenName: "ANDREA"), testEntries: [.fake()]))
		)
		
		let certifiedPerson = HealthCertifiedPerson(healthCertificates: [vaccinationCertificate, recoveryCertificate, testCertificate])
		
		let model = TicketValidationCertificateSelectionViewModel(
			validationConditions: ValidationConditions.fake(fnt: "SCHNEIDER", gnt: "ANDREA", dob: "1989-12-12", type: ["v"]),
			healthCertifiedPersons: [certifiedPerson],
			onHealthCertificateCellTap: { _, _ in }
		)

		XCTAssertFalse(model.isSupportedCertificatesEmpty)
		XCTAssertEqual(model.dynamicTableViewModel.numberOfRows(section: 0), 4) // 3 Text fields + 1 Certificate
	}

	func testGIVEN_Certificates_WHEN_CertificateSelectionModelIsCreatedWithNoType_THEN_ModelIsSetupCorrectly() throws {
		let vaccinationCertificate = try HealthCertificate(
			base45: try base45Fake(from: .fake(name: .fake(familyName: "Schneider", givenName: "Andrea", standardizedFamilyName: "SCHNEIDER", standardizedGivenName: "ANDREA"), vaccinationEntries: [.fake()]))
		)

		let recoveryCertificate = try HealthCertificate(
			base45: try base45Fake(from: .fake(name: .fake(familyName: "Schneider", givenName: "Andrea", standardizedFamilyName: "SCHNEIDER", standardizedGivenName: "ANDREA"), recoveryEntries: [.fake()]))
		)
		
		let testCertificate = try HealthCertificate(
			base45: try base45Fake(from: .fake(name: .fake(familyName: "Schneider", givenName: "Andrea", standardizedFamilyName: "SCHNEIDER", standardizedGivenName: "ANDREA"), testEntries: [.fake()]))
		)
		
		let certifiedPerson = HealthCertifiedPerson(healthCertificates: [vaccinationCertificate, recoveryCertificate, testCertificate])
		
		let model = TicketValidationCertificateSelectionViewModel(
			validationConditions: ValidationConditions.fake(fnt: "SCHNEIDER", gnt: "ANDREA", dob: "1989-12-12", type: []),
			healthCertifiedPersons: [certifiedPerson],
			onHealthCertificateCellTap: { _, _ in }
		)

		XCTAssertFalse(model.isSupportedCertificatesEmpty)
		XCTAssertEqual(model.dynamicTableViewModel.numberOfRows(section: 0), 5) // 3 Text fields + 3 Certificates
	}
	
	func testGIVEN_Certificates_WHEN_CertificateSelectionModelIsCreatedWithDifferentPerson_THEN_ModelIsSetupCorrectly() throws {
		let vaccinationCertificate = try HealthCertificate(
			base45: try base45Fake(from: .fake(name: .fake(familyName: "Schneider", givenName: "Andrea", standardizedFamilyName: "SCHNEIDER", standardizedGivenName: "ANDREA"), vaccinationEntries: [.fake()]))
		)

		let recoveryCertificate = try HealthCertificate(
			base45: try base45Fake(from: .fake(name: .fake(familyName: "Schneider", givenName: "Andrea", standardizedFamilyName: "SCHNEIDER", standardizedGivenName: "ANDREA"), recoveryEntries: [.fake()]))
		)
		
		let testCertificate = try HealthCertificate(
			base45: try base45Fake(from: .fake(name: .fake(familyName: "Schneider", givenName: "Andrea", standardizedFamilyName: "SCHNEIDER", standardizedGivenName: "ANDREA"), testEntries: [.fake()]))
		)
		
		let certifiedPerson = HealthCertifiedPerson(healthCertificates: [vaccinationCertificate, recoveryCertificate, testCertificate])
		
		let model = TicketValidationCertificateSelectionViewModel(
			validationConditions: ValidationConditions.fake(fnt: "SCHNEIDER", gnt: "PIA", dob: "1989-12-12", type: ["v", "r", "t"]),
			healthCertifiedPersons: [certifiedPerson],
			onHealthCertificateCellTap: { _, _ in }
		)

		XCTAssertTrue(model.isSupportedCertificatesEmpty)
		XCTAssertEqual(model.dynamicTableViewModel.numberOfRows(section: 0), 5) // 5 Text Fields + 0 Certificate
	}
}
