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
//

import Foundation
import UIKit

class PrivacyPolicyViewController: UIViewController {
	private var textView: HtmlTextView! { view as? HtmlTextView }

	override func loadView() {
		view = HtmlTextView()
		view.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		navigationItem.largeTitleDisplayMode = .always
		navigationItem.title = AppStrings.PrivacyPolicy.navigationTitle

		textView.delegate = self

		if let url = Bundle.main.url(forResource: "privacy-policy", withExtension: ".html") {
			textView.load(from: url)
		}
	}
}

extension PrivacyPolicyViewController: UITextViewDelegate {
	func textView(_ textView: UITextView, shouldInteractWith url: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
		WebPageHelper.openSafari(withUrl: url, from: self)
		return false
	}
}
