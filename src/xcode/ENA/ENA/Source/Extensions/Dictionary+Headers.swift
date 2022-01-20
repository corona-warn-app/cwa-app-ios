//
// 🦠 Corona-Warn-App
//

import Foundation

extension Dictionary {
	
	var dateHeader: Date? {
		if let dateString = value(caseInsensitiveKey: "Date") {
			return ENAFormatter.httpDateHeaderFormatter.date(from: dateString)
		} else {
			return nil
		}
	}
	
	
	func value(caseInsensitiveKey: String) -> String? {
		var headerValue: String?
		for (key, value) in self {
			if (key as? String)?.lowercased() == caseInsensitiveKey.lowercased() {
				headerValue = (value as? String)
			}
		}
		return headerValue
	}
}
