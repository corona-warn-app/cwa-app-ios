//
// 🦠 Corona-Warn-App
//

import XCTest
import HealthCertificateToolkit
@testable import ENA

class NotificationManagerTests: XCTestCase {
	
	func testGIVEN_HealthCertifiedPersonWithCertificate_WHEN_NotificationIsTriggered_THEN_ExtractionIsCorrect() throws {
		
		// GIVEN
		
		let (healthCertificateService, notificationManager) = createServices()
		let expectedName = Name.fake(standardizedFamilyName: "BRAUSE", standardizedGivenName: "PASCAL")
		
		let vaccinationCertificate1Base45 = try base45Fake(
			from: DigitalCovidCertificate.fake(
				name: expectedName,
				vaccinationEntries: [VaccinationEntry.fake(
					dateOfVaccination: "2021-09-03",
					uniqueCertificateIdentifier: "1"
				)]
			)
		)
		let expectedCertificate = try XCTUnwrap(HealthCertificate(base45: vaccinationCertificate1Base45))
		
		let vaccinationCertificate2Base45 = try base45Fake(
			from: DigitalCovidCertificate.fake(
				name: .fake(standardizedFamilyName: "TEUBER", standardizedGivenName: "KAI"),
				vaccinationEntries: [VaccinationEntry.fake(
					dateOfVaccination: "2021-09-06",
					uniqueCertificateIdentifier: "2"
				)]
			)
		)
		
		_ = healthCertificateService.registerHealthCertificate(base45: vaccinationCertificate1Base45)
		_ = healthCertificateService.registerHealthCertificate(base45: vaccinationCertificate2Base45)
		
		// WHEN
		
		let (healthCertifiedPerson, healthCertificate) = try XCTUnwrap( notificationManager.extract("ABC", from: "ABC1"))
		
		// THEN
		
		XCTAssertEqual(expectedCertificate.uniqueCertificateIdentifier, healthCertificate.uniqueCertificateIdentifier)
		XCTAssertEqual(expectedName, healthCertifiedPerson.name)
	}
	
	func testGIVEN_HealthCertifiedPersonWithCertificate_WHEN_NotificationIsTriggeredInDifferentOrder_THEN_ExtractionIsCorrect() throws {
		
		// GIVEN
		
		let (healthCertificateService, notificationManager) = createServices()
		
		let vaccinationCertificate1Base45 = try base45Fake(
			from: DigitalCovidCertificate.fake(
				name: .fake(standardizedFamilyName: "BRAUSE", standardizedGivenName: "PASCAL"),
				vaccinationEntries: [VaccinationEntry.fake(
					dateOfVaccination: "2021-09-03",
					uniqueCertificateIdentifier: "1"
				)]
			)
		)
		
		let expectedName = Name.fake(standardizedFamilyName: "TEUBER", standardizedGivenName: "KAI")
		
		let vaccinationCertificate2Base45 = try base45Fake(
			from: DigitalCovidCertificate.fake(
				name: expectedName,
				vaccinationEntries: [VaccinationEntry.fake(
					dateOfVaccination: "2021-09-06",
					uniqueCertificateIdentifier: "2"
				)]
			)
		)
		
		let expectedCertificate = try XCTUnwrap(HealthCertificate(base45: vaccinationCertificate2Base45))
		
		_ = healthCertificateService.registerHealthCertificate(base45: vaccinationCertificate2Base45)
		_ = healthCertificateService.registerHealthCertificate(base45: vaccinationCertificate1Base45)
		
		// WHEN
		
		let (healthCertifiedPerson, healthCertificate) = try XCTUnwrap( notificationManager.extract("ABC", from: "ABC2"))
		
		// THEN
		
		XCTAssertEqual(expectedCertificate.uniqueCertificateIdentifier, healthCertificate.uniqueCertificateIdentifier)
		XCTAssertEqual(expectedName, healthCertifiedPerson.name)
	}
	
	func testGIVEN_HealthCertifiedPerson_WHEN_BoosterNotificationIsTriggered_THEN_ExtractionIsCorrect() throws {
		
		// GIVEN
		
		let (healthCertificateService, notificationManager) = createServices()
		
		let vaccinationCertificate1Base45 = try base45Fake(
			from: DigitalCovidCertificate.fake(
				name: .fake(standardizedFamilyName: "BRAUSE", standardizedGivenName: "PASCAL"),
				vaccinationEntries: [VaccinationEntry.fake(
					dateOfVaccination: "2021-09-03",
					uniqueCertificateIdentifier: "1"
				)]
			)
		)
		
		let expectedName = Name.fake(standardizedFamilyName: "TEUBER", standardizedGivenName: "KAI")
		
		let vaccinationCertificate2Base45 = try base45Fake(
			from: DigitalCovidCertificate.fake(
				name: expectedName,
				vaccinationEntries: [VaccinationEntry.fake(
					dateOfVaccination: "2021-09-06",
					uniqueCertificateIdentifier: "2"
				)]
			)
		)
		let expectedCertificate = try XCTUnwrap(HealthCertificate(base45: vaccinationCertificate2Base45))
		let healthCertifiedPerson = HealthCertifiedPerson(healthCertificates: [expectedCertificate])
		
		_ = healthCertificateService.registerHealthCertificate(base45: vaccinationCertificate2Base45)
		_ = healthCertificateService.registerHealthCertificate(base45: vaccinationCertificate1Base45)
		
		// WHEN
		guard let name = healthCertifiedPerson.name?.groupingStandardizedName,
			  let dateOfBirth = healthCertifiedPerson.dateOfBirth
		else {
			XCTFail("Person name and dob cant be nil")
			return
		}
			let notificationRawValue = LocalNotificationIdentifier.boosterVaccination.rawValue
			let hashedID = ENAHasher.sha256(name + dateOfBirth)
			let id = notificationRawValue + hashedID
		let extractedHealthCertifiedPerson = try XCTUnwrap(notificationManager.extractPerson(notificationRawValue, from: id))
		
		// THEN
		
		XCTAssertEqual(extractedHealthCertifiedPerson.name?.standardizedName, healthCertifiedPerson.name?.standardizedName)
		XCTAssertEqual(extractedHealthCertifiedPerson.dateOfBirth, healthCertifiedPerson.dateOfBirth)
	}
	
	private func createServices() -> (HealthCertificateService, NotificationManager) {
		
		let notificationService = MockUserNotificationCenter()
				
		let store = MockTestStore()
		let client = ClientMock()
		let cachedAppConfig = CachedAppConfigurationMock(with: SAP_Internal_V2_ApplicationConfigurationIOS())
		let diaryStore = MockDiaryStore()
		let eventStore = MockEventStore()
		let healthCertificateService = HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			client: client,
			appConfiguration: cachedAppConfig,
			cclService: FakeCCLService(),
			recycleBin: .fake()
		)
		
		let coronaTestService = MockCoronaTestService()
		
		let eventCheckoutService = EventCheckoutService(
			eventStore: eventStore,
			contactDiaryStore: diaryStore,
			userNotificationCenter: notificationService
		)
		
		let notificationManager = NotificationManager(
			coronaTestService: coronaTestService,
			eventCheckoutService: eventCheckoutService,
			healthCertificateService: healthCertificateService,
			showHome: {},
			showTestResultFromNotification: { _ in },
			showHealthCertificate: { _ in },
			showHealthCertifiedPerson: { _ in }
		)
		
		return (healthCertificateService, notificationManager)
	}
}
