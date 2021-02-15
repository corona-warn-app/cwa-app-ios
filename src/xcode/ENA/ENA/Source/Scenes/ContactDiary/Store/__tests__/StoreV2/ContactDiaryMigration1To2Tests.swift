////
// 🦠 Corona-Warn-App
//

import XCTest
import FMDB
@testable import ENA

class ContactDiaryMigration1To2Tests: XCTestCase {

	func test_WHEN_migrationFrom1To2_THEN_PrefixedZerosAreRemoved() throws {
		let contactDiaryAccess = ContactDiaryAccess()

		guard let databaseQueue = FMDatabaseQueue(path: "file::memory:") else {
			XCTFail("Could not create FMDatabaseQueue.")
			return
		}

		// Create V1 schema.

		let schemaV1 = ContactDiaryStoreSchemaV1(databaseQueue: databaseQueue)

		let schemaV1Result = schemaV1.create()
		if case let .failure(error) = schemaV1Result {
			XCTFail("Error not expected: \(error)")
		}

		let oldName = "007"
		let oldLocation = "00005"
		let expectedFetchedOldName = "7"
		let expectedFetchedOldLocation = "5"

		let contactPersonId = contactDiaryAccess.addContactPerson(with: oldName, to: databaseQueue)
		let locationId = contactDiaryAccess.addLocation(with: oldLocation, to: databaseQueue)

		// Migrate to V2 schema.

		let migrator = SerialDatabaseQueueMigrator(
			queue: databaseQueue,
			latestVersion: 2,
			migrations: [ContactDiaryMigration1To2(databaseQueue: databaseQueue)]
		)
		try migrator.migrate()

		// Check if the leading zeros are removed.

		let contactPersonResult = contactDiaryAccess.fetchItem(from: "ContactPerson", with: contactPersonId, from: databaseQueue)
		guard  let name = contactPersonResult.string(forColumn: "name") else {
			XCTFail("Failed to fetch ContactPerson")
			return
		}
		let location = contactDiaryAccess.fetchItem(from: "Location", with: locationId, from: databaseQueue)
		guard let locationName = location.string(forColumn: "name") else {
			XCTFail("Failed to fetch ContactPerson")
			return
		}

		XCTAssertEqual(name, expectedFetchedOldName)
		XCTAssertEqual(locationName, expectedFetchedOldLocation)

		// Test if prefix zeros are saved correctly in V2.

		let expectedFetchedNewName = "00008"
		let expectedFetchedNewLocation = "00000"

		let contactPersonId2 = contactDiaryAccess.addContactPerson(with: expectedFetchedNewName, to: databaseQueue)
		let locationId2 = contactDiaryAccess.addLocation(with: expectedFetchedNewLocation, to: databaseQueue)

		let newContactPersonResult = contactDiaryAccess.fetchItem(from: "ContactPerson", with: contactPersonId2, from: databaseQueue)
		guard let newName = newContactPersonResult.string(forColumn: "name") else {
			XCTFail("Failed to fetch ContactPerson")
			return
		}
		let newLocation = contactDiaryAccess.fetchItem(from: "Location", with: locationId2, from: databaseQueue)
		guard let newLocationName = newLocation.string(forColumn: "name") else {
			XCTFail("Failed to fetch ContactPerson")
			return
		}

		XCTAssertEqual(expectedFetchedNewName, newName)
		XCTAssertEqual(expectedFetchedNewLocation, newLocationName)
	}
}
