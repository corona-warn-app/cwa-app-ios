//
// 🦠 Corona-Warn-App
//

import Foundation

protocol KeyValueCaching {
	subscript(cacheEntryKey: String) -> CacheData? { get set }
}

final class SecureKeyValueCache: SecureKeyValueStoring, KeyValueCaching {

	// MARK: - Init
	
	init(
		at directoryURL: URL,
		key: String
	) throws {
		self.directoryURL = directoryURL
		self.kvStore = try SQLiteKeyValueStore(with: directoryURL, key: key)
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
