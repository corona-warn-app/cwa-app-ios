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

class HtmlTextView: UITextView {
	private var html: String?

	override var layoutMargins: UIEdgeInsets { didSet { textContainerInset = layoutMargins } }

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setup()
	}

	override init(frame: CGRect, textContainer: NSTextContainer?) {
		super.init(frame: frame, textContainer: textContainer)
		setup()
	}
	
	private func setup() {
		isScrollEnabled = false
		backgroundColor = nil
		adjustsFontForContentSizeCategory = true
		font = .enaFont(for: .body)
		textColor = .enaColor(for: .textPrimary1)
		textContainer.lineFragmentPadding = .zero

		linkTextAttributes = [
			NSAttributedString.Key.foregroundColor: UIColor.enaColor(for: .textTint)
		]

		isEditable = false
	}
}

extension HtmlTextView {
	func load(from url: URL) {
		if var html = try? loadHtml(from: url) {
			self.html = html
			html = applyColors(to: html)
			if let attributedText = try? parseHtml(html) {
				let mutableAttributedText = NSMutableAttributedString(attributedString: attributedText)
				mutableAttributedText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.enaColor(for: .textPrimary1), range: NSRange(location: 0, length: attributedText.length))
				self.attributedText = mutableAttributedText
			}
		} else {
			logError(message: "HTML resource could not be loaded: \(url)")
		}
	}

	private func loadHtml(from url: URL) throws -> String? {
		let data = try Data(contentsOf: url)
		return String(data: data, encoding: .utf8)
	}

	private func applyColors(to html: String) -> String {
		guard let regex = try? NSRegularExpression(pattern: "--ena-([0-9a-z-]+)-color:\\s*(#[0-9a-z]{3,8})\\s*;", options: [.caseInsensitive]) else { return html }

		let mutableHtml = NSMutableString(string: html)

		for match in regex.matches(in: mutableHtml as String, range: .init(location: 0, length: mutableHtml.length)).reversed() {
			let colorName = mutableHtml.substring(with: match.range(at: 1))

			if let enaColor = ENAColor.allCases.first(where: { $0.cssName == colorName }) {
				mutableHtml.replaceCharacters(in: match.range(at: 2), with: "#\(UIColor.enaColor(for: enaColor).rgbaHex)")
			}
		}

		return mutableHtml as String
	}

	private func parseHtml(_ html: String) throws -> NSAttributedString? {
		let mutableAttributedText = try NSMutableAttributedString(
			data: Data(html.utf8),
			options: [
				.documentType: NSAttributedString.DocumentType.html,
				.characterEncoding: String.Encoding.utf8.rawValue
			],
			documentAttributes: nil
		)
		let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
		paragraphStyle.alignment = NSTextAlignment.natural
		mutableAttributedText.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: mutableAttributedText.length))
		return mutableAttributedText
	}
}


private extension ENAColor {
	var cssName: String {
		switch self {
		// MARK: - Background Colors
		case .background: return "background"
		case .hairline: return "hairline"
		case .hairlineContrast: return "hairline-contrast"
		case .separator: return "separator"

		// MARK: - Brand Colors
		case .brandBlue: return "brand-blue"
		case .brandBurgundy: return "brand-burgundy"
		case .brandRed: return "brand-red"

		// MARK: - Button Colors
		case .buttonDestructive: return "button-destructive"
		case .buttonHighlight: return "button-highlight"
		case .buttonPrimary: return "button-primary"

		// MARK: - Miscellaneous Colors
		case .chevron: return "chevron-color"
		case .shadow: return "shadow-color"
		case .tint: return "tint-color"

		// MARK: - Risk Colors
		case .riskHigh: return "Risk-high"
		case .riskLow: return "risk-low"
		case .riskMedium: return "risk-medium"
		case .riskNeutral: return "risk-neutral"

		// MARK: - Tap States Colors
		case .listHighlight: return "list-highlight"

		// MARK: - Text Colors
		case .textContrast: return "text-contrast"
		case .textPrimary1: return "text-primary-1"
		case .textPrimary1Contrast: return "text-primary-1-contrast"
		case .textPrimary2: return "text-primary-2"
		case .textPrimary3: return "text-primary-3"
		case .textSemanticGray: return "text-semantic-gray"
		case .textSemanticGreen: return "text-semantic-green"
		case .textSemanticRed: return "text-semantic-red"
		case .textTint: return "text-tint"
		}
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
