////
// 🦠 Corona-Warn-App
//

import UIKit
import WebKit

class HTMLViewController: UIViewController, DismissHandling {
	
	// MARK: - Init

	init(model: HtmlInfoModel) {
		self.infoModel = model
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has intentionally not been implemented")
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.setup()
		self.setupNavigationBar()
	}
	
	// MARK: - Protocol DismissHandling
	
	func wasAttemptedToBeDismissed() {
		if isDismissable {
			guard let completion = dismissHandeling else {
				dismiss(animated: true, completion: nil)
				return
			}
			completion()
		}
	}
	
	// MARK: - Internal

	var dismissHandeling: (() -> Void)?
	var isDismissable = true
	// MARK: - Private

	private func setup() {
		imageView.image = infoModel.image
		imageView.accessibilityLabel = infoModel.imageAccessabliltyLabel
		imageView.accessibilityIdentifier = infoModel.imageAccessabliltyIdentfier
		
		htmlTitleLabel.text = infoModel.title
		htmlTitleLabel.accessibilityIdentifier = infoModel.titleAccessabliltyIdentfier
		
		if let url = Bundle.main.url(forResource: infoModel.urlResourceName, withExtension: "html") {
			do {
				htmlView.navigationDelegate = self
				try htmlView.load(from: url)
			} catch {
				Log.error("Could not load url \(url)", log: .ui, error: error)
			}
		}
	}
	
	private func setupNavigationBar() {
		if #available(iOS 13, *) {
			navigationItem.largeTitleDisplayMode = .always
		} else {
			navigationItem.largeTitleDisplayMode = .never
		}
	}

    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var imageView: UIImageView!
	@IBOutlet private weak var htmlView: HTMLView!
	@IBOutlet private weak var htmlTitleLabel: ENALabel!
    @IBOutlet private weak var webViewHeight: NSLayoutConstraint!

	private let infoModel: HtmlInfoModel
}

extension HTMLViewController: WKNavigationDelegate {

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        htmlView.evaluateJavaScript("document.readyState", completionHandler: { complete, error in
            if complete != nil {
                self.htmlView.evaluateJavaScript("document.body.scrollHeight", completionHandler: { [weak self] height, error in
                    if let height = height as? CGFloat {
                        Log.debug("Set content height to \(height) @\(UIScreen.main.scale)x")
                        self?.webViewHeight.constant = height
                    } else {
                        Log.error("Could not get website height! \(error?.localizedDescription ?? "")", error: error)
                    }
                })
            }
        })
    }

	func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
		if navigationAction.navigationType == .linkActivated, let url = navigationAction.request.url {
			LinkHelper.open(url: url)
			decisionHandler(.cancel)
		} else {
			decisionHandler(.allow)
		}
	}
}
