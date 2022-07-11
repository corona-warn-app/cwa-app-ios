//
// 🦠 Corona-Warn-App
//

import Foundation

 extension FileManager {
	func clearTemporaryDirectory() {
		do {
			let temporaryDirectoryURL = FileManager.default.temporaryDirectory
			let temporaryDirectory = try FileManager.default.contentsOfDirectory(atPath: temporaryDirectoryURL.path)
			try temporaryDirectory.forEach { file in
				if file.contains(".pdf") {
					let fileUrl = temporaryDirectoryURL.appendingPathComponent(file)
					try FileManager.default.removeItem(atPath: fileUrl.path)
				}
			}
		} catch {
			Log.error("Unable to delete the pdf file")
		}
	}
 }
