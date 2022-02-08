//
// 🦠 Corona-Warn-App
//

import Foundation

protocol KeyValueCaching {
	subscript(cacheEntryKey: String) -> CacheData? { get set }
}

final class SecureKeyValueCache: SecureKeyValueStoring, KeyValueCaching {

	// MARK: - Init

	init(at directoryURL: URL, key: String) throws {
		self.directoryURL = directoryURL
		self.kvStore = try SQLiteKeyValueStore(with: directoryURL, key: key)
	}

	convenience init(
		at directoryURL: URL,
		key: String,
		store: KeyValueCacheStoring? = nil
	) throws {
		try self.init(at: directoryURL, key: key)

		guard let store = store else {
			Log.error("Migration only possible with KeyValueCacheStoring")
			return
		}

		// Migration
		let latestVersion = 1

		let migrator = SerialSecureCacheMigrator(
			latestVersion: latestVersion,
			migrations: [
				SecureKeyValueCacheMigrationTo1(kvStore: kvStore)
			],
			store: store
		)

		do {
			try migrator.migrate()
		} catch {
			Log.error("Migration throws am error", error: error)
		}
	}

	// MARK: - Internal

	// MARK: - SecureKeyValueStoring

	static let encryptionKeyKeychainKey = "secureCacheDatabaseKey"
	let kvStore: SQLiteKeyValueStore
	let directoryURL: URL

	// MARK: - Private

	private var cache: [String: CacheData] {
		get { kvStore["cache"] as [String: CacheData]? ?? [String: CacheData]() }
		set { kvStore["cache"] = newValue }
	}

	// MARK: - KeyValueCaching

	subscript(cacheEntryKey: String) -> CacheData? {
		get {
			return cache[cacheEntryKey]
		}
		set {
			cache[cacheEntryKey] = newValue
		}
	}
}

#if !RELEASE

final class KeyValueCacheFake: KeyValueCaching {

	// MARK: - Private

	private var cache = [String: CacheData]()

	// MARK: - KeyValueCaching

	subscript(cacheEntryKey: String) -> CacheData? {
		get {
			return cache[cacheEntryKey]
		}
		set {
			cache[cacheEntryKey] = newValue
		}
	}
}

#endif
