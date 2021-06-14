//
// 🦠 Corona-Warn-App
//

import UIKit

enum LinkHelper {
	
	typealias Success = Bool
	
	@discardableResult
	static func open(urlString: String) -> Success {
		if let url = URL(string: urlString) {
			return open(url: url)
		} else {
			let error = "\(urlString) is no valid URL"
			Log.error(error, log: .api)
			fatalError(error)
		}
	}
	
	@discardableResult
	static func open(url: URL) -> Success {
		guard UIApplication.shared.canOpenURL(url) else {
			Log.error("Cannot open url \(url.absoluteString)", log: .api)
			return false
		}
		UIApplication.shared.open(url, options: [:], completionHandler: nil)
		return true
	}
}
