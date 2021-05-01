//
// 🦠 Corona-Warn-App
//

import Foundation

enum ENAFormatter {

	static let httpDateHeaderFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.locale = Locale(identifier: "us_US")
		dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"
		return dateFormatter
	}()
	
	static func getDateTimeString(date: Date) -> String {
		let dateFormatter = DateFormatter()
		dateFormatter.dateStyle = .long
		dateFormatter.timeStyle = .short
		let target = Locale.autoupdatingCurrent
		dateFormatter.locale = target
		
		guard let dateTimeString = dateFormatter.string(for: date) else {
			return ""
		}
		return dateTimeString
	}
}
