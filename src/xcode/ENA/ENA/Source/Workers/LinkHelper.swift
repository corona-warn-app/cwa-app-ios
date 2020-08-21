//
// Corona-Warn-App
//
// SAP SE and all other contributors
// copyright owners license this file to you under the Apache
// License, Version 2.0 (the "License"); you may not use this
// file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import Foundation
import SafariServices
import UIKit

enum LinkHelper {
	static func showWebPage(from viewController: UIViewController, urlString: String) {
		if let url = URL(string: urlString) {
			openLink(withUrl: url, from: viewController)
		} else {
			let error = "\(urlString) is no valid URL"
			logError(message: error)
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
		config.entersReaderIfAvailable = true
		config.barCollapsingEnabled = true

		let vc = SFSafariViewController(url: url, configuration: config)
		vc.preferredControlTintColor = .enaColor(for: .tint)

		viewController.present(vc, animated: true)
	}
}
