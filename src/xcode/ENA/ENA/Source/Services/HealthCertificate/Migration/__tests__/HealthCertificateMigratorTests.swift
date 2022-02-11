//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
import HealthCertificateToolkit
@testable import ENA

class HealthCertificateMigratorTests: XCTestCase {
	
	func testGIVEN_4_Persons_WHEN_migration_THEN_Grouped_to_2_Persons() throws {
		// GIVEN
		let thomasCert01 = HealthCertifiedPerson(healthCertificates: [
			try HealthCertificate(base45: try thomasCert01())
		])
		let thomasCert02 = HealthCertifiedPerson(healthCertificates: [
			try HealthCertificate(base45: try thomasCert02())
		])
		let thomasCert03 = HealthCertifiedPerson(healthCertificates: [
			try HealthCertificate(base45: try thomasCert03())
		])
		let ulrikeCert01 = HealthCertifiedPerson(healthCertificates: [
			try HealthCertificate(base45: try ulrikeCert01())
		])
		
		let healthCertifiedPersons = [
			thomasCert01,
			thomasCert02,
			thomasCert03,
			ulrikeCert01
		]
		
		// WHEN
		let migrator = HealthCertificateMigrator()
		let migratedPersons = migrator.migrate(persons: healthCertifiedPersons)
		
		// THEN
		XCTAssertEqual(migratedPersons.count, 2)
		XCTAssertEqual(migratedPersons[0], thomasCert01)
		XCTAssertEqual(migratedPersons[0].healthCertificates.count, 3)
		XCTAssertEqual(migratedPersons[1], ulrikeCert01)
	}
	
	func testGIVEN_4_Persons_WHEN_migration_THEN_Grouped_to_2_Persons_2() throws {
		// GIVEN
		let thomasCert01 = HealthCertifiedPerson(healthCertificates: [
			try HealthCertificate(base45: try thomasCert01())
		])
		let thomasCert02 = HealthCertifiedPerson(healthCertificates: [
			try HealthCertificate(base45: try thomasCert02())
		])
		let thomasCert03 = HealthCertifiedPerson(healthCertificates: [
			try HealthCertificate(base45: try thomasCert03())
		])
		let ulrikeCert01 = HealthCertifiedPerson(healthCertificates: [
			try HealthCertificate(base45: try ulrikeCert01())
		])
		
		let healthCertifiedPersons = [
			thomasCert01,
			thomasCert02,
			thomasCert03,
			ulrikeCert01
		]
		
		// WHEN
		let migrator = HealthCertificateMigrator()
		let migratedPersons = migrator.migrate(persons: healthCertifiedPersons)
		
		// THEN
		XCTAssertEqual(migratedPersons.count, 2)
		XCTAssertEqual(migratedPersons[0], thomasCert01)
		XCTAssertEqual(migratedPersons[0].healthCertificates.count, 3)
		XCTAssertEqual(migratedPersons[1], ulrikeCert01)
	}
	
	func testGIVEN_4_Persons_WHEN_migration_THEN_Grouped_to_2_Persons2() throws {
		// GIVEN
		let thomasCert01 = HealthCertifiedPerson(healthCertificates: [
			try HealthCertificate(base45: try thomasCert01())
		])
		let thomasCert02 = HealthCertifiedPerson(healthCertificates: [
			try HealthCertificate(base45: try thomasCert02())
		])
		let thomasCert03 = HealthCertifiedPerson(healthCertificates: [
			try HealthCertificate(base45: try thomasCert03())
		])
		let ulrikeCert01 = HealthCertifiedPerson(healthCertificates: [
			try HealthCertificate(base45: try ulrikeCert01())
		])
		
		let healthCertifiedPersons = [
			thomasCert02,
			thomasCert03,
			thomasCert01,
			ulrikeCert01
		]
		
		// WHEN
		let migrator = HealthCertificateMigrator()
		let migratedPersons = migrator.migrate(persons: healthCertifiedPersons)
		
		// THEN
		XCTAssertEqual(migratedPersons.count, 2)
		XCTAssertEqual(migratedPersons[0], thomasCert01)
		XCTAssertEqual(migratedPersons[0].healthCertificates.count, 3)
		XCTAssertEqual(migratedPersons[1], ulrikeCert01)
	}
	
	func testGIVEN_4_Persons_WHEN_migration_THEN_Grouped_to_2_Persons3() throws {
		// GIVEN
		let thomasCert01 = HealthCertifiedPerson(healthCertificates: [
			try HealthCertificate(base45: try thomasCert01())
		])
		let thomasCert02 = HealthCertifiedPerson(healthCertificates: [
			try HealthCertificate(base45: try thomasCert02())
		])
		let thomasCert03 = HealthCertifiedPerson(healthCertificates: [
			try HealthCertificate(base45: try thomasCert03())
		])
		let ulrikeCert01 = HealthCertifiedPerson(healthCertificates: [
			try HealthCertificate(base45: try ulrikeCert01())
		])
		
		let healthCertifiedPersons = [
			ulrikeCert01,
			thomasCert02,
			thomasCert03,
			thomasCert01
		]
		
		// WHEN
		let migrator = HealthCertificateMigrator()
		let migratedPersons = migrator.migrate(persons: healthCertifiedPersons)
		
		// THEN
		XCTAssertEqual(migratedPersons.count, 2)
		XCTAssertEqual(migratedPersons[0], thomasCert01)
		XCTAssertEqual(migratedPersons[0].healthCertificates.count, 3)
		XCTAssertEqual(migratedPersons[1], ulrikeCert01)
	}
	
	func testGIVEN_4_Persons_WHEN_migration_THEN_Grouped_to_2_Persons4() throws {
		// GIVEN
		let thomasCert01 = HealthCertifiedPerson(healthCertificates: [
			try HealthCertificate(base45: try thomasCert01())
		])
		let thomasCert02 = HealthCertifiedPerson(healthCertificates: [
			try HealthCertificate(base45: try thomasCert02())
		])
		let thomasCert03 = HealthCertifiedPerson(healthCertificates: [
			try HealthCertificate(base45: try thomasCert03())
		])
		let ulrikeCert01 = HealthCertifiedPerson(healthCertificates: [
			try HealthCertificate(base45: try ulrikeCert01())
		])
		let andreasCert01 = HealthCertifiedPerson(healthCertificates: [
			try HealthCertificate(base45: try andreasCert01())
		])
		
		let healthCertifiedPersons = [
			ulrikeCert01,
			thomasCert02,
			thomasCert03,
			thomasCert01,
			andreasCert01
		]
		
		// WHEN
		let migrator = HealthCertificateMigrator()
		let migratedPersons = migrator.migrate(persons: healthCertifiedPersons)
		
		// THEN
		XCTAssertEqual(migratedPersons.count, 3)
//		XCTAssertEqual(migratedPersons[0], thomasCert03)
//		XCTAssertEqual(migratedPersons[0].healthCertificates.count, 3)
//		XCTAssertEqual(migratedPersons[1], ulrikeCert01)
	}
	
	func testGIVEN_4_Persons_WHEN_migration_THEN_Grouped_to_2_Persons5() throws {
		// GIVEN
		let thomasCert01 = HealthCertifiedPerson(healthCertificates: [
			try HealthCertificate(base45: try thomasCert01())
		])
		let thomasCert02 = HealthCertifiedPerson(healthCertificates: [
			try HealthCertificate(base45: try thomasCert02())
		])
		let thomasCert03 = HealthCertifiedPerson(healthCertificates: [
			try HealthCertificate(base45: try thomasCert03())
		])
		let ulrikeCert01 = HealthCertifiedPerson(healthCertificates: [
			try HealthCertificate(base45: try ulrikeCert01())
		])
		let ulrikeCert02 = HealthCertifiedPerson(healthCertificates: [
			try HealthCertificate(base45: try ulrikeCert02())
		])
		let andreasCert01 = HealthCertifiedPerson(healthCertificates: [
			try HealthCertificate(base45: try andreasCert01())
		])
		
		let healthCertifiedPersons = [
			ulrikeCert01,
			thomasCert02,
			thomasCert03,
			ulrikeCert02,
			thomasCert01,
			andreasCert01
		]
		
		// WHEN
		let migrator = HealthCertificateMigrator()
		let migratedPersons = migrator.migrate(persons: healthCertifiedPersons)
		
		// THEN
		XCTAssertEqual(migratedPersons.count, 3)
//		XCTAssertEqual(migratedPersons[0], thomasCert03)
//		XCTAssertEqual(migratedPersons[0].healthCertificates.count, 3)
//		XCTAssertEqual(migratedPersons[1], ulrikeCert01)
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

	private func thomasCert01() throws -> Base45 {
		try base45Fake(
			from: DigitalCovidCertificate.fake(
				name: .fake(
					standardizedFamilyName: "MEYER<SCHMIDT",
					standardizedGivenName: "THOMAS<ARMIN"
				),
				dateOfBirth: "1966-11-16",
				vaccinationEntries: [.fake()]
			)
		)
	}

	private func thomasCert02() throws -> Base45 {
		try base45Fake(
			from: DigitalCovidCertificate.fake(
				name: .fake(
					standardizedFamilyName: "MEYER",
					standardizedGivenName: "THOMAS"
				),
				dateOfBirth: "1966-11-16",
				testEntries: [.fake()]
			)
		)
	}

	private func thomasCert03() throws -> Base45 {
		try base45Fake(
			from: DigitalCovidCertificate.fake(
				name: .fake(
					standardizedFamilyName: "SCHMIDT",
					standardizedGivenName: "ARMIN"
				),
				dateOfBirth: "1966-11-16",
				recoveryEntries: [.fake()]
			)
		)
	}
	
	private func andreasCert01() throws -> Base45 {
		try base45Fake(
			from: DigitalCovidCertificate.fake(
				name: .fake(
					standardizedFamilyName: "BECKER",
					standardizedGivenName: "ANDREAS"
				),
				dateOfBirth: "1967-04-23",
				vaccinationEntries: [.fake()]
			)
		)
	}

	private func ulrikeCert01() throws -> Base45 {
		try base45Fake(
			from: DigitalCovidCertificate.fake(
				name: .fake(
					standardizedFamilyName: "MEYER",
					standardizedGivenName: "ULRIKE"
				),
				dateOfBirth: "1967-04-23",
				vaccinationEntries: [.fake()]
			)
		)
	}
	
	private func ulrikeCert02() throws -> Base45 {
		try base45Fake(
			from: DigitalCovidCertificate.fake(
				name: .fake(
					standardizedFamilyName: "MEYER<MÜLLER",
					standardizedGivenName: "ULRIKE<TABEA"
				),
				dateOfBirth: "1967-04-23",
				vaccinationEntries: [.fake()]
			)
		)
	}
}
