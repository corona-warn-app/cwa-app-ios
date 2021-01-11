//
// 🦠 Corona-Warn-App
//

import UIKit

class DMDeltaOnboardingViewController: UIViewController, UITextFieldDelegate {

	// MARK: - Attributes

	private let store: Store
	private var textField: UITextField!
	private var currentVersionLabel: UILabel!

	// MARK: - Initializers

	init(store: Store) {
		self.store = store

		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - View Lifecycle Methods

	override func viewDidLoad() {
		super.viewDidLoad()

		view.backgroundColor = ColorCompatibility.systemBackground

		currentVersionLabel = UILabel(frame: .zero)
		currentVersionLabel.translatesAutoresizingMaskIntoConstraints = false
		updateCurrentVersionLabel()

		let button = UIButton(frame: .zero)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.setTitle("Save Onboarding Version", for: .normal)
		button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
		button.setTitleColor(.enaColor(for: .buttonPrimary), for: .normal)

		textField = UITextField(frame: .zero)
		textField.translatesAutoresizingMaskIntoConstraints = false
		textField.delegate = self
		textField.borderStyle = .bezel

		let stackView = UIStackView(arrangedSubviews: [currentVersionLabel, textField, button])
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.axis = .vertical
		stackView.spacing = 20

		view.addSubview(stackView)
		NSLayoutConstraint.activate([
			stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
		])
	}

	// MARK: - Private API

	private func updateCurrentVersionLabel() {
		currentVersionLabel.text = "Current onboarding version: \(store.onboardingVersion)"
	}

	@objc
	private func buttonTapped() {
		store.onboardingVersion = textField.text ?? ""
		updateCurrentVersionLabel()
		let alert = UIAlertController(title: "Saved onboarding version: \(store.onboardingVersion)", message: "", preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "Ok", style: .cancel))
		present(alert, animated: true)
	}
}
