////
// 🦠 Corona-Warn-App
//

import Foundation


enum DataConversionError: Error {
	case stringToDataFailed
}

extension Data {
	public mutating func append(_ newElement: String) throws {
		guard let data = newElement.data(using: .utf8) else {
			// better this than failing silently
			throw DataConversionError.stringToDataFailed
		}

		append(data)
	}
}
