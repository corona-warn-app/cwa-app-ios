////
// 🦠 Corona-Warn-App
//

import Foundation

enum DCCDateStringFormatter {

	static func formatedString(from string: String) -> String {
		return string.components(separatedBy: "T").first ?? string
	}
}
