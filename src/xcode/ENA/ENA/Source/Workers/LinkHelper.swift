//
// 🦠 Corona-Warn-App
//

import Foundation
import SafariServices
import UIKit

enum LinkHelper {
	static func showWebPage(from viewController: UIViewController, urlString: String) {
		if let url = URL(string: urlString) {
			openLink(withUrl: url, from: viewController)
		} else {
			let error = "\(urlString) is no valid URL"
			Log.error(error, log: .api)
			fatalError(error)
		}
	}

	static func open(withUrl url: URL, from viewController: UIViewController) {
		switch url.scheme {
		case "tel", "mailto":
			UIApplication.shared.open(url, options: [:], completionHandler: nil)
		default:
			openLink(withUrl: url, from: viewController)
		}
	}

	static func openLink(withUrl url: URL, from viewController: UIViewController) {
		let config = SFSafariViewController.Configuration()
		config.entersReaderIfAvailable = false
		config.barCollapsingEnabled = true

		let vc = SFSafariViewController(url: url, configuration: config)
		vc.preferredControlTintColor = .enaColor(for: .tint)

		viewController.present(vc, animated: true)
	}
}
