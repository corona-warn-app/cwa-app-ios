//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
import HealthCertificateToolkit
@testable import ENA

class HealthCertificateMigratorTests: XCTestCase {
	
	func testGIVEN_4_Persons_Order_1_WHEN_Migration_THEN_Grouped_to_2_Persons() throws {
		
		// GIVEN
		
		let thomasCert01 = HealthCertifiedPerson(
			healthCertificates: [
				try HealthCertificate(
					base45: try thomasCert01(),
					validityState: .expired,
					didShowInvalidNotification: true
				)
			]
		)
		let thomasCert02 = HealthCertifiedPerson(
			healthCertificates: [
				try HealthCertificate(
					base45: try thomasCert02(),
					isNew: true
				)]
		)
		let thomasCert03 = HealthCertifiedPerson(
			healthCertificates: [
				try HealthCertificate(
					base45: try thomasCert03()
				)],
			isPreferredPerson: true,
			boosterRule: .fake(),
			isNewBoosterRule: true
		)
		let ulrikeCert01 = HealthCertifiedPerson(
			healthCertificates: [
				try HealthCertificate(
					base45: try ulrikeCert01(),
					isValidityStateNew: true
				)
			]
		)
		let store = MockTestStore(healthCertifiedPersonsVersion: 2)
		store.healthCertifiedPersons = [
			thomasCert01,
			thomasCert02,
			thomasCert03,
			ulrikeCert01
		]
		
		// WHEN
		let migrator = HealthCertificateMigrator()
		migrator.migrate(store: store)
		let migratedPersons = store.healthCertifiedPersons
		
		// THEN
		
		// Test grouing
		XCTAssertEqual(migratedPersons.count, 2)
		let thomas = migratedPersons[0]
		let ulrike = migratedPersons[1]
		
		XCTAssertEqual(thomas.name, thomasCert01.name)
		XCTAssertEqual(thomas.healthCertificates.count, 3)
		XCTAssertEqual(ulrike.name, ulrikeCert01.name)
		XCTAssertEqual(ulrike.healthCertificates.count, 1)
		// Test migrated properties
		XCTAssertTrue(thomas.isPreferredPerson)
		XCTAssertNotNil(thomas.boosterRule)
		XCTAssertFalse(thomas.isNewBoosterRule)
		XCTAssertEqual(thomas.healthCertificates[0].validityState, .expired)
		XCTAssertTrue(thomas.healthCertificates[0].didShowInvalidNotification)
		XCTAssertTrue(thomas.healthCertificates[1].isNew)
		XCTAssertTrue(ulrike.healthCertificates[0].isValidityStateNew)
	}
	
	func testGIVEN_4_Persons_Order_2_WHEN_Migration_THEN_Grouped_to_2_Persons() throws {
		// GIVEN
		
		let thomasCert01 = HealthCertifiedPerson(healthCertificates: [
			try HealthCertificate(base45: try thomasCert01())
		])
		let thomasCert02 = HealthCertifiedPerson(
			healthCertificates: [
				try HealthCertificate(
					base45: try thomasCert02()
				)],
			boosterRule: .fake()
		)
		let thomasCert03 = HealthCertifiedPerson(healthCertificates: [
			try HealthCertificate(base45: try thomasCert03())
		])
		let ulrikeCert01 = HealthCertifiedPerson(
			healthCertificates: [
				try HealthCertificate(
					base45: try ulrikeCert01()
				)],
			isPreferredPerson: true,
			boosterRule: nil
		)
		
		let store = MockTestStore(healthCertifiedPersonsVersion: 2)
		store.healthCertifiedPersons = [
			thomasCert01,
			thomasCert02,
			thomasCert03,
			ulrikeCert01
		]
		
		// WHEN
		let migrator = HealthCertificateMigrator()
		migrator.migrate(store: store)
		let migratedPersons = store.healthCertifiedPersons
		
		// THEN
		// By setting isPrefered to ulrike, we expect her to be first in the list
		XCTAssertEqual(migratedPersons.count, 2)
		XCTAssertEqual(migratedPersons[0].name, ulrikeCert01.name)
		XCTAssertEqual(migratedPersons[0].healthCertificates.count, 1)
		XCTAssertTrue(migratedPersons[0].isPreferredPerson)
		XCTAssertNil(migratedPersons[0].boosterRule)
		XCTAssertEqual(migratedPersons[1].name, thomasCert01.name)
		XCTAssertEqual(migratedPersons[1].healthCertificates.count, 3)
		XCTAssertFalse(migratedPersons[1].isPreferredPerson)
		XCTAssertNotNil(migratedPersons[1].boosterRule)
	}
	
	func testGIVEN_4_Persons_Order_3_WHEN_Migration_THEN_Grouped_to_2_Persons() throws {
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
		
		let store = MockTestStore(healthCertifiedPersonsVersion: 2)
		store.healthCertifiedPersons = [
			thomasCert02,
			thomasCert03,
			thomasCert01,
			ulrikeCert01
		]
		
		// WHEN
		let migrator = HealthCertificateMigrator()
		migrator.migrate(store: store)
		let migratedPersons = store.healthCertifiedPersons
		
		// THEN
		XCTAssertEqual(migratedPersons.count, 2)
		XCTAssertEqual(migratedPersons[0].name, thomasCert01.name)
		XCTAssertEqual(migratedPersons[0].healthCertificates.count, 3)
		XCTAssertEqual(migratedPersons[1].name, ulrikeCert01.name)
		XCTAssertEqual(migratedPersons[1].healthCertificates.count, 1)
	}
	
	func testGIVEN_4_Persons_Order_4_WHEN_Migration_THEN_Grouped_to_2_Persons() throws {
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
		
		let store = MockTestStore(healthCertifiedPersonsVersion: 2)
		store.healthCertifiedPersons = [
			ulrikeCert01,
			thomasCert02,
			thomasCert03,
			thomasCert01
		]
		
		// WHEN
		let migrator = HealthCertificateMigrator()
		migrator.migrate(store: store)
		let migratedPersons = store.healthCertifiedPersons
		
		// THEN
		XCTAssertEqual(migratedPersons.count, 2)
		XCTAssertEqual(migratedPersons[0].name, thomasCert01.name)
		XCTAssertEqual(migratedPersons[0].healthCertificates.count, 3)
		XCTAssertEqual(migratedPersons[1].name, ulrikeCert01.name)
		XCTAssertEqual(migratedPersons[1].healthCertificates.count, 1)
	}
	
	func testGIVEN_5_Persons_WHEN_Migration_THEN_Grouped_to_3_Persons() throws {
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
		let andreasCert01 = HealthCertifiedPerson(
			healthCertificates: [
			try HealthCertificate(
				base45: try andreasCert01()
			)],
			dccWalletInfo: .fake(
				boosterNotification: .fake(visible: true, identifier: "BoosterRuleIdentifier"),
				validUntil: Date(timeIntervalSinceNow: 100)
			))
		
		let store = MockTestStore(healthCertifiedPersonsVersion: 2)
		store.healthCertifiedPersons = [
			ulrikeCert01,
			thomasCert02,
			thomasCert03,
			thomasCert01,
			andreasCert01
		]
		
		// WHEN
		let migrator = HealthCertificateMigrator()
		migrator.migrate(store: store)
		let migratedPersons = store.healthCertifiedPersons
		
		// THEN
		XCTAssertEqual(migratedPersons.count, 3)
		XCTAssertEqual(migratedPersons[0].name, andreasCert01.name)
		XCTAssertEqual(migratedPersons[0].healthCertificates.count, 1)
		XCTAssertNotNil(migratedPersons[0].dccWalletInfo)
		XCTAssertEqual(migratedPersons[1].name, thomasCert01.name)
		XCTAssertEqual(migratedPersons[1].healthCertificates.count, 3)
		XCTAssertEqual(migratedPersons[2].name, ulrikeCert01.name)
		XCTAssertEqual(migratedPersons[2].healthCertificates.count, 1)
	}
	
	func testGIVEN_5_Persons_With_Prefered_WHEN_Migration_THEN_Grouped_to_3_Persons_prefered_on_top() throws {
		// GIVEN
		let thomasCert01 = HealthCertifiedPerson(healthCertificates: [
			try HealthCertificate(base45: try thomasCert01())
		])
		let thomasCert02 = HealthCertifiedPerson(
			healthCertificates: [
				try HealthCertificate(base45: try thomasCert02())
			],
			isPreferredPerson: true
		)
		let thomasCert03 = HealthCertifiedPerson(healthCertificates: [
			try HealthCertificate(base45: try thomasCert03())
		])
		let ulrikeCert01 = HealthCertifiedPerson(healthCertificates: [
			try HealthCertificate(base45: try ulrikeCert01())
		])
		let andreasCert01 = HealthCertifiedPerson(healthCertificates: [
			try HealthCertificate(base45: try andreasCert01())
		])
		
		let store = MockTestStore(healthCertifiedPersonsVersion: 2)
		store.healthCertifiedPersons = [
			ulrikeCert01,
			thomasCert02,
			thomasCert03,
			thomasCert01,
			andreasCert01
		]
		
		// WHEN
		let migrator = HealthCertificateMigrator()
		migrator.migrate(store: store)
		let migratedPersons = store.healthCertifiedPersons
		
		// THEN
		XCTAssertEqual(migratedPersons.count, 3)
		XCTAssertEqual(migratedPersons[0].name, thomasCert01.name)
		XCTAssertEqual(migratedPersons[0].healthCertificates.count, 3)
		XCTAssertEqual(migratedPersons[1].name, andreasCert01.name)
		XCTAssertEqual(migratedPersons[1].healthCertificates.count, 1)
		XCTAssertEqual(migratedPersons[2].name, ulrikeCert01.name)
		XCTAssertEqual(migratedPersons[2].healthCertificates.count, 1)
	}
	
	func testGIVEN_6_Persons_WHEN_Migration_THEN_Grouped_to_3_Persons() throws {
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
		
		let store = MockTestStore(healthCertifiedPersonsVersion: 2)
		store.healthCertifiedPersons = [
			ulrikeCert01,
			thomasCert02,
			thomasCert03,
			ulrikeCert02,
			thomasCert01,
			andreasCert01
		]
		
		// WHEN
		let migrator = HealthCertificateMigrator()
		migrator.migrate(store: store)
		let migratedPersons = store.healthCertifiedPersons
		
		// THEN
		XCTAssertEqual(migratedPersons.count, 3)
		XCTAssertEqual(migratedPersons[0].name, andreasCert01.name)
		XCTAssertEqual(migratedPersons[0].healthCertificates.count, 1)
		XCTAssertEqual(migratedPersons[1].name, thomasCert01.name)
		XCTAssertEqual(migratedPersons[1].healthCertificates.count, 3)
		XCTAssertEqual(migratedPersons[2].name, ulrikeCert01.name)
		XCTAssertEqual(migratedPersons[2].healthCertificates.count, 2)
	}
	
	func testGIVEN_6_Persons_Shuffled_Order_WHEN_Migration_THEN_Grouped_to_3_Persons() throws {
		
		for _ in 0..<20 {
		
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
			
			let store = MockTestStore(healthCertifiedPersonsVersion: 2)
			store.healthCertifiedPersons = [
				ulrikeCert01,
				thomasCert02,
				thomasCert03,
				ulrikeCert02,
				thomasCert01,
				andreasCert01
			]
			
			store.healthCertifiedPersons.shuffle()
			
			// WHEN
			let migrator = HealthCertificateMigrator()
			migrator.migrate(store: store)
			let migratedPersons = store.healthCertifiedPersons
			
			// THEN
			XCTAssertEqual(migratedPersons.count, 3)
			XCTAssertEqual(migratedPersons[0].name, andreasCert01.name)
			XCTAssertEqual(migratedPersons[0].healthCertificates.count, 1)
			XCTAssertEqual(migratedPersons[1].name, thomasCert01.name)
			XCTAssertEqual(migratedPersons[1].healthCertificates.count, 3)
			XCTAssertEqual(migratedPersons[2].name, ulrikeCert01.name)
			XCTAssertEqual(migratedPersons[2].healthCertificates.count, 2)
		}
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
				vaccinationEntries: [.fake(dateOfVaccination: "2022-01-01")]
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
				testEntries: [.fake(dateTimeOfSampleCollection: "2022-01-02T22:22:22.595Z")]
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
				recoveryEntries: [.fake(certificateValidFrom: "2022-01-03")]
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
				vaccinationEntries: [.fake(dateOfVaccination: "2022-01-01")]
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
				vaccinationEntries: [.fake(dateOfVaccination: "2022-01-02")]
			)
		)
	}
}
