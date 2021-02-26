////
// 🦠 Corona-Warn-App
//

import UIKit
import ZIPFoundation

class LogDataItem: NSObject, UIActivityItemSource {

	let compressedData: NSData


	/// New `LogDataItem` from the given String
	/// - Parameter logString: the log String that represents this item
	init?(logString: String) {
		guard
			let archive = Archive(accessMode: .create),
			let rawData = logString.data(using: .utf8)
		else {
			Log.warning("No log data to export.", log: .localData)
			return nil
		}

		do {
			try archive.addEntry(with: "cwa-all-logs.txt", type: .file, uncompressedSize: UInt32(logString.count), compressionMethod: .deflate, bufferSize: 4, provider: { position, size -> Data in
				// This will be called until `data` is exhausted.
				return rawData.subdata(in: position..<position + size)
			})
			guard let compressed = archive.data else {
				Log.warning("Log compression failed for unknown reasons.", log: .localData)
				return nil
			}
			self.compressedData = compressed as NSData
		} catch {
			Log.error("Log export error", log: .localData, error: error)
			return nil
		}
	}

	/// New `LogDataItem` from file at given URL
	/// - Parameter url: The file url to read. The content represents this item
	init?(at url: URL) {
		guard
			let archive = Archive(accessMode: .create)
		else {
			Log.warning("No log data to export.", log: .localData)
			return nil
		}

		do {
			try archive.addEntry(with: url.lastPathComponent, relativeTo: url.deletingLastPathComponent(), compressionMethod: .deflate)

			guard let compressed = archive.data else {
				Log.warning("Log compression failed for unknown reasons.", log: .localData)
				return nil
			}
			self.compressedData = compressed as NSData
		} catch {
			Log.error("Log export error: \(error)", log: .localData, error: error)
			return nil
		}
	}

	// MARK: - UIActivityItemSource

	func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
		// Here the type is important, not the content
		return "CWA Log"
	}

	func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
		do {
			let temporaryURL = URL(fileURLWithPath: NSTemporaryDirectory().appending("cwa-log.zip"))
			try compressedData.write(to: temporaryURL, options: [])
			return temporaryURL
		} catch {
			Log.error("", log: .localData, error: error)
			return nil
		}
	}

	func activityViewController(_ activityViewController: UIActivityViewController, dataTypeIdentifierForActivityType activityType: UIActivity.ActivityType?) -> String {
		return "de.rki.coronawarnapp.log"
	}

	func activityViewController(_ activityViewController: UIActivityViewController, thumbnailImageForActivityType activityType: UIActivity.ActivityType?, suggestedSize size: CGSize) -> UIImage? {
		return UIImage(named: "Icons_CWAAppIcon")
	}

}
