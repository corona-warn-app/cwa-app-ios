//
// 🦠 Corona-Warn-App
//

import XCTest
import HealthCertificateToolkit
@testable import ENA

class HealthCertificateServiceMigrationTests: XCTestCase {

	// make sure grouping works as expected
	func testGIVEN_ServiceWithEmptyStore_WHEN_RegisterThreeCertificatesWithDifferentSpelling_THEN_OnePersonIsCreated() throws {
		// GIVEN
		let store = MockTestStore()
		let service = getService(store: store)

		// WHEN
		service.registerHealthCertificate(base45: try cert01())
		service.registerHealthCertificate(base45: try cert02())
		service.registerHealthCertificate(base45: try cert03())

		// THEN
		XCTAssertEqual(service.healthCertifiedPersons.count, 1)
	}

	// without migration no grouping will apply
	func testGIVEN_ServiceWithCertificatesInStore_WHEN_ServiceWithNoMigration_THEN_TwoHealthCertifiedPersons() throws {
		// GIVEN
		let cert01 = try HealthCertificate(base45: try cert01())
		let cert02 = try HealthCertificate(base45: try cert02())
		let cert03 = try HealthCertificate(base45: try cert03())
		let person01 = HealthCertifiedPerson(healthCertificates: [cert01])
		let person02 = HealthCertifiedPerson(healthCertificates: [cert02, cert03])
		let store = MockTestStore()
		store.healthCertifiedPersons = [person01, person02]

		// WHEN
		let service = getService(store: store)

		// THEN
		XCTAssertEqual(service.healthCertifiedPersons.count, 2)
	}

	// with migration grouping will apply, preferred person state is transferred from second person
	func testGIVEN_ServiceWithCertificatesInStore_SecondPersonIsPreferred_WHEN_ServiceWithMigration_THEN_OnePreferredHealthCertifiedPerson() throws {
		// GIVEN
		let cert01 = try HealthCertificate(base45: try cert01(), validityState: .expired, didShowInvalidNotification: true)
		let cert02 = try HealthCertificate(base45: try cert02(), isNew: true)
		let cert03 = try HealthCertificate(base45: try cert03(), isValidityStateNew: true)
		let person01 = HealthCertifiedPerson(
			healthCertificates: [cert01],
			isPreferredPerson: false,
			boosterRule: nil,
			isNewBoosterRule: false
		)
		let person02 = HealthCertifiedPerson(
			healthCertificates: [cert02, cert03],
			isPreferredPerson: true,
			boosterRule: .fake(),
			isNewBoosterRule: true
		)

		let store = MockTestStore(healthCertifiedPersonsVersion: nil) // fake old version
		store.healthCertifiedPersons = [person01, person02]

		// WHEN
		let service = getService(store: store)

		// THEN
		XCTAssertEqual(service.healthCertifiedPersons.count, 1)

		let mergedPerson = try XCTUnwrap(service.healthCertifiedPersons.first)
		XCTAssertEqual(mergedPerson.healthCertificates, [cert03, cert02, cert01])
		XCTAssertTrue(mergedPerson.isPreferredPerson)
		XCTAssertNil(mergedPerson.boosterRule)
		XCTAssertFalse(mergedPerson.isNewBoosterRule)

		// Check that certificate properties are properly migrated
		XCTAssertEqual(mergedPerson.healthCertificates[2].validityState, .expired)
		XCTAssertTrue(mergedPerson.healthCertificates[2].didShowInvalidNotification)
		XCTAssertTrue(mergedPerson.healthCertificates[1].isNew)
		XCTAssertTrue(mergedPerson.healthCertificates[0].isValidityStateNew)
	}

	// with migration grouping will apply, preferred person state is transferred from first person
	func testGIVEN_ServiceWithCertificatesInStore_FirstPersonIsPreferred_WHEN_ServiceWithMigration_THEN_OnePreferredHealthCertifiedPerson() throws {
		// GIVEN
		let cert01 = try HealthCertificate(base45: try cert01())
		let cert02 = try HealthCertificate(base45: try cert02())
		let cert03 = try HealthCertificate(base45: try cert03())
		let person01 = HealthCertifiedPerson(
			healthCertificates: [cert01],
			isPreferredPerson: true,
			boosterRule: .fake(),
			isNewBoosterRule: true
		)
		let person02 = HealthCertifiedPerson(
			healthCertificates: [cert02, cert03],
			isPreferredPerson: false,
			boosterRule: nil,
			isNewBoosterRule: false
		)

		let store = MockTestStore(healthCertifiedPersonsVersion: nil) // fake old version
		store.healthCertifiedPersons = [person01, person02]

		// WHEN
		let service = getService(store: store)

		// THEN
		XCTAssertEqual(service.healthCertifiedPersons.count, 1)

		let mergedPerson = try XCTUnwrap(service.healthCertifiedPersons.first)
		XCTAssertEqual(mergedPerson.healthCertificates, [cert03, cert02, cert01])
		XCTAssertTrue(mergedPerson.isPreferredPerson)
		XCTAssertNil(mergedPerson.boosterRule)
		XCTAssertFalse(mergedPerson.isNewBoosterRule)
	}

	// with migration grouping will apply, merged person is not preferred, other person is untouched
	func testGIVEN_ServiceWithCertificatesInStore_NoPersonIsPreferred_WHEN_ServiceWithMigration_THEN_OneNotPreferredHealthCertifiedPerson() throws {
		// GIVEN
		let cert01 = try HealthCertificate(base45: try cert01())
		let cert02 = try HealthCertificate(base45: try cert02())
		let cert03 = try HealthCertificate(base45: try cert03())
		let cert04 = try HealthCertificate(base45: try cert04())
		let person01 = HealthCertifiedPerson(
			healthCertificates: [cert01],
			isPreferredPerson: false,
			boosterRule: nil,
			isNewBoosterRule: false
		)
		let person02 = HealthCertifiedPerson(
			healthCertificates: [cert02, cert03],
			isPreferredPerson: false,
			boosterRule: nil,
			isNewBoosterRule: false
		)
		let person03 = HealthCertifiedPerson(
			healthCertificates: [cert04],
			isPreferredPerson: true,
			dccWalletInfo: .fake(
				boosterNotification: .fake(visible: true, identifier: "BoosterRuleIdentifier"),
				validUntil: Date(timeIntervalSinceNow: 100)
			),
			isNewBoosterRule: true
		)

		let store = MockTestStore(healthCertifiedPersonsVersion: nil) // fake old version
		store.healthCertifiedPersons = [person01, person02, person03]

		// WHEN
		let service = getService(store: store)

		// THEN
		XCTAssertEqual(service.healthCertifiedPersons.count, 2)

		let mergedPerson = try XCTUnwrap(service.healthCertifiedPersons.last)
		XCTAssertEqual(mergedPerson.healthCertificates, [cert03, cert02, cert01])
		XCTAssertFalse(mergedPerson.isPreferredPerson)
		XCTAssertNil(mergedPerson.boosterRule)
		XCTAssertFalse(mergedPerson.isNewBoosterRule)

		let otherPerson = try XCTUnwrap(service.healthCertifiedPersons.first)
		XCTAssertEqual(otherPerson.healthCertificates, [cert04])
		XCTAssertTrue(otherPerson.isPreferredPerson)
		XCTAssertNotNil(otherPerson.dccWalletInfo)
		XCTAssertTrue(otherPerson.isNewBoosterRule)
	}

	// MARK: - Helpers

	private func getService(store: Store) -> HealthCertificateService {
		let client = ClientMock()
		return HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
			client: client,
			appConfiguration: CachedAppConfigurationMock(
				with: SAP_Internal_V2_ApplicationConfigurationIOS()
			),
			cclService: FakeCCLService(),
			recycleBin: RecycleBin(
				store: store
			)
		)
	}

	private func cert01() throws -> Base45 {
		try base45Fake(
			from: DigitalCovidCertificate.fake(
				name: .fake(
					familyName: "Meyer",
					givenName: "Thomas  Armin",
					standardizedFamilyName: "MEYER",
					standardizedGivenName: "THOMAS<<ARMIN"
				),
				dateOfBirth: "1966-11-16",
				vaccinationEntries: [.fake(dateOfVaccination: "2021-06-02")]
			),
			and: .fake()
		)
	}

	private func cert02() throws -> Base45 {
		try base45Fake(
			from: DigitalCovidCertificate.fake(
				name: .fake(
					familyName: "Meyer",
					givenName: "Thomas Armin",
					standardizedFamilyName: "MEYER",
					standardizedGivenName: "THOMAS<ARMIN"
				),
				dateOfBirth: "1966-11-16",
				testEntries: [.fake(dateTimeOfSampleCollection: "2021-05-29T22:34:17.595Z")]
			)
		)
	}

	private func cert03() throws -> Base45 {
		try base45Fake(
			from: DigitalCovidCertificate.fake(
				name: .fake(
					familyName: "Meyer",
					givenName: "Thomas Armin",
					standardizedFamilyName: "MEYER",
					standardizedGivenName: "THOMAS<ARMIN"
				),
				dateOfBirth: "1966-11-16",
				recoveryEntries: [.fake(certificateValidFrom: "2021-05-01")]
			)
		)
	}

	private func cert04() throws -> Base45 {
		try base45Fake(
			from: DigitalCovidCertificate.fake(
				name: .fake(
					familyName: "Meyer",
					givenName: "Ulrike",
					standardizedFamilyName: "MEYER",
					standardizedGivenName: "ULRIKE"
				),
				dateOfBirth: "1967-04-23",
				vaccinationEntries: [.fake(dateOfVaccination: "2021-06-02")]
			),
			and: .fake()
		)
	}

}
