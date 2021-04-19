//
// 🦠 Corona-Warn-App
//

import Foundation

/// This extension handles creating a key package directory and file clean up before new files get written to disk.
/// New keyfiles only get written just before a risk calculation is run and since this point of time is the safest to remove old keypackages that might gotten left behind.
/// Keyfiles could be left behind if the App gets killed during the risk calculation.
extension FileManager {
		
	// MARK: - Internal
	
	func createKeyPackageDirectory() throws-> URL {
		removeOldKeyPackages()
		
		let url = keyPackageURL().appendingPathComponent(UUID().uuidString, isDirectory: true)
		try createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
		Log.debug("Created: \(url)", log: .localData)
		return url
	}
	
	// MARK: - Private
	
	private func removeOldKeyPackages() {
		Log.debug("Removing \(keyPackageURL())", log: .localData)
		do {
			try removeItem(at: keyPackageURL()) // Delete the whole dir to make sure no old data is left behind
		} catch {
			Log.error("Error while removing: \(keyPackageURL()): \(error)", log: .localData)
		}
		removeOrphanedKeyPackages()
	}
		
	/// Deletes all *bin or *sig files inside the tmp directory of the appcontainer. The Riskcalculation has to write the keyfiles to disk and cleans them up
	/// under normal conditions. BUT if the  Riskcalculation is killed (watchdog or user force quits the app) thoose keyfiles can remain on Disk. This
	/// functions finds and removes old keyfiles.
	/// This has to be done since in versions < 1.8 just got written directly into the tmp directory.
	private func removeOrphanedKeyPackages() {
		Log.info("Starting to remove orphaned KeyPackages", log: .localData)
		let en = enumerator(at: temporaryDirectory, includingPropertiesForKeys: nil)
		while let elementURL = en?.nextObject() as? URL {
			if elementURL.absoluteString.hasSuffix("sig") || elementURL.absoluteString.hasSuffix("bin") {
				Log.debug("Removing: \(elementURL)", log: .localData)
				do {
					try removeItem(at: elementURL.deletingLastPathComponent())  // Remove the directory the file was contained in
				} catch {
					Log.error("Error while removing orphaned package: \(elementURL): \(error)", log: .localData)
				}
			}
		}
		Log.info("Finsihed removing orphaned KeyPackages", log: .localData)
		
	}

	private func keyPackageURL() -> URL {
		temporaryDirectory.appendingPathComponent("keypackages", isDirectory: true)
	}
}
