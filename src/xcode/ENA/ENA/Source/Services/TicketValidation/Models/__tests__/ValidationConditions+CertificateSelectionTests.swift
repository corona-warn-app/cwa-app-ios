//
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA
@testable import HealthCertificateToolkit

class TicketValidationConditionsCertificateSelectionTests: XCTestCase {

	func testGIVEN_Certificates_WHEN_FilterCertificateMethodIsCalledWithTwoTypes_THEN_ResultIsCorrect() throws {
		let validationConditions = TicketValidationConditions.fake(fnt: "SCHNEIDER", gnt: "ANDREA", dob: "1989-12-12", type: ["v", "r"])
		
		let vaccinationCertificate = try HealthCertificate(
			base45: try base45Fake(digitalCovidCertificate: .fake(name: .fake(familyName: "Schneider", givenName: "Andrea", standardizedFamilyName: "SCHNEIDER", standardizedGivenName: "ANDREA"), vaccinationEntries: [.fake()]))
		)

		let recoveryCertificate = try HealthCertificate(
			base45: try base45Fake(digitalCovidCertificate: .fake(name: .fake(familyName: "Schneider", givenName: "Andrea", standardizedFamilyName: "SCHNEIDER", standardizedGivenName: "ANDREA"), recoveryEntries: [.fake()]))
		)
		
		let testCertificate = try HealthCertificate(
			base45: try base45Fake(digitalCovidCertificate: .fake(name: .fake(familyName: "Schneider", givenName: "Andrea", standardizedFamilyName: "SCHNEIDER", standardizedGivenName: "ANDREA"), testEntries: [.fake()]))
		)
		
		let certifiedPerson = HealthCertifiedPerson(healthCertificates: [vaccinationCertificate, recoveryCertificate, testCertificate])
		
		let supportedCertificatesTuple = validationConditions.filterCertificates(healthCertifiedPersons: [certifiedPerson])
		
		XCTAssertEqual(supportedCertificatesTuple.supportedHealthCertificates, [vaccinationCertificate, recoveryCertificate])
		XCTAssertEqual(supportedCertificatesTuple.supportedCertificateTypes, [AppStrings.TicketValidation.SupportedCertificateType.vaccinationCertificate, AppStrings.TicketValidation.SupportedCertificateType.recoveryCertificate])
	}
	
	func testGIVEN_Certificates_WHEN_FilterCertificateMethodIsCalledWithOneType_THEN_ResultIsCorrect() throws {
		let validationConditions = TicketValidationConditions.fake(fnt: "SCHNEIDER", gnt: "ANDREA", dob: "1989-12-12", type: ["t"])
		
		let vaccinationCertificate = try HealthCertificate(
			base45: try base45Fake(digitalCovidCertificate: .fake(name: .fake(familyName: "Schneider", givenName: "Andrea", standardizedFamilyName: "SCHNEIDER", standardizedGivenName: "ANDREA"), vaccinationEntries: [.fake()]))
		)

		let recoveryCertificate = try HealthCertificate(
			base45: try base45Fake(digitalCovidCertificate: .fake(name: .fake(familyName: "Schneider", givenName: "Andrea", standardizedFamilyName: "SCHNEIDER", standardizedGivenName: "ANDREA"), recoveryEntries: [.fake()]))
		)
		
		let testCertificate = try HealthCertificate(
			base45: try base45Fake(digitalCovidCertificate: .fake(name: .fake(familyName: "Schneider", givenName: "Andrea", standardizedFamilyName: "SCHNEIDER", standardizedGivenName: "ANDREA"), testEntries: [.fake()]))
		)
		
		let certifiedPerson = HealthCertifiedPerson(healthCertificates: [vaccinationCertificate, recoveryCertificate, testCertificate])
		
		let supportedCertificatesTuple = validationConditions.filterCertificates(healthCertifiedPersons: [certifiedPerson])
		
		XCTAssertEqual(supportedCertificatesTuple.supportedHealthCertificates, [testCertificate])
		XCTAssertEqual(supportedCertificatesTuple.supportedCertificateTypes, [AppStrings.TicketValidation.SupportedCertificateType.testCertificate])
	}
	
	func testGIVEN_Certificates_WHEN_FilterCertificateMethodIsCalledWithOneTypeRAT_THEN_ResultIsCorrect() throws {
		let validationConditions = TicketValidationConditions.fake(fnt: "SCHNEIDER", gnt: "ANDREA", dob: "1989-12-12", type: ["tr"])
		
		let vaccinationCertificate = try HealthCertificate(
			base45: try base45Fake(digitalCovidCertificate: .fake(name: .fake(familyName: "Schneider", givenName: "Andrea", standardizedFamilyName: "SCHNEIDER", standardizedGivenName: "ANDREA"), vaccinationEntries: [.fake()]))
		)

		let recoveryCertificate = try HealthCertificate(
			base45: try base45Fake(digitalCovidCertificate: .fake(name: .fake(familyName: "Schneider", givenName: "Andrea", standardizedFamilyName: "SCHNEIDER", standardizedGivenName: "ANDREA"), recoveryEntries: [.fake()]))
		)
		
		let antigenTestCertificate = try HealthCertificate(
			base45: try base45Fake(digitalCovidCertificate: .fake(name: .fake(familyName: "Schneider", givenName: "Andrea", standardizedFamilyName: "SCHNEIDER", standardizedGivenName: "ANDREA"), testEntries: [.fake(typeOfTest: TestEntry.antigenTypeString)]))
		)
		
		let certifiedPerson = HealthCertifiedPerson(healthCertificates: [vaccinationCertificate, recoveryCertificate, antigenTestCertificate])
		
		let supportedCertificatesTuple = validationConditions.filterCertificates(healthCertifiedPersons: [certifiedPerson])
		
		XCTAssertEqual(supportedCertificatesTuple.supportedHealthCertificates, [antigenTestCertificate])
		XCTAssertEqual(supportedCertificatesTuple.supportedCertificateTypes, [AppStrings.TicketValidation.SupportedCertificateType.ratTestCertificate])
	}
	
	func testGIVEN_Certificates_WHEN_FilterCertificateMethodIsCalledWithOneTypePCR_THEN_ResultIsCorrect() throws {
		let validationConditions = TicketValidationConditions.fake(fnt: "SCHNEIDER", gnt: "ANDREA", dob: "1989-12-12", type: ["tp"])
		
		let vaccinationCertificate = try HealthCertificate(
			base45: try base45Fake(digitalCovidCertificate: .fake(name: .fake(familyName: "Schneider", givenName: "Andrea", standardizedFamilyName: "SCHNEIDER", standardizedGivenName: "ANDREA"), vaccinationEntries: [.fake()]))
		)

		let recoveryCertificate = try HealthCertificate(
			base45: try base45Fake(digitalCovidCertificate: .fake(name: .fake(familyName: "Schneider", givenName: "Andrea", standardizedFamilyName: "SCHNEIDER", standardizedGivenName: "ANDREA"), recoveryEntries: [.fake()]))
		)
		
		let pcrTestCertificate = try HealthCertificate(
			base45: try base45Fake(digitalCovidCertificate: .fake(name: .fake(familyName: "Schneider", givenName: "Andrea", standardizedFamilyName: "SCHNEIDER", standardizedGivenName: "ANDREA"), testEntries: [.fake(typeOfTest: TestEntry.pcrTypeString)]))
		)
		
		let certifiedPerson = HealthCertifiedPerson(healthCertificates: [vaccinationCertificate, recoveryCertificate, pcrTestCertificate])
		
		let supportedCertificatesTuple = validationConditions.filterCertificates(healthCertifiedPersons: [certifiedPerson])
		
		XCTAssertEqual(supportedCertificatesTuple.supportedHealthCertificates, [pcrTestCertificate])
		XCTAssertEqual(supportedCertificatesTuple.supportedCertificateTypes, [AppStrings.TicketValidation.SupportedCertificateType.pcrTestCertificate])
	}
	
	func testGIVEN_Certificates_WHEN_FilterCertificateMethodIsCalledWithNoType_THEN_ResultIsCorrect() throws {
		let validationConditions = TicketValidationConditions.fake(fnt: "SCHNEIDER", gnt: "ANDREA", dob: "1989-12-12", type: [])
		
		let vaccinationCertificate = try HealthCertificate(
			base45: try base45Fake(digitalCovidCertificate: .fake(name: .fake(familyName: "Schneider", givenName: "Andrea", standardizedFamilyName: "SCHNEIDER", standardizedGivenName: "ANDREA"), vaccinationEntries: [.fake()]))
		)

		let recoveryCertificate = try HealthCertificate(
			base45: try base45Fake(digitalCovidCertificate: .fake(name: .fake(familyName: "Schneider", givenName: "Andrea", standardizedFamilyName: "SCHNEIDER", standardizedGivenName: "ANDREA"), recoveryEntries: [.fake()]))
		)
		
		let testCertificate = try HealthCertificate(
			base45: try base45Fake(digitalCovidCertificate: .fake(name: .fake(familyName: "Schneider", givenName: "Andrea", standardizedFamilyName: "SCHNEIDER", standardizedGivenName: "ANDREA"), testEntries: [.fake()]))
		)
		
		let certifiedPerson = HealthCertifiedPerson(healthCertificates: [vaccinationCertificate, recoveryCertificate, testCertificate])
		
		let supportedCertificatesTuple = validationConditions.filterCertificates(healthCertifiedPersons: [certifiedPerson])
		
		XCTAssertEqual(supportedCertificatesTuple.supportedHealthCertificates, [vaccinationCertificate, testCertificate, recoveryCertificate])
		XCTAssertEqual(supportedCertificatesTuple.supportedCertificateTypes, [])
	}
	
	func testGIVEN_Certificates_WHEN_FilterCertificateMethodIsCalledWithDifferentPerson_THEN_ResultIsCorrect() throws {
		let validationConditions = TicketValidationConditions.fake(fnt: "SCHNEIDER", gnt: "THOMAS", dob: "1983-12-12", type: ["v", "r", "t"])
		
		let vaccinationCertificate = try HealthCertificate(
			base45: try base45Fake(digitalCovidCertificate: .fake(name: .fake(familyName: "Schneider", givenName: "Andrea", standardizedFamilyName: "SCHNEIDER", standardizedGivenName: "ANDREA"), vaccinationEntries: [.fake()]))
		)

		let recoveryCertificate = try HealthCertificate(
			base45: try base45Fake(digitalCovidCertificate: .fake(name: .fake(familyName: "Schneider", givenName: "Andrea", standardizedFamilyName: "SCHNEIDER", standardizedGivenName: "ANDREA"), recoveryEntries: [.fake()]))
		)
		
		let testCertificate = try HealthCertificate(
			base45: try base45Fake(digitalCovidCertificate: .fake(name: .fake(familyName: "Schneider", givenName: "Andrea", standardizedFamilyName: "SCHNEIDER", standardizedGivenName: "ANDREA"), testEntries: [.fake()]))
		)
		
		let certifiedPerson = HealthCertifiedPerson(healthCertificates: [vaccinationCertificate, recoveryCertificate, testCertificate])
		
		let supportedCertificatesTuple = validationConditions.filterCertificates(healthCertifiedPersons: [certifiedPerson])
		
		XCTAssertEqual(supportedCertificatesTuple.supportedHealthCertificates, [])
		XCTAssertEqual(supportedCertificatesTuple.supportedCertificateTypes, [AppStrings.TicketValidation.SupportedCertificateType.vaccinationCertificate, AppStrings.TicketValidation.SupportedCertificateType.recoveryCertificate, AppStrings.TicketValidation.SupportedCertificateType.testCertificate])
	}
	
	func testGIVEN_Certificates_WHEN_ServiceProviderRequirementsMethodIsCalledWithSupportedTypes_THEN_StringIsCorrect() throws {
		let validationConditions = TicketValidationConditions.fake(fnt: "SCHNEIDER", gnt: "ANDREA", dob: "1989-12-12", type: ["v", "r", "t"])
		
		let vaccinationCertificate = try HealthCertificate(
			base45: try base45Fake(digitalCovidCertificate: .fake(name: .fake(familyName: "Schneider", givenName: "Andrea", standardizedFamilyName: "SCHNEIDER", standardizedGivenName: "ANDREA"), vaccinationEntries: [.fake()]))
		)

		let recoveryCertificate = try HealthCertificate(
			base45: try base45Fake(digitalCovidCertificate: .fake(name: .fake(familyName: "Schneider", givenName: "Andrea", standardizedFamilyName: "SCHNEIDER", standardizedGivenName: "ANDREA"), recoveryEntries: [.fake()]))
		)
		
		let testCertificate = try HealthCertificate(
			base45: try base45Fake(digitalCovidCertificate: .fake(name: .fake(familyName: "Schneider", givenName: "Andrea", standardizedFamilyName: "SCHNEIDER", standardizedGivenName: "ANDREA"), testEntries: [.fake()]))
		)
		
		let certifiedPerson = HealthCertifiedPerson(healthCertificates: [vaccinationCertificate, recoveryCertificate, testCertificate])
		
		let supportedCertificatesTuple = validationConditions.filterCertificates(healthCertifiedPersons: [certifiedPerson])
		
		let serviceProviderRequirementsString = validationConditions.serviceProviderRequirementsString(supportedCertificateTypes: supportedCertificatesTuple.supportedCertificateTypes)

		XCTAssertEqual("Impfzertifikat, Genesenenzertifikat, Schnelltest-Testzertifikat, PCR-Testzertifikat\nGeburtsdatum: 1989-12-12\nSCHNEIDER<<ANDREA", serviceProviderRequirementsString)
	}
	
	func testGIVEN_Certificates_WHEN_ServiceProviderRequirementsMethodIsCalledWithSupportedTypesWithNoGivenName_THEN_StringIsCorrect() throws {
		let validationConditions = TicketValidationConditions.fake(fnt: "", gnt: "ANDREA", dob: "1989-12-12", type: ["v", "r", "t"])
		
		let vaccinationCertificate = try HealthCertificate(
			base45: try base45Fake(digitalCovidCertificate: .fake(name: .fake(familyName: "Schneider", givenName: "Andrea", standardizedFamilyName: "", standardizedGivenName: "ANDREA"), vaccinationEntries: [.fake()]))
		)

		let recoveryCertificate = try HealthCertificate(
			base45: try base45Fake(digitalCovidCertificate: .fake(name: .fake(familyName: "Schneider", givenName: "Andrea", standardizedFamilyName: "", standardizedGivenName: "ANDREA"), recoveryEntries: [.fake()]))
		)
		
		let testCertificate = try HealthCertificate(
			base45: try base45Fake(digitalCovidCertificate: .fake(name: .fake(familyName: "Schneider", givenName: "Andrea", standardizedFamilyName: "", standardizedGivenName: "ANDREA"), testEntries: [.fake()]))
		)
		
		let certifiedPerson = HealthCertifiedPerson(healthCertificates: [vaccinationCertificate, recoveryCertificate, testCertificate])
		
		let supportedCertificatesTuple = validationConditions.filterCertificates(healthCertifiedPersons: [certifiedPerson])
		
		let serviceProviderRequirementsString = validationConditions.serviceProviderRequirementsString(supportedCertificateTypes: supportedCertificatesTuple.supportedCertificateTypes)

		XCTAssertEqual("Impfzertifikat, Genesenenzertifikat, Schnelltest-Testzertifikat, PCR-Testzertifikat\nGeburtsdatum: 1989-12-12\n<<ANDREA", serviceProviderRequirementsString)
	}
	
	func testGIVEN_Certificates_WHEN_ServiceProviderRequirementsMethodIsCalledWithSupportedTypesWithNoFamilyName_THEN_StringIsCorrect() throws {
		let validationConditions = TicketValidationConditions.fake(fnt: "SCHNEIDER", gnt: "", dob: "1989-12-12", type: ["v", "r", "t"])
		
		let vaccinationCertificate = try HealthCertificate(
			base45: try base45Fake(digitalCovidCertificate: .fake(name: .fake(familyName: "Schneider", givenName: "Andrea", standardizedFamilyName: "SCHNEIDER", standardizedGivenName: ""), vaccinationEntries: [.fake()]))
		)

		let recoveryCertificate = try HealthCertificate(
			base45: try base45Fake(digitalCovidCertificate: .fake(name: .fake(familyName: "Schneider", givenName: "Andrea", standardizedFamilyName: "SCHNEIDER", standardizedGivenName: ""), recoveryEntries: [.fake()]))
		)
		
		let testCertificate = try HealthCertificate(
			base45: try base45Fake(digitalCovidCertificate: .fake(name: .fake(familyName: "Schneider", givenName: "Andrea", standardizedFamilyName: "SCHNEIDER", standardizedGivenName: ""), testEntries: [.fake()]))
		)
		
		let certifiedPerson = HealthCertifiedPerson(healthCertificates: [vaccinationCertificate, recoveryCertificate, testCertificate])
		
		let supportedCertificatesTuple = validationConditions.filterCertificates(healthCertifiedPersons: [certifiedPerson])
		
		let serviceProviderRequirementsString = validationConditions.serviceProviderRequirementsString(supportedCertificateTypes: supportedCertificatesTuple.supportedCertificateTypes)

		XCTAssertEqual("Impfzertifikat, Genesenenzertifikat, Schnelltest-Testzertifikat, PCR-Testzertifikat\nGeburtsdatum: 1989-12-12\nSCHNEIDER<<", serviceProviderRequirementsString)
	}
}
