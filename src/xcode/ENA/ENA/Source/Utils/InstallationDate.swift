////
// 🦠 Corona-Warn-App
//

import Foundation

enum InstallationDate {

	static func inferredFromDocumentDirectoryCreationDate() -> Date {
		guard
			let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last,
			let attributes = try? FileManager.default.attributesOfItem(atPath: documentsURL.path)
		else {
			return Date()
		}
		return attributes[.creationDate] as? Date ?? Date()
	}
}
