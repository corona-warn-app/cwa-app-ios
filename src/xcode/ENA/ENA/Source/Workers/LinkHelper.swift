//
// 🦠 Corona-Warn-App
//

import UIKit

enum LinkHelper {
	
	typealias Success = Bool
	
	enum Result {
		case done
		case error
		case allow
	}
	
	enum LinkType {
		case faq
	}

	@discardableResult
	static func open(urlString: String) -> Success {
		if let url = URL(string: urlString) {
			return open(url: url) == .done
		} else {
			let error = "\(urlString) is no valid URL"
			Log.error(error, log: .api)
			fatalError(error)
		}
	}
	
	@discardableResult
	static func open(url: URL, interaction: UITextItemInteraction = .invokeDefaultAction) -> Result {
		#if DEBUG
		if isUITesting {
			showAlert(url: url)
			return .done
		}
		#endif
		guard interaction == .invokeDefaultAction else {
			return .allow
		}
		guard UIApplication.shared.canOpenURL(url) else {
			Log.error("Cannot open url \(url.absoluteString)", log: .api)
			return .error
		}
		UIApplication.shared.open(url, options: [:], completionHandler: nil)
		return .done
	}
	
	static func urlString(suffix: String, type: LinkType) -> String {
		switch type {
		case .faq:
			return AppStrings.Links.appFaqAnchor + suffix
		}
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
