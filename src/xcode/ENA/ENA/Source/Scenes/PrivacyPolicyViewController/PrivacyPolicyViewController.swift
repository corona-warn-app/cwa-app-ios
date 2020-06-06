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
	private var textView: UITextView! { view as? UITextView }

	override func loadView() {
		view = UITextView()

		textView.font = .preferredFont(forTextStyle: .body)
		textView.adjustsFontForContentSizeCategory = true
		textView.textContainer.lineFragmentPadding = .zero
		textView.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

		textView.linkTextAttributes = [
			NSAttributedString.Key.foregroundColor: UIColor.enaColor(for: .textTint)
		]

		textView.isEditable = false
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		navigationItem.largeTitleDisplayMode = .always
		navigationItem.title = AppStrings.PrivacyPolicy.navigationTitle

		textView.delegate = self

		updateTextView()
	}

	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)

		DispatchQueue.main.async(execute: updateTextView)
	}
}

extension PrivacyPolicyViewController: UITextViewDelegate {
	func textView(_ textView: UITextView, shouldInteractWith url: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
		WebPageHelper.openSafari(withUrl: url, from: self)
		return false
	}
}

extension PrivacyPolicyViewController {
	private func updateTextView() {
		if let url = Bundle.main.url(forResource: "privacy-policy", withExtension: ".html"),
			let html = try? loadHtml(url: url) {
			textView.attributedText = try? parseHtml(html: html)
		} else {
			logError(message: "Privacy Policy could not be loaded.")
		}
	}

	private func loadHtml(url: URL) throws -> String? {
		let data = try Data(contentsOf: url)

		if var html = String(data: data, encoding: .utf8) {
			if let regex = try? NSRegularExpression(pattern: "--ena-([0-9a-z-]+)-color:\\s*(#[0-9a-z]{6});", options: [.caseInsensitive]) {
				let mutableHtml = NSMutableString(string: html)

				for match in regex.matches(in: mutableHtml as String, range: .init(location: 0, length: mutableHtml.length)).reversed() {
					let color: UIColor?
					switch mutableHtml.substring(with: match.range(at: 1)) {
					case "text-primary-1": color = .enaColor(for: .textPrimary1)
					case "text-tint": color = .enaColor(for: .textTint)
					default: color = nil
					}

					if let color = color {
						mutableHtml.replaceCharacters(in: match.range(at: 2), with: "#\(color.rgbaHex)")
					}
				}

				html = mutableHtml as String
			}

			return html
		} else {
			return nil
		}
	}

	private func parseHtml(html: String) throws -> NSAttributedString? {
		guard let data = html.data(using: .utf8) else { return nil }

		return try NSAttributedString(
			data: data,
			options: [
				.documentType: NSAttributedString.DocumentType.html,
				.characterEncoding: String.Encoding.utf8.rawValue
			],
			documentAttributes: nil
		)
	}
}

private extension UIColor {
	var red: CGFloat { cgColor.components?[0] ?? 0 }
	var green: CGFloat { cgColor.components?[1] ?? 0 }
	var blue: CGFloat { cgColor.components?[2] ?? 0 }

	var rgb: UInt32 { UInt32(red * 255) << 16 | UInt32(green * 255) << 8 | UInt32(blue * 255) }
	var rgba: UInt32 { rgb << 8 | UInt32(self.cgColor.alpha * 255) }
	var rgbaHex: String { String(format: "%08X", rgba) }
}
