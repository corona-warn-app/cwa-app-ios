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
		#if DEBUG
		if isUITesting {
			showAlert(url: url)
			return true
		}
		#endif
		guard UIApplication.shared.canOpenURL(url) else {
			Log.error("Cannot open url \(url.absoluteString)", log: .api)
			return false
		}
		UIApplication.shared.open(url, options: [:], completionHandler: nil)
		return true
	}
	
	#if DEBUG
	private static func showAlert(url: URL) {
		let alert = UIAlertController(title: nil, message: url.absoluteString, preferredStyle: .alert)
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
		alert.addAction(cancelAction)
		
		if var topController = UIApplication.shared.keyWindow?.rootViewController {
			  while let presentedViewController = topController.presentedViewController {
					topController = presentedViewController
				   }
			topController.present(alert, animated: false, completion: nil)
		}
	}
	#endif
}
