//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class FamilyNameTextFieldCell: UITableViewCell, UITextFieldDelegate, ReuseIdentifierProviding {

	// MARK: - Init

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupView()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	// MARK: - Protocol UITextFieldDelegate

	func textFieldDidEndEditing(_ textField: UITextField) {
		viewModel = textField.text
	}

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		endEditing(true)
	}

	// MARK: - Public

	// MARK: - Internal

	@OpenCombine.Published private(set) var viewModel: String?

	func configure(_ placeholder: String? = nil) {
		textField.placeholder = placeholder
	}

	// MARK: - Private
	private let textField = ENATextField(frame: .zero)

	private func setupView() {
		textField.translatesAutoresizingMaskIntoConstraints = false
		textField.accessibilityIdentifier = AccessibilityIdentifiers.HealthCertificate.FamilyMemberConsent.textInput
		textField.backgroundColor = .enaColor(for: .backgroundLightGray)
		textField.clearButtonMode = .whileEditing
		textField.textColor = .enaColor(for: .textPrimary1)
		textField.returnKeyType = .done
		textField.delegate = self
		textField.layer.borderWidth = 0
		contentView.addSubview(textField)

		NSLayoutConstraint.activate(
			[
				textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 13.0),
				textField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8.0),
				textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -33.0),
				textField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8.0),
				textField.heightAnchor.constraint(equalToConstant: 40.0)
			]
		)

	}

}
