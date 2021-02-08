//
// 🦠 Corona-Warn-App
//

import Foundation

extension Bundle {
	/// Read the Plist with the specified name as a `[String: String]` dictionary
	///
	/// - returns: Dictionary with `String` K/V pairs, nil if the plist was not found in the Bundle
	func readPlistDict(name: String) -> [String: String]? {
		guard
			let path = Bundle.main.path(forResource: name, ofType: "plist"),
			let xml = FileManager.default.contents(atPath: path),
			let plistDict = try? PropertyListSerialization.propertyList(from: xml, options: .mutableContainers, format: nil) as? [String: String]
		else {
			assertionFailure("could not parse \(name)")
			return nil
		}

		return plistDict
	}

	/// Read the Plist with the specified name as a `[String]` array
	///
	/// - returns:`String` Array of the plist contents
	func readPlistAsArr(name: String) -> [String]? {
		guard
			let path = Bundle.main.path(forResource: name, ofType: "plist"),
			let xml = FileManager.default.contents(atPath: path),
			let plistArr = try? PropertyListSerialization.propertyList(from: xml, options: .mutableContainers, format: nil) as? [String]
		else {
			assertionFailure("could not parse \(name)")
			return nil
		}

		return plistArr
	}
}
