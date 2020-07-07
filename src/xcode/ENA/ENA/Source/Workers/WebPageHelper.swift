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

enum WebPageHelper {
	static func showWebPage(from viewController: UIViewController, urlString: String) {
		if let url = URL(string: urlString) {
			let config = SFSafariViewController.Configuration()
			config.entersReaderIfAvailable = true
			config.barCollapsingEnabled = true

			let vc = SFSafariViewController(url: url, configuration: config)
			vc.preferredControlTintColor = .enaColor(for: .tint)
			viewController.present(vc, animated: true)
		} else {
			let error = "\(urlString) is no valid URL"
			logError(message: error)
			fatalError(error)
		}
	}

	static func openSafari(withUrl url: URL, from viewController: UIViewController) {
		let config = SFSafariViewController.Configuration()
		config.entersReaderIfAvailable = true
		config.barCollapsingEnabled = true

		let vc = SFSafariViewController(url: url, configuration: config)
		vc.preferredControlTintColor = .enaColor(for: .tint)

		viewController.present(vc, animated: true)
	}
}
