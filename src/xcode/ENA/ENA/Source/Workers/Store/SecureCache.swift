//
// 🦠 Corona-Warn-App
//

import Foundation

struct CacheData: Codable {
	let data: Data
	let eTag: String
	let date: Date

	static func fake(
		data: Data = Data(),
		eTag: String = "",
		date: Date = Date()
	) -> CacheData {
		return CacheData(
			data: data,
			eTag: eTag,
			date: date
		)
	}
}

protocol KeyValueCaching {
	subscript(cacheEntryKey: Int) -> CacheData? { get set }
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

	private var cache: [Int: CacheData] {
		get { kvStore["cache"] as [Int: CacheData]? ?? [Int: CacheData]() }
		set { kvStore["cache"] = newValue }
	}

	// MARK: - KeyValueCaching

	subscript(cacheEntryKey: Int) -> CacheData? {
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

	private var cache = [Int: CacheData]()

	// MARK: - KeyValueCaching

	subscript(cacheEntryKey: Int) -> CacheData? {
		get {
			return cache[cacheEntryKey]
		}
		set {
			cache[cacheEntryKey] = newValue
		}
	}
}

#endif
