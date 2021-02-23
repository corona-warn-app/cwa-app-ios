////
// 🦠 Corona-Warn-App
//

import UIKit

class HTMLViewController: UIViewController {
	
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
		guard let completion = dismissHandeling else {
			dismiss(animated: true, completion: nil)
			return
		}
		completion()
	}
	
	// MARK: - Internal

	var dismissHandeling: (() -> Void)?

	// MARK: - Private

	private func setup() {
		navigationItem.title = AppStrings.AppInformation.privacyNavigation

		imageView.image = infoModel.image
		imageView.accessibilityLabel = infoModel.imageAccessabliltyLabel
		imageView.accessibilityIdentifier = infoModel.imageAccessabliltyIdentfier
		
		htmlTitleLabel.text = infoModel.title
		htmlTitleLabel.accessibilityIdentifier = infoModel.titleAccessabliltyIdentfier
		
		if let url = Bundle.main.url(forResource: infoModel.urlResourceName, withExtension: "html") {
			do {
				try htmlTextView.load(from: url)
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

	@IBOutlet private weak var imageView: UIImageView!
	@IBOutlet private weak var htmlTextView: HtmlTextView!
	@IBOutlet private weak var htmlTitleLabel: ENALabel!
	
	private let infoModel: HtmlInfoModel
}
