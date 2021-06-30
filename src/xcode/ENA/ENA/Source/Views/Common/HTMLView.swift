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
		setup()
	}

	private func setup() {
		backgroundColor = nil
		scrollView.isScrollEnabled = false

		accessibilityIdentifier = "HTMLView"
	}

	// MARK: - Content display

	override var intrinsicContentSize: CGSize {
		return scrollView.contentSize
	}
}
