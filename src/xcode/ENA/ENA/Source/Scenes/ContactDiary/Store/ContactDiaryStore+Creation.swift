////
// 🦠 Corona-Warn-App
//

import FMDB

extension ContactDiaryStore {

	// MARK: - Internal

	static var storeURL: URL {
		storeDirectoryURL
			.appendingPathComponent("ContactDiary")
			.appendingPathExtension("sqlite")
	}

	static var storeDirectoryURL: URL {
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
	
	struct ContactDiaryStoreMakeResult {
		let store: ContactDiaryStore
		let error: SecureSQLStoreError?
	}

	static func make(url: URL? = nil, numberOfTries: Int = 1) -> ContactDiaryStoreMakeResult {
		Log.info("[ContactDiaryStore] Trying to create contact diary store...", log: .localData)

		let storeURL = url ?? ContactDiaryStore.storeURL

		guard let databaseQueue = FMDatabaseQueue(path: storeURL.path) else {
			Log.error("[ContactDiaryStore] Failed to create FMDatabaseQueue.", log: .localData)
			return ContactDiaryStoreMakeResult(
				store: ContactDiaryStore.recoverStore(storeURL: storeURL, numberOfTries: numberOfTries),
				error: .failedToCreateQueue
			)
		}

		let latestDBVersion = 5
		let schema = ContactDiaryStoreSchemaV5(
			databaseQueue: databaseQueue
		)

		let migrations: [Migration] = [
			ContactDiaryMigration1To2(databaseQueue: databaseQueue),
			ContactDiaryMigration2To3(databaseQueue: databaseQueue),
			ContactDiaryMigration3To4(databaseQueue: databaseQueue),
			ContactDiaryMigration4To5(databaseQueue: databaseQueue)
		]
		let migrator = SerialDatabaseQueueMigrator(
			queue: databaseQueue,
			latestVersion: latestDBVersion,
			migrations: migrations
		)

		let store = ContactDiaryStore(
			databaseQueue: databaseQueue,
			schema: schema,
			key: ContactDiaryStore.encryptionKey,
			migrator: migrator
		)
		
		if case .failure(let error) = store.openAndSetup() {
			Log.error("[ContactDiaryStore] Failed open and setup with error: \(error)", log: .localData)
			return ContactDiaryStoreMakeResult(
				store: ContactDiaryStore.recoverStore(storeURL: storeURL, numberOfTries: numberOfTries),
				error: error
			)
		}

		if case .failure(let error) = store.cleanup() {
			Log.error("[ContactDiaryStore] Failed cleanup with error: \(error)", log: .localData)
			return ContactDiaryStoreMakeResult(
				store: store,
				error: nil
			)
		}

		var updateDiaryResult: SecureSQLStore.VoidResult?
		store.databaseQueue.inDatabase { database in
			updateDiaryResult = store.updateDiaryDays(with: database)
		}
		if case .failure(let error) = updateDiaryResult {
			Log.error("[ContactDiaryStore] Failed updating entries with error: \(error)", log: .localData)
			return ContactDiaryStoreMakeResult(
				store: store,
				error: nil
			)
		}
		
		store.registerToDidBecomeActiveNotification()
		
		return ContactDiaryStoreMakeResult(
			store: store,
			error: nil
		)
	}

	// MARK: - Private

	private static func recoverStore(storeURL: URL, numberOfTries: Int) -> ContactDiaryStore {
		if numberOfTries == 0 {
			Log.info("[ContactDiaryStore] Failed to rescue contact diary store.", log: .localData)
			fatalError("[ContactDiaryStore] Could not create contact diary store after retrying.")
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

		return ContactDiaryStore.make(url: storeURL, numberOfTries: numberOfTries - 1).store
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
				key = try keychain.generateDatabaseKey(persistForKeychainKey: ContactDiaryStore.encryptionKeyKey)
			} catch {
				fatalError("[ContactDiaryStore] Failed to create key for contact diary store.")
			}
		}

		return key
	}
	
	static func resetEncryptionKey() throws -> String {
		guard let keychain = try? KeychainHelper() else {
			fatalError("[ContactDiaryStore] Failed to create KeychainHelper for contact diary store.")
		}
		try keychain.clearInKeychain(key: ContactDiaryStore.encryptionKeyKey)
		return encryptionKey
	}
}
