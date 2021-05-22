//
// 🦠 Corona-Warn-App
//

#if !RELEASE

import UIKit

class DMDebugRiskCalculationViewController: UIViewController {

	// MARK: - Init

	init(store: Store) {
		self.store = store

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
	private let textView = UITextView()

	private struct RiskCalculationDebugHelper: Encodable {
		let configuration: RiskCalculationConfiguration
		let mostRecentRiskCalculation: ENFRiskCalculation
	}

	private func setUp() {
		title = "🐞🥊 🦠🧮"

		textView.isEditable = false

		view.addSubview(textView)
		textView.translatesAutoresizingMaskIntoConstraints = false

		NSLayoutConstraint.activate([
			view.leadingAnchor.constraint(equalTo: textView.leadingAnchor),
			view.topAnchor.constraint(equalTo: textView.topAnchor),
			view.trailingAnchor.constraint(equalTo: textView.trailingAnchor),
			view.bottomAnchor.constraint(equalTo: textView.bottomAnchor)
		])

		guard let mostRecentRiskCalculationConfiguration = store.mostRecentRiskCalculationConfiguration,
			  let mostRecentRiskCalculation = store.mostRecentRiskCalculation else {
			textView.text = "No risk calculation run yet."
			return
		}

		let riskCalculationDebugHelper = RiskCalculationDebugHelper(
			configuration: mostRecentRiskCalculationConfiguration,
			mostRecentRiskCalculation: mostRecentRiskCalculation
		)

		let encoder = JSONEncoder()
		encoder.outputFormatting = .prettyPrinted
		encoder.dateEncodingStrategy = .iso8601
		
		if let data = try? encoder.encode(riskCalculationDebugHelper),
		   let jsonString = String(data: data, encoding: .utf8) {
			textView.text = jsonString
		}
	}

	@objc
	private func didTapExportButton() {
		let activityViewController = UIActivityViewController(activityItems: [textView.text ?? ""], applicationActivities: nil)
		present(activityViewController, animated: true, completion: nil)
	}
	
}

#endif
