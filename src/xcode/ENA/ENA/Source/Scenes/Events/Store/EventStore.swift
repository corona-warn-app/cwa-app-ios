////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine
import FMDB

class EventStore: EventStoring, EventProviding {

	static let encryptionKeyKey = "EventStoreEncryptionKey"

	// MARK: - Init

	init?(
		databaseQueue: FMDatabaseQueue,
		schema: SchemaProtocol,
		key: String,
		migrator: SerialMigratorProtocol
		) {
		self.databaseQueue = databaseQueue
		self.key = key
		self.schema = schema
		self.migrator = migrator

		guard case .success = openAndSetup() else {
			return nil
		}

		guard case .success = cleanup() else {
			return nil
		}

		registerToDidBecomeActiveNotification()
	}

	// MARK: - Protocol EventStoring

	func createEvent(event: Event) -> EventStoring.VoidResult {
		var result: EventStoring.VoidResult?

		databaseQueue.inDatabase { database in
			Log.info("[EventStore] Add Event.", log: .localData)

			let sql = """
				INSERT INTO Event (
					id,
					type,
					description,
					address,
					start,
					end,
					defaultCheckInLengthInMinutes,
					signature
				)
				VALUES (
					:id,
					:type,
					SUBSTR(:description, 1, \(maxTextLength)),
					SUBSTR(:address, 1, \(maxTextLength)),
					:start,
					:end,
					:defaultCheckInLengthInMinutes,
					:signature
				);
			"""
			let parameters: [String: Any] = [
				"id": event.id,
				"type": event.type,
				"description": event.description,
				"address": event.address,
				"start": Int(event.start.timeIntervalSince1970),
				"end": Int(event.end.timeIntervalSince1970),
				"defaultCheckInLengthInMinutes": event.defaultCheckInLengthInMinutes,
				"signature": event.signature
			]
			guard database.executeUpdate(sql, withParameterDictionary: parameters) else {
				logLastErrorCode(from: database)
				result = .failure(dbError(from: database))
				return
			}

			let updateEventsResult = updateEvents(with: database)
			guard case .success = updateEventsResult else {
				logLastErrorCode(from: database)
				result = .failure(dbError(from: database))
				return
			}

			result = .success(())
		}

		guard let _result = result else {
			fatalError("[EventStore] Result should not be nil.")
		}

		return _result
	}

	func deleteEvent(id: String) -> EventStoring.VoidResult {
		var result: EventStoring.VoidResult?

		databaseQueue.inDatabase { database in
			Log.info("[EventStore] Remove Event with id: \(id).", log: .localData)

			let sql = """
				DELETE FROM Event
				WHERE id = ?;
			"""

			do {
				try database.executeUpdate(sql, values: [id])
			} catch {
				logLastErrorCode(from: database)
				result = .failure(dbError(from: database))
				return
			}

			let updateEventsResult = updateEvents(with: database)
			guard case .success = updateEventsResult else {
				logLastErrorCode(from: database)
				result = .failure(dbError(from: database))
				return
			}

			result = .success(())
		}

		guard let _result = result else {
			fatalError("[EventStore] Result should not be nil.")
		}

		return _result
	}

	func createCheckin(checkin: Checkin) -> EventStoring.IdResult {
		var result: EventStoring.IdResult?

		databaseQueue.inDatabase { database in
			Log.info("[EventStore] Add Checkin.", log: .localData)

			let sql = """
				INSERT INTO Checkin (
					eventId,
					eventType,
					eventDescription,
					eventAddress,
					eventStart,
					eventEnd,
					eventDefaultCheckInLengthInMinutes,
					eventSignature,
					checkinStart,
					checkinEnd
				)
				VALUES (
					:eventId,
					:eventType,
					SUBSTR(:eventDescription, 1, \(maxTextLength))
					SUBSTR(:eventAddress, 1, \(maxTextLength)),
					:eventStart,
					:eventEnd,
					:eventDefaultCheckInLengthInMinutes,
					:eventSignature,
					:checkinStart,
					:checkinEnd
				);
			"""
			let parameters: [String: Any] = [
				"eventId": checkin.eventId,
				"eventType": checkin.eventType,
				"eventDescription": checkin.eventDescription,
				"eventAddress": checkin.eventAddress,
				"eventStart": Int(checkin.eventStart.timeIntervalSince1970),
				"eventEnd": Int(checkin.eventEnd.timeIntervalSince1970),
				"eventDefaultCheckInLengthInMinutes": checkin.eventDefaultCheckInLengthInMinutes,
				"eventSignature": checkin.eventSignature,
				"checkinStart": Int(checkin.checkinStart.timeIntervalSince1970),
				"checkinEnd": Int(checkin.checkinEnd.timeIntervalSince1970)
			]
			guard database.executeUpdate(sql, withParameterDictionary: parameters) else {
				logLastErrorCode(from: database)
				result = .failure(dbError(from: database))
				return
			}

			let updateCheckinsResult = updateCheckins(with: database)
			guard case .success = updateCheckinsResult else {
				logLastErrorCode(from: database)
				result = .failure(dbError(from: database))
				return
			}

			result = .success(Int(database.lastInsertRowId))
		}

		guard let _result = result else {
			fatalError("[EventStore] Result should not be nil.")
		}

		return _result
	}

	func deleteCheckin(id: Int) -> EventStoring.VoidResult {
		var result: EventStoring.VoidResult?

		databaseQueue.inDatabase { database in
			Log.info("[EventStore] Remove Checkin with id: \(id).", log: .localData)

			let sql = """
				DELETE FROM Checkin
				WHERE id = ?;
			"""

			do {
				try database.executeUpdate(sql, values: [id])
			} catch {
				logLastErrorCode(from: database)
				result = .failure(dbError(from: database))
				return
			}

			let updateCheckinsResult = updateCheckins(with: database)
			guard case .success = updateCheckinsResult else {
				logLastErrorCode(from: database)
				result = .failure(dbError(from: database))
				return
			}

			result = .success(())
		}

		guard let _result = result else {
			fatalError("[EventStore] Result should not be nil.")
		}

		return _result
	}

	func updateCheckin(id: Int, end: Date) -> EventStoring.VoidResult {
		var result: EventStoring.VoidResult?

		databaseQueue.inDatabase { database in
			Log.info("[EventStore] Update Checkin with id: \(id).", log: .localData)

			let sql = """
				UPDATE Checkin
				SET end = ?
				WHERE id = ?
			"""

			do {
				try database.executeUpdate(
					sql,
					values: [
						id,
						Int(end.timeIntervalSince1970)
					]
				)
			} catch {
				logLastErrorCode(from: database)
				result = .failure(dbError(from: database))
				return
			}

			let updateCheckinsResult = updateCheckins(with: database)
			guard case .success = updateCheckinsResult else {
				logLastErrorCode(from: database)
				result = .failure(dbError(from: database))
				return
			}

			result = .success(())
		}

		guard let _result = result else {
			fatalError("[EventStore] Result should not be nil.")
		}

		return _result
	}

	// MARK: - Protocol EventProviding

	var eventsPublisher = CurrentValueSubject<[Event], Never>([])

	var checkingPublisher = CurrentValueSubject<[Checkin], Never>([])

	// MARK: - Private

	private let databaseQueue: FMDatabaseQueue
	private let key: String
	private let schema: SchemaProtocol
	private let migrator: SerialMigratorProtocol
	private let maxTextLength = 150

	private func openAndSetup() -> EventStoring.VoidResult {
		var errorResult: EventStoring.VoidResult?
		var userVersion: UInt32 = 0

		databaseQueue.inDatabase { database in
			Log.info("[EventStore] Open and setup database.", log: .localData)
			let dbHandle = OpaquePointer(database.sqliteHandle)
			guard CWASQLite.sqlite3_key(dbHandle, key, Int32(key.count)) == SQLITE_OK else {
				Log.error("[EventStore] Unable to set Key for encryption.", log: .localData)
				errorResult = .failure(dbError(from: database))
				return
			}

			guard database.open() else {
				Log.error("[EventStore] Database could not be opened", log: .localData)
				errorResult = .failure(dbError(from: database))
				return
			}

			userVersion = database.userVersion

			let sql = """
				PRAGMA locking_mode=EXCLUSIVE;
				PRAGMA auto_vacuum=2;
				PRAGMA journal_mode=WAL;
			"""
			guard database.executeStatements(sql) else {
				logLastErrorCode(from: database)
				errorResult = .failure(dbError(from: database))
				return
			}
		}

		if let _errorResult = errorResult {
			return _errorResult
		}

		// if version is zero then this means this is a fresh database "i.e no previous app was installed"
		// then we create the latest schema
		if userVersion == 0 {
			let schemaCreateResult = schema.create()
			if case let .failure(error) = schemaCreateResult {
				return .failure(.database(error))
			}
		} else {
			migrate()
		}

		return .success(())
	}

	private func migrate() {
		do {
			try migrator.migrate()
		} catch {
			_ = MigrationError.general(description: error.localizedDescription)
		}
	}

	private func registerToDidBecomeActiveNotification() {
		NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActiveNotification), name: UIApplication.didBecomeActiveNotification, object: nil)
	}

	@objc
	private func didBecomeActiveNotification(_ notification: Notification) {
		cleanup()
	}

	@discardableResult
	private func cleanup() -> EventStoring.VoidResult {
		var result: EventStoring.VoidResult = .success(())

		databaseQueue.inDatabase { database in
			Log.info("[EventStore] Cleanup old entries.", log: .localData)

			// TODO: AFS

//			guard database.beginExclusiveTransaction() else {
//				logLastErrorCode(from: database)
//				result = .failure(dbError(from: database))
//				return
//			}
//
//			let sqlContactPersonEncounter = """
//				DELETE FROM ContactPersonEncounter
//				WHERE date < date('\(todayDateString)','-\(dataRetentionPeriodInDays - 1) days')
//			"""
//
//			let sqlLocationVisit = """
//				DELETE FROM LocationVisit
//				WHERE date < date('\(todayDateString)','-\(dataRetentionPeriodInDays - 1) days')
//			"""
//
//			do {
//				try database.executeUpdate(sqlContactPersonEncounter, values: nil)
//				try database.executeUpdate(sqlLocationVisit, values: nil)
//			} catch {
//				logLastErrorCode(from: database)
//				result = .failure(dbError(from: database))
//				return
//			}
//
//			guard database.commit() else {
//				logLastErrorCode(from: database)
//				result = .failure(dbError(from: database))
//				return
//			}
//
//			let updateDiaryDaysResult = updateDiaryDays(with: database)
//			guard case .success = updateDiaryDaysResult else {
//				logLastErrorCode(from: database)
//				result = .failure(dbError(from: database))
//				return
//			}
		}

		return result
	}

	@discardableResult
	private func updateEvents(with database: FMDatabase) -> EventStore.VoidResult {
		var result: EventStoring.VoidResult?

		databaseQueue.inDatabase { database in
			Log.info("[EventStore] Update events publisher.", log: .localData)

			let sql = """
				SELECT * FROM Event;
			"""

			do {
				let queryResult = try database.executeQuery(sql, values: [])
				var events = [Event]()

				while queryResult.next() {
					guard let id = queryResult.string(forColumn: "id"),
						  let description = queryResult.string(forColumn: "description"),
						  let address = queryResult.string(forColumn: "address"),
						  let signature = queryResult.string(forColumn: "signature") else {
						fatalError("[EventStore] SQL column is NOT NULL. Nil was not expected.")
					}

					let type = EventType(rawValue: Int(queryResult.int(forColumn: "type"))) ?? .type1
					let start = Date(timeIntervalSince1970: Double(queryResult.int(forColumn: "start")))
					let end = Date(timeIntervalSince1970: Double(queryResult.int(forColumn: "end")))
					let defaultCheckInLengthInMinutes = Int(queryResult.int(forColumn: "defaultCheckInLengthInMinutes"))

					let event = Event(
						id: id,
						type: type,
						description: description,
						address: address,
						start: start,
						end: end,
						defaultCheckInLengthInMinutes: defaultCheckInLengthInMinutes,
						signature: signature
					)

					events.append(event)
				}

				eventsPublisher.send(events)
			} catch {
				logLastErrorCode(from: database)
				result = .failure(dbError(from: database))
				return
			}

			result = .success(())
		}

		guard let _result = result else {
			fatalError("[EventStore] Result should not be nil.")
		}

		return _result
	}

	@discardableResult
	private func updateCheckins(with database: FMDatabase) -> EventStore.VoidResult {
		var result: EventStoring.VoidResult?

		databaseQueue.inDatabase { database in
			Log.info("[EventStore] Update checkins publisher.", log: .localData)

			let sql = """
				SELECT * FROM Checkin;
			"""

			do {
				let queryResult = try database.executeQuery(sql, values: [])
				var checkins = [Checkin]()

				while queryResult.next() {
					guard let eventId = queryResult.string(forColumn: "eventId"),
						  let eventDescription = queryResult.string(forColumn: "eventDescription"),
						  let eventAddress = queryResult.string(forColumn: "eventAddress"),
						  let eventSignature = queryResult.string(forColumn: "eventSignature") else {
						fatalError("[EventStore] SQL column is NOT NULL. Nil was not expected.")
					}

					let id = Int(queryResult.int(forColumn: "id"))
					let eventType = EventType(rawValue: Int(queryResult.int(forColumn: "eventType"))) ?? .type1
					let eventStart = Date(timeIntervalSince1970: Double(queryResult.int(forColumn: "eventStart")))
					let eventEnd = Date(timeIntervalSince1970: Double(queryResult.int(forColumn: "eventEnd")))
					let eventDefaultCheckInLengthInMinutes = Int(queryResult.int(forColumn: "eventDefaultCheckInLengthInMinutes"))
					let checkinStart = Date(timeIntervalSince1970: Double(queryResult.int(forColumn: "checkinStart")))
					let checkinEnd = Date(timeIntervalSince1970: Double(queryResult.int(forColumn: "checkinEnd")))

					let checkin = Checkin(
						id: id,
						eventId: eventId,
						eventType: eventType,
						eventDescription: eventDescription,
						eventAddress: eventAddress,
						eventStart: eventStart,
						eventEnd: eventEnd,
						eventDefaultCheckInLengthInMinutes: eventDefaultCheckInLengthInMinutes,
						eventSignature: eventSignature,
						checkinStart: checkinStart,
						checkinEnd: checkinEnd
					)

					checkins.append(checkin)
				}

				checkingPublisher.send(checkins)
			} catch {
				logLastErrorCode(from: database)
				result = .failure(dbError(from: database))
				return
			}

			result = .success(())
		}

		guard let _result = result else {
			fatalError("[EventStore] Result should not be nil.")
		}

		return _result
	}

	private func logLastErrorCode(from database: FMDatabase) {
		Log.error("[EventStore] (\(database.lastErrorCode())) \(database.lastErrorMessage())", log: .localData)
	}

	private func dbError(from database: FMDatabase) -> EventStoringError {
		let dbError = SQLiteErrorCode(rawValue: database.lastErrorCode()) ?? SQLiteErrorCode.unknown
		return .database(dbError)
	}
}
