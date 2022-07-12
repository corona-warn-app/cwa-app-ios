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
			htmlView.navigationDelegate = self
			let request = URLRequest(url: url)
			htmlView.load(request)
		} else {
			Log.error("Could not load url \(infoModel.urlResourceName).html", log: .ui, error: nil)
		}
		
		htmlView.scrollView.isScrollEnabled = true
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

class NewHTMLViewController: UIViewController, DismissHandling {
	
	let containerScrollView: UIScrollView = {
		let view = UIScrollView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.isAccessibilityElement = false
		return view
	}()
	
	let headline: UILabel = {
		let label = UILabel()
		label.text = "Some headline text"
		label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
		label.isAccessibilityElement = true
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	let webView: NewHTMLView = {
		let view = NewHTMLView(frame: .zero, configuration: WKWebViewConfiguration())
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = nil
		view.isAccessibilityElement = false
		view.scrollView.isScrollEnabled = true
		return view
	}()
	
	let html: String = {
	   """
	   
	   <!DOCTYPE html>
	   <html lang="en">
	   <head>
	   <meta charset="UTF-8">
	   <meta http-equiv="X-UA-Compatible" content="IE=edge">
	   <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
	   <title>Document</title>
	   <style>
	   html { font-size: 1.5rem; }
	   </style>
	   </head>
	   <body>
	   <h1>HTML Ipsum Presents</h1>

	   <p><strong>Pellentesque habitant morbi tristique</strong> senectus et netus et malesuada fames ac turpis egestas. Vestibulum tortor quam, feugiat vitae, ultricies eget, tempor sit amet, ante. Donec eu libero sit amet quam egestas semper. <em>Aenean ultricies mi vitae est.</em> Mauris placerat eleifend leo. Quisque sit amet est et sapien ullamcorper pharetra. Vestibulum erat wisi, condimentum sed, <code>commodo vitae</code>, ornare sit amet, wisi. Aenean fermentum, elit eget tincidunt condimentum, eros ipsum rutrum orci, sagittis tempus lacus enim ac dui. <a href="#">Donec non enim</a> in turpis pulvinar facilisis. Ut felis.</p>

	   <h2>Header Level 2</h2>

	   <ol>
	   <li>Lorem ipsum dolor sit amet, consectetuer adipiscing elit.</li>
	   <li>Aliquam tincidunt mauris eu risus.</li>
	   </ol>

	   <blockquote><p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus magna. Cras in mi at felis aliquet congue. Ut a est eget ligula molestie gravida. Curabitur massa. Donec eleifend, libero at sagittis mollis, tellus est malesuada tellus, at luctus turpis elit sit amet quam. Vivamus pretium ornare est.</p></blockquote>

	   <h3>Header Level 3</h3>

	   <ul>
	   <li>Lorem ipsum dolor sit amet, consectetuer adipiscing elit.</li>
	   <li>Aliquam tincidunt mauris eu risus.</li>
	   </ul>

	   <pre><code>
	   #header h1 a {
	   display: block;
	   width: 300px;
	   height: 80px;
	   }
	   </code></pre>
	   </body>
	   </html>
	   """
	}()
	
	init(model: HtmlInfoModel) {
		self.infoModel = model
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has intentionally not been implemented")
	}
	
	var webViewHeightConstraint: NSLayoutConstraint?

	override func viewDidLoad() {
		super.viewDidLoad()
		
//		navigationItem.largeTitleDisplayMode = .never
		
		view.backgroundColor = .white
		
		view.addSubview(containerScrollView)
		
		containerScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
		containerScrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
		containerScrollView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
		containerScrollView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
		
		containerScrollView.addSubview(headline)
		
		headline.topAnchor.constraint(equalTo: containerScrollView.topAnchor).isActive = true
		headline.rightAnchor.constraint(equalTo: containerScrollView.rightAnchor).isActive = true
		headline.leftAnchor.constraint(equalTo: containerScrollView.leftAnchor).isActive = true
		
		containerScrollView.addSubview(webView)

		webView.topAnchor.constraint(equalTo: headline.bottomAnchor, constant: 8).isActive = true
		webView.bottomAnchor.constraint(equalTo: containerScrollView.bottomAnchor).isActive = true
		webView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
		webView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
		webViewHeightConstraint = webView.heightAnchor.constraint(equalToConstant: 500)
		webViewHeightConstraint?.isActive = true
		
//		webView.loadHTMLString(html, baseURL: nil)
		
		if let url = Bundle.main.url(forResource: infoModel.urlResourceName, withExtension: "html") {
			webView.navigationDelegate = self
			let request = URLRequest(url: url)
			webView.load(request)
		} else {
			Log.error("Could not load url \(infoModel.urlResourceName).html", log: .ui, error: nil)
		}
	}
	
	var dismissHandeling: (() -> Void)?
	var isDismissable = true
	
	private let infoModel: HtmlInfoModel
}

extension NewHTMLViewController: WKNavigationDelegate {

	func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
		webView.evaluateJavaScript("document.readyState", completionHandler: { complete, error in
			if complete != nil {
				self.webView.evaluateJavaScript("document.body.scrollHeight", completionHandler: { [weak self] height, error in
					if let height = height as? CGFloat {
						Log.debug("Set content height to \(height) @\(UIScreen.main.scale)x")
						self?.webViewHeightConstraint?.constant = webView.scrollView.intrinsicContentSize.height
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

class NewHTMLView: WKWebView {
	// MARK: - Content display

	override var intrinsicContentSize: CGSize {
		return scrollView.contentSize
	}
}

extension NewHTMLView: UIScrollViewDelegate {
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		// Prevents a side scrolling during text selection
		if scrollView.contentOffset.x != 0 {
			scrollView.contentOffset.x = 0
		}
	}
}
