////
//// 🦠 Corona-Warn-App
////
//
//import XCTest
//import HealthCertificateToolkit
//@testable import ENA
//
//class HealthCertificateServiceMigrationTests: XCTestCase {
//
//	func testGIVEN_4_Persons_WHEN_registerHealthCertificate_THEN_Grouped_to_2_Persons() throws {
//		// GIVEN
//		let store = MockTestStore()
//		let service = getService(store: store)
//
//		// WHEN
//		service.registerHealthCertificate(base45: try thomasCert01())
//		service.registerHealthCertificate(base45: try thomasCert02())
//		service.registerHealthCertificate(base45: try thomasCert03())
//		service.registerHealthCertificate(base45: try ulrikeCert01())
//		// THEN
//		XCTAssertEqual(service.healthCertifiedPersons.count, 2)
//	}
//
//	// with migration grouping will apply, preferred person state is transferred from second person
//	func testGIVEN_ServiceWithCertificatesInStore_SecondPersonIsPreferred_WHEN_ServiceWithMigration_THEN_OnePreferredHealthCertifiedPerson() throws {
//		// GIVEN
//		let cert01 = try HealthCertificate(base45: try cert01(), validityState: .expired, didShowInvalidNotification: true)
//		let cert02 = try HealthCertificate(base45: try cert02(), isNew: true)
//		let cert03 = try HealthCertificate(base45: try cert03(), isValidityStateNew: true)
//		let person01 = HealthCertifiedPerson(
//			healthCertificates: [cert01],
//			isPreferredPerson: false,
//			boosterRule: nil,
//			isNewBoosterRule: false
//		)
//		let person02 = HealthCertifiedPerson(
//			healthCertificates: [cert02, cert03],
//			isPreferredPerson: true,
//			boosterRule: .fake(),
//			isNewBoosterRule: true
//		)
//
//		let store = MockTestStore(healthCertifiedPersonsVersion: nil) // fake old version
//		store.healthCertifiedPersons = [person01, person02]
//
//		// WHEN
//		let service = getService(store: store)
//
//		// THEN
//		XCTAssertEqual(service.healthCertifiedPersons.count, 1)
//
//		let mergedPerson = try XCTUnwrap(service.healthCertifiedPersons.first)
//		XCTAssertEqual(mergedPerson.healthCertificates, [cert03, cert02, cert01])
//		XCTAssertTrue(mergedPerson.isPreferredPerson)
//		XCTAssertNil(mergedPerson.boosterRule)
//		XCTAssertFalse(mergedPerson.isNewBoosterRule)
//
//		// Check that certificate properties are properly migrated
//		XCTAssertEqual(mergedPerson.healthCertificates[2].validityState, .expired)
//		XCTAssertTrue(mergedPerson.healthCertificates[2].didShowInvalidNotification)
//		XCTAssertTrue(mergedPerson.healthCertificates[1].isNew)
//		XCTAssertTrue(mergedPerson.healthCertificates[0].isValidityStateNew)
//	}
//
//	// with migration grouping will apply, preferred person state is transferred from first person
//	func testGIVEN_ServiceWithCertificatesInStore_FirstPersonIsPreferred_WHEN_ServiceWithMigration_THEN_OnePreferredHealthCertifiedPerson() throws {
//		// GIVEN
//		let cert01 = try HealthCertificate(base45: try cert01())
//		let cert02 = try HealthCertificate(base45: try cert02())
//		let cert03 = try HealthCertificate(base45: try cert03())
//		let person01 = HealthCertifiedPerson(
//			healthCertificates: [cert01],
//			isPreferredPerson: true,
//			boosterRule: .fake(),
//			isNewBoosterRule: true
//		)
//		let person02 = HealthCertifiedPerson(
//			healthCertificates: [cert02, cert03],
//			isPreferredPerson: false,
//			boosterRule: nil,
//			isNewBoosterRule: false
//		)
//
//		let store = MockTestStore(healthCertifiedPersonsVersion: nil) // fake old version
//		store.healthCertifiedPersons = [person01, person02]
//
//		// WHEN
//		let service = getService(store: store)
//
//		// THEN
//		XCTAssertEqual(service.healthCertifiedPersons.count, 1)
//
//		let mergedPerson = try XCTUnwrap(service.healthCertifiedPersons.first)
//		XCTAssertEqual(mergedPerson.healthCertificates, [cert03, cert02, cert01])
//		XCTAssertTrue(mergedPerson.isPreferredPerson)
//		XCTAssertNil(mergedPerson.boosterRule)
//		XCTAssertFalse(mergedPerson.isNewBoosterRule)
//	}
//
//	// with migration grouping will apply, merged person is not preferred, other person is untouched
//	func testGIVEN_ServiceWithCertificatesInStore_NoPersonIsPreferred_WHEN_ServiceWithMigration_THEN_OneNotPreferredHealthCertifiedPerson() throws {
//		// GIVEN
//		let cert01 = try HealthCertificate(base45: try cert01())
//		let cert02 = try HealthCertificate(base45: try cert02())
//		let cert03 = try HealthCertificate(base45: try cert03())
//		let cert04 = try HealthCertificate(base45: try cert04())
//		let person01 = HealthCertifiedPerson(
//			healthCertificates: [cert01],
//			isPreferredPerson: false,
//			boosterRule: nil,
//			isNewBoosterRule: false
//		)
//		let person02 = HealthCertifiedPerson(
//			healthCertificates: [cert02, cert03],
//			isPreferredPerson: false,
//			boosterRule: nil,
//			isNewBoosterRule: false
//		)
//		let person03 = HealthCertifiedPerson(
//			healthCertificates: [cert04],
//			isPreferredPerson: true,
//			dccWalletInfo: .fake(
//				boosterNotification: .fake(visible: true, identifier: "BoosterRuleIdentifier"),
//				validUntil: Date(timeIntervalSinceNow: 100)
//			),
//			isNewBoosterRule: true
//		)
//
//		let store = MockTestStore(healthCertifiedPersonsVersion: nil) // fake old version
//		store.healthCertifiedPersons = [person01, person02, person03]
//
//		// WHEN
//		let service = getService(store: store)
//
//		// THEN
//		XCTAssertEqual(service.healthCertifiedPersons.count, 2)
//
//		let mergedPerson = try XCTUnwrap(service.healthCertifiedPersons.last)
//		XCTAssertEqual(mergedPerson.healthCertificates, [cert03, cert02, cert01])
//		XCTAssertFalse(mergedPerson.isPreferredPerson)
//		XCTAssertNil(mergedPerson.boosterRule)
//		XCTAssertFalse(mergedPerson.isNewBoosterRule)
//
//		let otherPerson = try XCTUnwrap(service.healthCertifiedPersons.first)
//		XCTAssertEqual(otherPerson.healthCertificates, [cert04])
//		XCTAssertTrue(otherPerson.isPreferredPerson)
//		XCTAssertNotNil(otherPerson.dccWalletInfo)
//		XCTAssertTrue(otherPerson.isNewBoosterRule)
//	}
//
//	// MARK: - Helpers
//
//	private func getService(store: Store) -> HealthCertificateService {
//		let client = ClientMock()
//		return HealthCertificateService(
//			store: store,
//			dccSignatureVerifier: DCCSignatureVerifyingStub(),
//			dscListProvider: MockDSCListProvider(),
//			client: client,
//			appConfiguration: CachedAppConfigurationMock(
//				with: SAP_Internal_V2_ApplicationConfigurationIOS()
//			),
//			cclService: FakeCCLService(),
//			recycleBin: RecycleBin(
//				store: store
//			)
//		)
//	}
//
//	private func thomasCert01() throws -> Base45 {
//		try base45Fake(
//			from: DigitalCovidCertificate.fake(
//				name: .fake(
//					standardizedFamilyName: "MEYER<SCHMIDT",
//					standardizedGivenName: "THOMAS<ARMIN"
//				),
//				dateOfBirth: "1966-11-16",
//				vaccinationEntries: [.fake()]
//			)
//		)
//	}
//
//	private func thomasCert02() throws -> Base45 {
//		try base45Fake(
//			from: DigitalCovidCertificate.fake(
//				name: .fake(
//					standardizedFamilyName: "MEYER",
//					standardizedGivenName: "THOMAS"
//				),
//				dateOfBirth: "1966-11-16",
//				testEntries: [.fake()]
//			)
//		)
//	}
//
//	private func thomasCert03() throws -> Base45 {
//		try base45Fake(
//			from: DigitalCovidCertificate.fake(
//				name: .fake(
//					standardizedFamilyName: "SCHMIDT",
//					standardizedGivenName: "ARMIN"
//				),
//				dateOfBirth: "1966-11-16",
//				recoveryEntries: [.fake()]
//			)
//		)
//	}
//
//	private func ulrikeCert01() throws -> Base45 {
//		try base45Fake(
//			from: DigitalCovidCertificate.fake(
//				name: .fake(
//					standardizedFamilyName: "MEYER",
//					standardizedGivenName: "ULRIKE"
//				),
//				dateOfBirth: "1967-04-23",
//				vaccinationEntries: [.fake()]
//			)
//		)
//	}
//
//}
