//
// Corona-Warn-App
//
// SAP SE and all other contributors
// copyright owners license this file to you under the Apache
// License, Version 2.0 (the "License"); you may not use this
// file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.
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

		view.backgroundColor = .systemBackground

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
