////
// 🦠 Corona-Warn-App
//

import FMDB

extension EventStore {

	convenience init?(url: URL) {

		guard let databaseQueue = FMDatabaseQueue(path: url.path) else {
			Log.error("[EventStore] Failed to create FMDatabaseQueue.", log: .localData)
			return nil
		}

		let latestDBVersion = 1
		let schema = EventStoreSchemaV1(
			databaseQueue: databaseQueue
		)

		let migrations: [Migration] = []
		let migrator = SerialDatabaseQueueMigrator(
			queue: databaseQueue,
			latestVersion: latestDBVersion,
			migrations: migrations
		)

		self.init(
			databaseQueue: databaseQueue,
			schema: schema,
			key: EventStore.encryptionKey,
			migrator: migrator
		)
	}

	static func make(url: URL? = nil) -> EventStore {
		let storeURL: URL

		if let url = url {
			storeURL = url
		} else {
			storeURL = EventStore.storeURL
		}

		Log.info("[EventStore] Trying to create event store...", log: .localData)

		if let store = EventStore(url: storeURL) {
			Log.info("[EventStore] Successfully created event store", log: .localData)
			return store
		}

		Log.info("[EventStore] Failed to create event store. Try to rescue it...", log: .localData)

		// The database could not be created – To the rescue!
		// Remove the database file and try to init the store a second time.
		do {
			try FileManager.default.removeItem(at: storeURL)
		} catch {
			Log.error("Could not remove item at \(EventStore.storeDirectoryURL)", log: .localData, error: error)
			assertionFailure()
		}

		if let secondTryStore = EventStore(url: storeURL) {
			Log.info("[EventStore] Successfully rescued event store", log: .localData)
			return secondTryStore
		} else {
			Log.info("[EventStore] Failed to rescue event store.", log: .localData)
			fatalError("[EventStore] Could not create event store after second try.")
		}
	}

	private static var storeURL: URL {
		storeDirectoryURL
			.appendingPathComponent("EventStore")
			.appendingPathExtension("sqlite")
	}

	private static var storeDirectoryURL: URL {
		let fileManager = FileManager.default

		guard let storeDirectoryURL = try? fileManager
				.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
				.appendingPathComponent("EventStore") else {
			fatalError("[EventStore] Could not create folder.")
		}

		if !fileManager.fileExists(atPath: storeDirectoryURL.path) {
			do {
				try fileManager.createDirectory(atPath: storeDirectoryURL.path, withIntermediateDirectories: true, attributes: nil)
			} catch {
				Log.error("Could not create directory at \(storeDirectoryURL)", log: .localData, error: error)
				assertionFailure()
			}
		}
		return storeDirectoryURL
	}

	private static var encryptionKey: String {
		guard let keychain = try? KeychainHelper() else {
			fatalError("[EventStore] Failed to create KeychainHelper for event store.")
		}

		let key: String
		if let keyData = keychain.loadFromKeychain(key: EventStore.encryptionKeyKey) {
			key = String(decoding: keyData, as: UTF8.self)
		} else {
			do {
				key = try keychain.generateEventDatabaseKey()
			} catch {
				fatalError("[EventStore] Failed to create key for event store.")
			}
		}

		return key
	}
}
