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
		isOpaque = false
		scrollView.isScrollEnabled = false
		isAccessibilityElement = true

		accessibilityIdentifier = AccessibilityIdentifiers.General.webView
		scrollView.delegate = self
	}

	// MARK: - Content display

	override var intrinsicContentSize: CGSize {
		return scrollView.contentSize
	}
}

extension HTMLView: UIScrollViewDelegate {
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		// Prevents a side scrolling during text selection
		if scrollView.contentOffset.x != 0 {
			scrollView.contentOffset.x = 0
		}
	}
}
