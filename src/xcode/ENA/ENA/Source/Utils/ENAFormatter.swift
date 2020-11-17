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
}
