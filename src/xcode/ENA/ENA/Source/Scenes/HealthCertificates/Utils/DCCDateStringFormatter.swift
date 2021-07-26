////
// 🦠 Corona-Warn-App
//

import Foundation

enum DCCDateStringFormatter {

	static func formattedString(from string: String) -> String {
		return string.components(separatedBy: "T").first ?? string
	}

	static func localizedFormattedString(from string: String) -> String {
		let formattedString = Self.formattedString(from: string)

		let inputDateFormatter = DateFormatter()
		inputDateFormatter.calendar = Calendar(identifier: .gregorian)

		let outputDateFormatter = DateFormatter()
		outputDateFormatter.locale = Locale.current

		inputDateFormatter.dateFormat = "yyyy-MM-dd"
		if let date = inputDateFormatter.date(from: formattedString) {
			outputDateFormatter.setLocalizedDateFormatFromTemplate("yyyyMMdd")
			return outputDateFormatter.string(from: date)
		}

		inputDateFormatter.dateFormat = "yyyy-MM"
		if let date = inputDateFormatter.date(from: formattedString) {
			outputDateFormatter.setLocalizedDateFormatFromTemplate("yyyyMM")
			return outputDateFormatter.string(from: date)
		}

		inputDateFormatter.dateFormat = "yyyy"
		if let date = inputDateFormatter.date(from: formattedString) {
			outputDateFormatter.setLocalizedDateFormatFromTemplate("yyyy")
			return outputDateFormatter.string(from: date)
		}

		return formattedString
	}

}
