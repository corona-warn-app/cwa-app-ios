////
// 🦠 Corona-Warn-App
//

import UIKit

class DiaryExportItem: NSObject, UIActivityItemSource {

	// MARK: - Init
	
	init(subject: String, body: String) {
		self.subject = subject
		self.body = body
	}
	
	// MARK: - Protocol UIActivityItemSource
	
	func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
		return ""
	}
	
	func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
		return body
	}
	
	func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
		guard let activityType = activityType else {
			return ""
		}
		switch activityType {
		case .mail:
			return subject
		default:
			return ""
		}
	}
	
	// MARK: - Private
	
	private let subject: String
	private let body: String
}
