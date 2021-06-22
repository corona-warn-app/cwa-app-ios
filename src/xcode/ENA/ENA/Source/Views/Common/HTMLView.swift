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

	// MARK: - Init

	override init(frame: CGRect, configuration: WKWebViewConfiguration) {
		super.init(frame: frame, configuration: configuration)
		setup()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setup()
	}

	init() {
		// We currently deal with local HTML, so no need to handle Cookies, etc. for now
		let config = WKWebViewConfiguration()
		super.init(frame: .zero, configuration: config)
	}

	private func setup() {
		backgroundColor = nil
		scrollView.isScrollEnabled = false
	}

	// MARK: - Content display

	override var intrinsicContentSize: CGSize {
		return scrollView.contentSize
	  }

	func load(from url: URL) throws {
		let request = URLRequest(url: url)
		if load(request) == nil {
			throw WebViewError.cannotLoad
		}
	}
}
