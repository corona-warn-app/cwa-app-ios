//
// 🦠 Corona-Warn-App
//

import UIKit
import WebKit

final class HTMLView: WKWebView {

	enum WebViewError: Error {
		case cannotLoad
	}

	private var htmlURL: URL!

	override init(frame: CGRect, configuration: WKWebViewConfiguration) {
		super.init(frame: frame, configuration: configuration)
		setup()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setup()
	}

	private func setup() {
		backgroundColor = nil
	}

	func load(from url: URL) throws {
		let request = URLRequest(url: url)
		guard let navigation = load(request) else {
			throw WebViewError.cannotLoad
		}
		dump(navigation)

//		if var html = try loadHtml(from: url) {
//			self.html = html
//			html = applyColors(to: html)
//			if let attributedText = try parseHtml(html) {
//				let mutableAttributedText = NSMutableAttributedString(attributedString: attributedText)
//				mutableAttributedText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.enaColor(for: .textPrimary1), range: NSRange(location: 0, length: attributedText.length))
//				self.attributedText = mutableAttributedText
//			}
//		} else {
//			Log.error("HTML resource could not be loaded: \(url)", log: .api)
//		}
	}

}
