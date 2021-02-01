////
// 🦠 Corona-Warn-App
//

import UIKit

final class SurveyConsentViewController: UIViewController {

	// MARK: - Init

	init(
		viewModel: SurveyConsentViewModel,
		onStartSurveyTap: @escaping (URL) -> Void
	) {
		self.viewModel = viewModel
		self.onStartSurveyTap = onStartSurveyTap

		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .white
		createAndLayoutViewHierarchy()
	}

	// MARK: - Protocol

	// MARK: - Public

	// MARK: - Internal

	func createAndLayoutViewHierarchy() {
		let button = UIButton(type: .custom)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.setTitle("Start Survey", for: .normal)
		button.setTitleColor(.red, for: .normal)
		button.addTarget(self, action: #selector(didTap), for: .touchUpInside)
		button.accessibilityIdentifier = AccessibilityIdentifiers.ExposureDetection.surveyStartButton
		view.addSubview(button)

		button.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
		button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
	}

	@objc
	func didTap() {
		guard let url = URL(string: "https://www.test.de") else {
			return
		}
		onStartSurveyTap(url)
	}

	// MARK: - Private

	private let onStartSurveyTap: (URL) -> Void
	private let viewModel: SurveyConsentViewModel
}
