//
// 🦠 Corona-Warn-App
//

import Foundation
import jsonlogic

class SerialSecureCacheMigrator: SerialMigratorProtocol {

	private let latestVersion: Int
	private let migrations: [Migration]
	private let store: KeyValueCacheStoring

	init(
		latestVersion: Int,
		migrations: [Migration],
		store: KeyValueCacheStoring
	) {
		self.latestVersion = latestVersion
		self.migrations = migrations
		self.store = store
	}

	func migrate() throws {
		if store.keyValueCacheVersion < latestVersion {
			do {
				let nextVersion = store.keyValueCacheVersion + 1
				let migration = migrations.first { $0.version == nextVersion }
				try migration?.execute()
				store.keyValueCacheVersion = nextVersion
				try migrate()
			} catch {
				Log.error("Migration of KeyValueCachingStore failed from version \(store.keyValueCacheVersion) to version \(store.keyValueCacheVersion.advanced(by: 1))")
				throw error
			}
		} else {
			Log.info("No migration of KeyValueCachingStore needed", log: .localData)
		}
	}

}

final class SecureKeyValueCacheMigrationTo1: Migration {

	init(
		kvStore: SQLiteKeyValueStore
	) {
		self.kvStore = kvStore
	}

	let version = 1

	func execute() throws {
		do {
			let keychain = try KeychainHelper()
			let key = try keychain.generateDatabaseKey(persistForKeychainKey: SecureKeyValueCache.encryptionKeyKeychainKey)
			try kvStore.wipeAll(key: key)
		} catch {
			Log.error("Failed SerialSecureCachingMigrationTo1", error: error)
			throw error
		}
	}

	private let kvStore: SQLiteKeyValueStore

}
