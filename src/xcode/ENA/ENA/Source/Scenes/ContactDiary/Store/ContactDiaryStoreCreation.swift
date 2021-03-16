////
// 🦠 Corona-Warn-App
//

import FMDB

extension ContactDiaryStore {

	// MARK: - Init

	convenience init?(url: URL) {

		guard let databaseQueue = FMDatabaseQueue(path: url.path) else {
			Log.error("[ContactDiaryStore] Failed to create FMDatabaseQueue.", log: .localData)
			return nil
		}

		let latestDBVersion = 4
		let schema = ContactDiaryStoreSchemaV4(
			databaseQueue: databaseQueue
		)

		let migrations: [Migration] = [
			ContactDiaryMigration1To2(databaseQueue: databaseQueue),
			ContactDiaryMigration2To3(databaseQueue: databaseQueue),
			ContactDiaryMigration3To4(databaseQueue: databaseQueue)
		]
		let migrator = SerialDatabaseQueueMigrator(
			queue: databaseQueue,
			latestVersion: latestDBVersion,
			migrations: migrations
		)

		self.init(
			databaseQueue: databaseQueue,
			schema: schema,
			key: ContactDiaryStore.encryptionKey,
			migrator: migrator
		)
	}

	// MARK: - Internal

	static func make(url: URL? = nil) -> ContactDiaryStore {
		let storeURL: URL

		if let url = url {
			storeURL = url
		} else {
			storeURL = ContactDiaryStore.storeURL
		}

		Log.info("[ContactDiaryStore] Trying to create contact diary store...", log: .localData)

		if let store = ContactDiaryStore(url: storeURL) {
			Log.info("[ContactDiaryStore] Successfully created contact diary store", log: .localData)
			return store
		}

		Log.info("[ContactDiaryStore] Failed to create contact diary store. Try to rescue it...", log: .localData)

		// The database could not be created – To the rescue!
		// Remove the database file and try to init the store a second time.
		do {
			try FileManager.default.removeItem(at: storeURL)
		} catch {
			Log.error("Could not remove item at \(ContactDiaryStore.storeDirectoryURL)", log: .localData, error: error)
			assertionFailure()
		}

		if let secondTryStore = ContactDiaryStore(url: storeURL) {
			Log.info("[ContactDiaryStore] Successfully rescued contact diary store", log: .localData)
			return secondTryStore
		} else {
			Log.info("[ContactDiaryStore] Failed to rescue contact diary store.", log: .localData)
			fatalError("[ContactDiaryStore] Could not create contact diary store after second try.")
		}
	}

	// MARK: - Private

	private static var storeURL: URL {
		storeDirectoryURL
			.appendingPathComponent("ContactDiary")
			.appendingPathExtension("sqlite")
	}

	private static var storeDirectoryURL: URL {
		let fileManager = FileManager.default

		guard let storeDirectoryURL = try? fileManager
			.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
				.appendingPathComponent("ContactDiary") else {
			fatalError("[ContactDiaryStore] Could not create folder.")
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
			fatalError("[ContactDiaryStore] Failed to create KeychainHelper for contact diary store.")
		}

		let key: String
		if let keyData = keychain.loadFromKeychain(key: ContactDiaryStore.encryptionKeyKey) {
			key = String(decoding: keyData, as: UTF8.self)
		} else {
			do {
				key = try keychain.generateContactDiaryDatabaseKey()
			} catch {
				fatalError("[ContactDiaryStore] Failed to create key for contact diary store.")
			}
		}

		return key
	}
}
