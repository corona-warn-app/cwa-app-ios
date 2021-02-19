//
// 🦠 Corona-Warn-App
//

#if !RELEASE

import UIKit

class DMPPAnalyticsActualData: UIViewController {

	// MARK: - Init

	init(
		store: Store,
		client: Client,
		appConfig: AppConfigurationProviding
	) {
		self.store = store
		self.client = client
		self.appConfiguration = appConfig
		self.submitter = PPAnalyticsSubmitter(
			store: store,
			client: client,
			appConfig: appConfig)

		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()

		setUp()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		navigationController?.setToolbarHidden(false, animated: animated)

		let shareBarButtonItem = UIBarButtonItem(title: "Export", style: .plain, target: self, action: #selector(didTapExportButton))

		setToolbarItems(
			[
				UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
				shareBarButtonItem,
				UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
			],
			animated: animated
		)
	}

	// MARK: - Private
	private let store: Store
	private let client: Client
	private let appConfiguration: AppConfigurationProviding
	private let submitter: PPAnalyticsSubmitter
	private let textView = UITextView()

	private func setUp() {
		title = "PPA - Actual data 📈"

		textView.isEditable = false

		view.addSubview(textView)
		textView.translatesAutoresizingMaskIntoConstraints = false

		NSLayoutConstraint.activate([
			view.leadingAnchor.constraint(equalTo: textView.leadingAnchor),
			view.topAnchor.constraint(equalTo: textView.topAnchor),
			view.trailingAnchor.constraint(equalTo: textView.trailingAnchor),
			view.bottomAnchor.constraint(equalTo: textView.bottomAnchor)
		])

		textView.text = Analytics.getPPADataMessage().debugDescription
	}

	@objc
	private func didTapExportButton() {
		let activityViewController = UIActivityViewController(activityItems: [textView.text ?? ""], applicationActivities: nil)
		present(activityViewController, animated: true, completion: nil)
	}

}

#endif
