//
// 🦠 Corona-Warn-App
//

protocol SecureKeyValueStoring {

	static var encryptionKeyKeychainKey: String { get }
	var kvStore: SQLiteKeyValueStore { get }
	var directoryURL: URL { get }

	init(
		at directoryURL: URL,
		key: String,
		store: KeyValueCacheStoring?
	) throws

}

extension SecureKeyValueStoring {

	init(subDirectory: String, store: KeyValueCacheStoring? = nil) {
		self.init(subDirectory: subDirectory, isRetry: false, store: store)
	}

	private init(subDirectory: String, isRetry: Bool, store: KeyValueCacheStoring?) {
		do {
			let keychain = try KeychainHelper()
			let directoryURL = try Self.databaseDirectory(at: subDirectory)
			let fileManager = FileManager.default
			if fileManager.fileExists(atPath: directoryURL.path) {
				// fetch existing key from keychain or generate a new one
				let key: String
				if let keyData = keychain.loadFromKeychain(key: Self.encryptionKeyKeychainKey) {
					#if DEBUG
					if isUITesting, ProcessInfo.processInfo.arguments.contains(UITestingParameters.SecureStoreHandling.simulateMismatchingKey.rawValue) {
						// injecting a wrong key to simulate a mismatch, e.g. because of backup restoration or other reasons
						key = "wrong 🔑"
						try self.init(at: directoryURL, key: key, store: store)
						return
					}
					#endif

					key = String(decoding: keyData, as: UTF8.self)
				} else {
					key = try keychain.generateDatabaseKey(persistForKeychainKey: Self.encryptionKeyKeychainKey)
				}
				try self.init(at: directoryURL, key: key, store: store)
			} else {
				try fileManager.createDirectory(atPath: directoryURL.path, withIntermediateDirectories: true, attributes: nil)
				let key = try keychain.generateDatabaseKey(persistForKeychainKey: Self.encryptionKeyKeychainKey)
				try self.init(at: directoryURL, key: key, store: store)
			}
		} catch is SQLiteStoreError where isRetry == false {
			Self.performHardDatabaseReset(at: subDirectory)
			self.init(subDirectory: subDirectory, isRetry: true, store: store)
		} catch {
			fatalError("Creating the Database failed (\(error)")
		}
	}

	private static func databaseDirectory(at subDirectory: String) throws -> URL {
		try FileManager.default
			.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
			.appendingPathComponent(subDirectory)
	}

	/// Last Resort option.
	///
	/// This function clears the existing database key and removes any existing databases.
	private static func performHardDatabaseReset(at path: String) {
		do {
			Log.info("⚠️ performing hard database reset ⚠️", log: .localData)
			// remove database key
			try KeychainHelper().clearInKeychain(key: Self.encryptionKeyKeychainKey)

			// remove database
			let directoryURL = try databaseDirectory(at: path)
			try FileManager.default.removeItem(at: directoryURL)
		} catch {
			fatalError("Reset failure: \(error.localizedDescription)")
		}
	}

}
