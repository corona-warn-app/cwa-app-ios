////
// 🦠 Corona-Warn-App
//

import Foundation

extension FileManager {

	/// Fetched the file size at a given path if a file exists
	/// - Parameter path: The file path to check
	/// - Returns: The size of the file in bytes; returns nil if no file exists or any other errors occur
	func sizeOfFile(atPath path: String) -> Int64? {
		guard let attrs = try? attributesOfItem(atPath: path) else {
			return nil
		}
		return attrs[.size] as? Int64
	}
}
