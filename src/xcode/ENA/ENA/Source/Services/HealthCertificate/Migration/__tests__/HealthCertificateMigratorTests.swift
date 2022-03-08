//
// 🦠 Corona-Warn-App
//

import Foundation
import XCTest
import HealthCertificateToolkit
@testable import ENA

// swiftlint:disable file_length
// swiftlint:disable type_body_length
class HealthCertificateMigratorTests: XCTestCase {

	func testGIVEN_2_Persons_WHEN_Migration_THEN_GroupingIsNotChanged() throws {

		// GIVEN
		let thomas01 = HealthCertifiedPerson(
			healthCertificates: [
				try HealthCertificate(
					base45: try thomasCert01(),
					isNew: true
				)],
			isPreferredPerson: true,
			dccWalletInfo: .fake()
		)

		let ulrike01 = HealthCertifiedPerson(
			healthCertificates: [
				try HealthCertificate(
					base45: try ulrikeCert01(),
					isValidityStateNew: true
				)
			],
			dccWalletInfo: .fake()
		)
		let store = MockTestStore(healthCertifiedPersonsVersion: 2)
		store.healthCertifiedPersons = [
			thomas01,
			ulrike01
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

		XCTAssertEqual(thomas.name, thomas01.name)
		XCTAssertEqual(thomas.healthCertificates.count, 1)
		XCTAssertEqual(ulrike.name, ulrike01.name)
		XCTAssertEqual(ulrike.healthCertificates.count, 1)
		// Test migrated properties
		XCTAssertTrue(thomas.isPreferredPerson)
		XCTAssertNotNil(thomas.dccWalletInfo)
		XCTAssertFalse(thomas.mostRecentWalletInfoUpdateFailed)
		XCTAssertNil(thomas.boosterRule)
		XCTAssertFalse(thomas.isNewBoosterRule)
		XCTAssertTrue(ulrike.healthCertificates[0].isValidityStateNew)
		XCTAssertFalse(ulrike.isPreferredPerson)
		XCTAssertNotNil(ulrike.dccWalletInfo)
		XCTAssertFalse(ulrike.mostRecentWalletInfoUpdateFailed)
		XCTAssertNil(ulrike.boosterRule)
		XCTAssertFalse(ulrike.isNewBoosterRule)
	}
	
	func testGIVEN_4_Persons_Order_1_WHEN_Migration_THEN_Grouped_to_2_Persons() throws {
		
		// GIVEN
		
		let thomas01 = HealthCertifiedPerson(
			healthCertificates: [
				try HealthCertificate(
					base45: try thomasCert01(),
					validityState: .expired,
					didShowInvalidNotification: true
				)
			],
			dccWalletInfo: .fake()
		)
		let thomas02 = HealthCertifiedPerson(
			healthCertificates: [
				try HealthCertificate(
					base45: try thomasCert02(),
					isNew: true
				)
			],
			dccWalletInfo: .fake()
		)
		let thomas03 = HealthCertifiedPerson(
			healthCertificates: [
				try HealthCertificate(
					base45: try thomasCert03()
				)
			],
			isPreferredPerson: true,
			dccWalletInfo: .fake(),
			mostRecentWalletInfoUpdateFailed: true,
			boosterRule: .fake(),
			isNewBoosterRule: true
		)
		let ulrike01 = HealthCertifiedPerson(
			healthCertificates: [
				try HealthCertificate(
					base45: try ulrikeCert01(),
					isValidityStateNew: true
				)
			],
			dccWalletInfo: .fake()
		)
		let store = MockTestStore(healthCertifiedPersonsVersion: 2)
		store.healthCertifiedPersons = [
			thomas01,
			thomas02,
			thomas03,
			ulrike01
		]
		
		// WHEN
		let migrator = HealthCertificateMigrator()
		migrator.migrate(store: store)
		let migratedPersons = store.healthCertifiedPersons
		
		// THEN
		
		// Test grouping
		XCTAssertEqual(migratedPersons.count, 2)
		let thomas = migratedPersons[0]
		let ulrike = migratedPersons[1]
		
		XCTAssertEqual(thomas.name, thomas01.name)
		XCTAssertEqual(thomas.healthCertificates.count, 3)

		XCTAssertEqual(ulrike.name, ulrike01.name)
		XCTAssertEqual(ulrike.healthCertificates.count, 1)

		// Test migrated properties
		XCTAssertTrue(thomas.isPreferredPerson)
		XCTAssertNil(thomas.dccWalletInfo)
		XCTAssertFalse(thomas.mostRecentWalletInfoUpdateFailed)
		XCTAssertNil(thomas.boosterRule)
		XCTAssertFalse(thomas.isNewBoosterRule)
		XCTAssertEqual(thomas.healthCertificates[0].validityState, .expired)
		XCTAssertTrue(thomas.healthCertificates[0].didShowInvalidNotification)
		XCTAssertTrue(thomas.healthCertificates[1].isNew)
		XCTAssertTrue(ulrike.healthCertificates[0].isValidityStateNew)
		XCTAssertFalse(ulrike.isPreferredPerson)
		XCTAssertNotNil(ulrike.dccWalletInfo)
		XCTAssertFalse(ulrike.mostRecentWalletInfoUpdateFailed)
		XCTAssertNil(ulrike.boosterRule)
		XCTAssertFalse(ulrike.isNewBoosterRule)
	}
	
	func testGIVEN_4_Persons_Order_2_WHEN_Migration_THEN_Grouped_to_2_Persons() throws {
		// GIVEN
		
		let thomas01 = HealthCertifiedPerson(
			healthCertificates: [
				try HealthCertificate(base45: try thomasCert01())
			],
			dccWalletInfo: .fake()
		)
		let thomas02 = HealthCertifiedPerson(
			healthCertificates: [
				try HealthCertificate(
					base45: try thomasCert02()
				)
			],
			dccWalletInfo: .fake(),
			boosterRule: .fake()
		)
		let thomas03 = HealthCertifiedPerson(
			healthCertificates: [
				try HealthCertificate(base45: try thomasCert03())
			],
			dccWalletInfo: .fake()
		)
		let ulrike01 = HealthCertifiedPerson(
			healthCertificates: [
				try HealthCertificate(
					base45: try ulrikeCert01()
				)
			],
			isPreferredPerson: true,
			dccWalletInfo: .fake(),
			boosterRule: nil
		)
		
		let store = MockTestStore(healthCertifiedPersonsVersion: 2)
		store.healthCertifiedPersons = [
			thomas01,
			thomas02,
			thomas03,
			ulrike01
		]
		
		// WHEN
		let migrator = HealthCertificateMigrator()
		migrator.migrate(store: store)
		let migratedPersons = store.healthCertifiedPersons
		
		// THEN
		// By setting isPreferred to ulrike, we expect her to be first in the list
		XCTAssertEqual(migratedPersons.count, 2)
		XCTAssertEqual(migratedPersons[0].name, ulrike01.name)
		XCTAssertEqual(migratedPersons[0].healthCertificates.count, 1)
		XCTAssertTrue(migratedPersons[0].isPreferredPerson)
		XCTAssertNotNil(migratedPersons[0].dccWalletInfo)
		XCTAssertFalse(migratedPersons[0].mostRecentWalletInfoUpdateFailed)
		XCTAssertNil(migratedPersons[0].boosterRule)

		XCTAssertEqual(migratedPersons[1].name, thomas01.name)
		XCTAssertEqual(migratedPersons[1].healthCertificates.count, 3)
		XCTAssertFalse(migratedPersons[1].isPreferredPerson)
		XCTAssertNil(migratedPersons[1].dccWalletInfo)
		XCTAssertFalse(migratedPersons[0].mostRecentWalletInfoUpdateFailed)
		XCTAssertNil(migratedPersons[1].boosterRule)
	}
	
	func testGIVEN_4_Persons_Order_3_WHEN_Migration_THEN_Grouped_to_2_Persons() throws {
		// GIVEN
		let thomas01 = HealthCertifiedPerson(healthCertificates: [
			try HealthCertificate(base45: try thomasCert01())
		])
		let thomas02 = HealthCertifiedPerson(healthCertificates: [
			try HealthCertificate(base45: try thomasCert02())
		])
		let thomas03 = HealthCertifiedPerson(
			healthCertificates: [
				try HealthCertificate(
					base45: try thomasCert03()
				)
			],
			dccWalletInfo: .fake(
				boosterNotification: .fake(visible: true, identifier: "BoosterRuleIdentifier"),
				validUntil: Date(timeIntervalSinceNow: 100)
			)
		)
		let ulrike01 = HealthCertifiedPerson(healthCertificates: [
			try HealthCertificate(base45: try ulrikeCert01())
		])
		
		let store = MockTestStore(healthCertifiedPersonsVersion: 2)
		store.healthCertifiedPersons = [
			thomas02,
			thomas03,
			thomas01,
			ulrike01
		]
		
		// WHEN
		let migrator = HealthCertificateMigrator()
		migrator.migrate(store: store)
		let migratedPersons = store.healthCertifiedPersons
		
		// THEN
		XCTAssertEqual(migratedPersons.count, 2)
		XCTAssertEqual(migratedPersons[0].name, thomas01.name)
		XCTAssertEqual(migratedPersons[0].healthCertificates.count, 3)
		XCTAssertNil(migratedPersons[0].dccWalletInfo)

		XCTAssertEqual(migratedPersons[1].name, ulrike01.name)
		XCTAssertEqual(migratedPersons[1].healthCertificates.count, 1)

	}
	
	func testGIVEN_4_Persons_Order_4_WHEN_Migration_THEN_Grouped_to_2_Persons() throws {
		// GIVEN
		let thomas01 = HealthCertifiedPerson(healthCertificates: [
			try HealthCertificate(base45: try thomasCert01())
		])
		let thomas02 = HealthCertifiedPerson(healthCertificates: [
			try HealthCertificate(base45: try thomasCert02())
		])
		let thomas03 = HealthCertifiedPerson(healthCertificates: [
			try HealthCertificate(base45: try thomasCert03())
		])
		let ulrike01 = HealthCertifiedPerson(healthCertificates: [
			try HealthCertificate(base45: try ulrikeCert01())
		])
		
		let store = MockTestStore(healthCertifiedPersonsVersion: 2)
		store.healthCertifiedPersons = [
			ulrike01,
			thomas02,
			thomas03,
			thomas01
		]
		
		// WHEN
		let migrator = HealthCertificateMigrator()
		migrator.migrate(store: store)
		let migratedPersons = store.healthCertifiedPersons
		
		// THEN
		XCTAssertEqual(migratedPersons.count, 2)
		XCTAssertEqual(migratedPersons[0].name, thomas01.name)
		XCTAssertEqual(migratedPersons[0].healthCertificates.count, 3)
		XCTAssertEqual(migratedPersons[1].name, ulrike01.name)
		XCTAssertEqual(migratedPersons[1].healthCertificates.count, 1)
	}
	
	func testGIVEN_5_Persons_WHEN_Migration_THEN_Grouped_to_3_Persons() throws {
		// GIVEN
		let thomas01 = HealthCertifiedPerson(healthCertificates: [
			try HealthCertificate(base45: try thomasCert01())
		])
		let thomas02 = HealthCertifiedPerson(healthCertificates: [
			try HealthCertificate(base45: try thomasCert02())
		])
		let thomas03 = HealthCertifiedPerson(healthCertificates: [
			try HealthCertificate(base45: try thomasCert03())
		])
		let ulrike01 = HealthCertifiedPerson(healthCertificates: [
			try HealthCertificate(base45: try ulrikeCert01())
		])
		let andreas01 = HealthCertifiedPerson(
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
			ulrike01,
			thomas02,
			thomas03,
			thomas01,
			andreas01
		]
		
		// WHEN
		let migrator = HealthCertificateMigrator()
		migrator.migrate(store: store)
		let migratedPersons = store.healthCertifiedPersons
		
		// THEN
		XCTAssertEqual(migratedPersons.count, 3)
		XCTAssertEqual(migratedPersons[0].name, andreas01.name)
		XCTAssertEqual(migratedPersons[0].healthCertificates.count, 1)
		XCTAssertNotNil(migratedPersons[0].dccWalletInfo)
		XCTAssertEqual(migratedPersons[1].name, thomas01.name)
		XCTAssertEqual(migratedPersons[1].healthCertificates.count, 3)
		XCTAssertEqual(migratedPersons[2].name, ulrike01.name)
		XCTAssertEqual(migratedPersons[2].healthCertificates.count, 1)
	}
	
	func testGIVEN_5_Persons_With_Prefered_WHEN_Migration_THEN_Grouped_to_3_Persons_prefered_on_top() throws {
		// GIVEN
		let thomas01 = HealthCertifiedPerson(healthCertificates: [
			try HealthCertificate(base45: try thomasCert01())
		])
		let thomas02 = HealthCertifiedPerson(
			healthCertificates: [
				try HealthCertificate(base45: try thomasCert02())
			],
			isPreferredPerson: true
		)
		let thomas03 = HealthCertifiedPerson(healthCertificates: [
			try HealthCertificate(base45: try thomasCert03())
		])
		let ulrike01 = HealthCertifiedPerson(healthCertificates: [
			try HealthCertificate(base45: try ulrikeCert01())
		])
		let andreas01 = HealthCertifiedPerson(healthCertificates: [
			try HealthCertificate(base45: try andreasCert01())
		])
		
		let store = MockTestStore(healthCertifiedPersonsVersion: 2)
		store.healthCertifiedPersons = [
			ulrike01,
			thomas02,
			thomas03,
			thomas01,
			andreas01
		]
		
		// WHEN
		let migrator = HealthCertificateMigrator()
		migrator.migrate(store: store)
		let migratedPersons = store.healthCertifiedPersons
		
		// THEN
		XCTAssertEqual(migratedPersons.count, 3)
		XCTAssertEqual(migratedPersons[0].name, thomas01.name)
		XCTAssertEqual(migratedPersons[0].healthCertificates.count, 3)
		XCTAssertEqual(migratedPersons[1].name, andreas01.name)
		XCTAssertEqual(migratedPersons[1].healthCertificates.count, 1)
		XCTAssertEqual(migratedPersons[2].name, ulrike01.name)
		XCTAssertEqual(migratedPersons[2].healthCertificates.count, 1)
	}
	
	func testGIVEN_6_Persons_WHEN_Migration_THEN_Grouped_to_3_Persons() throws {
		// GIVEN
		let thomas01 = HealthCertifiedPerson(
			healthCertificates: [
				try HealthCertificate(base45: try thomasCert01())
			],
			dccWalletInfo: .fake()
		)
		let thomas02 = HealthCertifiedPerson(
			healthCertificates: [
				try HealthCertificate(base45: try thomasCert02())
			],
			dccWalletInfo: .fake()
		)
		let thomas03 = HealthCertifiedPerson(
			healthCertificates: [
				try HealthCertificate(base45: try thomasCert03())
			],
			dccWalletInfo: .fake()
		)
		let ulrike01 = HealthCertifiedPerson(
			healthCertificates: [
				try HealthCertificate(base45: try ulrikeCert01())
			],
			dccWalletInfo: .fake()
		)
		let ulrike02 = HealthCertifiedPerson(
			healthCertificates: [
				try HealthCertificate(base45: try ulrikeCert02())
			],
			dccWalletInfo: .fake()
		)
		let andreas01 = HealthCertifiedPerson(
			healthCertificates: [
				try HealthCertificate(base45: try andreasCert01())
			],
			dccWalletInfo: .fake()
		)
		
		let store = MockTestStore(healthCertifiedPersonsVersion: 2)
		store.healthCertifiedPersons = [
			ulrike01,
			thomas02,
			thomas03,
			ulrike02,
			thomas01,
			andreas01
		]
		
		// WHEN
		let migrator = HealthCertificateMigrator()
		migrator.migrate(store: store)
		let migratedPersons = store.healthCertifiedPersons
		
		// THEN
		XCTAssertEqual(migratedPersons.count, 3)
		XCTAssertEqual(migratedPersons[0].name, andreas01.name)
		XCTAssertEqual(migratedPersons[0].healthCertificates.count, 1)
		XCTAssertNotNil(migratedPersons[0].dccWalletInfo)
		XCTAssertEqual(migratedPersons[1].name, thomas01.name)
		XCTAssertEqual(migratedPersons[1].healthCertificates.count, 3)
		XCTAssertNil(migratedPersons[1].dccWalletInfo)
		XCTAssertEqual(migratedPersons[2].name, ulrike01.name)
		XCTAssertEqual(migratedPersons[2].healthCertificates.count, 2)
		XCTAssertNil(migratedPersons[2].dccWalletInfo)
	}
	
	func testGIVEN_6_Persons_Shuffled_Order_WHEN_Migration_THEN_Grouped_to_3_Persons() throws {
		
		for _ in 0..<20 {
		
			// GIVEN
			let thomas01 = HealthCertifiedPerson(healthCertificates: [
				try HealthCertificate(base45: try thomasCert01())
			])
			let thomas02 = HealthCertifiedPerson(healthCertificates: [
				try HealthCertificate(base45: try thomasCert02())
			])
			let thomas03 = HealthCertifiedPerson(healthCertificates: [
				try HealthCertificate(base45: try thomasCert03())
			])
			let ulrike01 = HealthCertifiedPerson(healthCertificates: [
				try HealthCertificate(base45: try ulrikeCert01())
			])
			let ulrike02 = HealthCertifiedPerson(healthCertificates: [
				try HealthCertificate(base45: try ulrikeCert02())
			])
			let andreas01 = HealthCertifiedPerson(healthCertificates: [
				try HealthCertificate(base45: try andreasCert01())
			])
			
			let store = MockTestStore(healthCertifiedPersonsVersion: 2)
			store.healthCertifiedPersons = [
				ulrike01,
				thomas02,
				thomas03,
				ulrike02,
				thomas01,
				andreas01
			]
			
			store.healthCertifiedPersons.shuffle()
			
			// WHEN
			let migrator = HealthCertificateMigrator()
			migrator.migrate(store: store)
			let migratedPersons = store.healthCertifiedPersons
			
			// THEN
			XCTAssertEqual(migratedPersons.count, 3)
			XCTAssertEqual(migratedPersons[0].name, andreas01.name)
			XCTAssertEqual(migratedPersons[0].healthCertificates.count, 1)
			XCTAssertEqual(migratedPersons[1].name, thomas01.name)
			XCTAssertEqual(migratedPersons[1].healthCertificates.count, 3)
			XCTAssertEqual(migratedPersons[2].name, ulrike01.name)
			XCTAssertEqual(migratedPersons[2].healthCertificates.count, 2)
		}
	}

	func testGIVEN_SomePersons_WHEN_MigrationRegroupsNot_THEN_ShouldShowRegroupingAlertIsFalse() throws {
		// GIVEN
		let thomas01 = HealthCertifiedPerson(healthCertificates: [
			try HealthCertificate(base45: try thomasCert01())
		])

		let ulrike01 = HealthCertifiedPerson(healthCertificates: [
			try HealthCertificate(base45: try ulrikeCert01())
		])
		let store = MockTestStore(healthCertifiedPersonsVersion: 2)
		store.healthCertifiedPersons = [
			thomas01,
			ulrike01
		]

		XCTAssertFalse(store.shouldShowRegroupingAlert)

		// WHEN
		let migrator = HealthCertificateMigrator()
		migrator.migrate(store: store)
		let migratedPersons = store.healthCertifiedPersons

		// THEN

		// Test grouing
		XCTAssertEqual(migratedPersons.count, 2)
		let thomas = migratedPersons[0]
		let ulrike = migratedPersons[1]

		XCTAssertEqual(thomas.name, thomas01.name)
		XCTAssertEqual(thomas.healthCertificates.count, 1)
		XCTAssertEqual(ulrike.name, ulrike01.name)
		XCTAssertEqual(ulrike.healthCertificates.count, 1)
		XCTAssertFalse(store.shouldShowRegroupingAlert)

	}

	func testGIVEN_SomePersons_WHEN_MigrationRegroups_THEN_ShouldShowRegroupingAlertIsTrue() throws {
		// GIVEN
		let thomas01 = HealthCertifiedPerson(healthCertificates: [
			try HealthCertificate(base45: try thomasCert01())
		])
		let thomas02 = HealthCertifiedPerson(healthCertificates: [
			try HealthCertificate(base45: try thomasCert02())
		])
		let thomas03 = HealthCertifiedPerson(healthCertificates: [
			try HealthCertificate(base45: try thomasCert03())
		])
		let ulrike01 = HealthCertifiedPerson(healthCertificates: [
			try HealthCertificate(base45: try ulrikeCert01())
		])
		let ulrike02 = HealthCertifiedPerson(healthCertificates: [
			try HealthCertificate(base45: try ulrikeCert02())
		])
		let andreas01 = HealthCertifiedPerson(healthCertificates: [
			try HealthCertificate(base45: try andreasCert01())
		])

		let store = MockTestStore(healthCertifiedPersonsVersion: 2)
		store.healthCertifiedPersons = [
			ulrike01,
			thomas02,
			thomas03,
			ulrike02,
			thomas01,
			andreas01
		]

		XCTAssertFalse(store.shouldShowRegroupingAlert)

		// WHEN
		let migrator = HealthCertificateMigrator()
		migrator.migrate(store: store)
		let migratedPersons = store.healthCertifiedPersons

		// THEN
		XCTAssertEqual(migratedPersons.count, 3)
		XCTAssertEqual(migratedPersons[0].name, andreas01.name)
		XCTAssertEqual(migratedPersons[0].healthCertificates.count, 1)
		XCTAssertEqual(migratedPersons[1].name, thomas01.name)
		XCTAssertEqual(migratedPersons[1].healthCertificates.count, 3)
		XCTAssertEqual(migratedPersons[2].name, ulrike01.name)
		XCTAssertEqual(migratedPersons[2].healthCertificates.count, 2)
		XCTAssertTrue(store.shouldShowRegroupingAlert)
	}
	
	// MARK: - Helpers

	private func getService(store: Store) -> HealthCertificateService {
		return HealthCertificateService(
			store: store,
			dccSignatureVerifier: DCCSignatureVerifyingStub(),
			dscListProvider: MockDSCListProvider(),
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
