//
// 🦠 Corona-Warn-App
//

import XCTest
import HealthCertificateToolkit

@testable import ENA

class HealthCertificateExportCertificatesInfoViewModelTests: CWATestCase {
	
	var sut: HealthCertificateExportCertificatesInfoViewModel!

    override func setUpWithError() throws {
		let vaccinationValueSetsProvider = VaccinationValueSetsProvider(client: CachingHTTPClientMock(), store: MockTestStore())
		
		sut = HealthCertificateExportCertificatesInfoViewModel(healthCertifiedPersons: [], vaccinationValueSetsProvider: vaccinationValueSetsProvider)
    }

    override func tearDownWithError() throws {
        sut = nil
    }
	
	func testGIVEN_ViewModel_WHEN_getDynamicTableViewModel_THEN_CellsAndSectionsCountAreCorrent() {
		// WHEN
		let dynamicTableViewModel = sut.dynamicTableViewModel
		
		// THEN
		XCTAssertEqual(dynamicTableViewModel.numberOfSection, 1)
		XCTAssertEqual(dynamicTableViewModel.numberOfRows(section: 0), 4)
	}
	
	func testGIVEN_HidesCloseButton_THEN_ShouldBeFalse() {
		// GIVEN
		let hidesCloseButton = sut.hidesCloseButton
		
		// THEN
		XCTAssertFalse(hidesCloseButton)
	}
	
	func testGIVEN_TestCertificates_THEN_FilteredCertificateCountIsCorrect() throws {
		// GIVEN
		
		let healthCertifiedPerson1 = HealthCertifiedPerson(healthCertificates: [try testCertificate(coronaTestType: .pcr, ageInHours: 12), try testCertificate(coronaTestType: .antigen, ageInHours: 24), try testCertificate(coronaTestType: .pcr, ageInHours: 84)])
		let healthCertifiedPerson2 = HealthCertifiedPerson(healthCertificates: [try testCertificate(coronaTestType: .pcr, ageInHours: 36), try testCertificate(coronaTestType: .antigen, ageInHours: 96)])
		
		let filteredHealthCertificates = sut.filteredHealthCertificates(healthCertifiedPersons: [healthCertifiedPerson1, healthCertifiedPerson2])
		let oldCertificates = filteredHealthCertificates.filter { $0.type == .test && $0.ageInHours ?? 0 > 72 }
		
		// THEN
		XCTAssertEqual(filteredHealthCertificates.count, 3)
		XCTAssertEqual(oldCertificates, [])
	}
	
	func testGIVEN_HealthCertificate_THEN_FilteredCertificateCountIsCorrect() throws {
		// GIVEN
		let validCertificate = try HealthCertificate(
			base45: try base45Fake(digitalCovidCertificate: .fake(vaccinationEntries: [.fake()])),
			validityState: .valid
		)
		
		let invalidCertificate = try HealthCertificate(
			base45: try base45Fake(digitalCovidCertificate: .fake(vaccinationEntries: [.fake()])),
			validityState: .invalid
		)
		
		let expiredCertificate = try HealthCertificate(
			base45: try base45Fake(digitalCovidCertificate: .fake(vaccinationEntries: [.fake()])),
			validityState: .expired
		)
		
		let expiringSoonCertificate = try HealthCertificate(
			base45: try base45Fake(digitalCovidCertificate: .fake(vaccinationEntries: [.fake()])),
			validityState: .expiringSoon
		)
		
		let revokedCertificate = try HealthCertificate(
			base45: try base45Fake(digitalCovidCertificate: .fake(vaccinationEntries: [.fake()])),
			validityState: .revoked
		)
		
		let blockedCertificate = try HealthCertificate(
			base45: try base45Fake(digitalCovidCertificate: .fake(vaccinationEntries: [.fake()])),
			validityState: .blocked
		)
		
		let healthCertifiedPerson1 = HealthCertifiedPerson(healthCertificates: [validCertificate, invalidCertificate, expiredCertificate, expiringSoonCertificate, revokedCertificate, blockedCertificate])
		let healthCertifiedPerson2 = HealthCertifiedPerson(healthCertificates: [revokedCertificate, blockedCertificate])
		
		let filteredHealthCertificates = sut.filteredHealthCertificates(healthCertifiedPersons: [healthCertifiedPerson1, healthCertifiedPerson2])
		let revokedOrBlockedCertificates = filteredHealthCertificates.filter { $0.validityState == .blocked || $0.validityState == .revoked }
		
		// THEN
		XCTAssertEqual(filteredHealthCertificates.count, 4)
		XCTAssertEqual(revokedOrBlockedCertificates, [])
	}
	
	func testGIVEN_MixCertificates_THEN_FilteredCertificateCountIsCorrect() throws {
		// GIVEN
		
		let validVaccinationCertificate = try HealthCertificate(
			base45: try base45Fake(digitalCovidCertificate: .fake(vaccinationEntries: [.fake()])),
			validityState: .valid
		)
		let validRecoveryCertificate = try HealthCertificate(
			base45: try base45Fake(digitalCovidCertificate: .fake(recoveryEntries: [.fake()])),
			validityState: .valid
		)
		let revokedRecoveryCertificate = try HealthCertificate(
			base45: try base45Fake(digitalCovidCertificate: .fake(recoveryEntries: [.fake()])),
			validityState: .revoked
		)
		
		let healthCertifiedPerson1 = HealthCertifiedPerson(healthCertificates: [try testCertificate(coronaTestType: .pcr, ageInHours: 12), try testCertificate(coronaTestType: .antigen, ageInHours: 24), try testCertificate(coronaTestType: .pcr, ageInHours: 84)])

		let healthCertifiedPerson2 = HealthCertifiedPerson(healthCertificates: [validVaccinationCertificate, validRecoveryCertificate, revokedRecoveryCertificate])
		
		let filteredHealthCertificates = sut.filteredHealthCertificates(healthCertifiedPersons: [healthCertifiedPerson1, healthCertifiedPerson2])
		
		let oldCertificates = filteredHealthCertificates.filter { $0.type == .test && $0.ageInHours ?? 0 > 72 }
		let revokedOrBlockedCertificates = filteredHealthCertificates.filter { $0.validityState == .blocked || $0.validityState == .revoked }
		
		// THEN
		XCTAssertEqual(filteredHealthCertificates.count, 4)
		XCTAssertEqual(oldCertificates, [])
		XCTAssertEqual(revokedOrBlockedCertificates, [])
	}
}
