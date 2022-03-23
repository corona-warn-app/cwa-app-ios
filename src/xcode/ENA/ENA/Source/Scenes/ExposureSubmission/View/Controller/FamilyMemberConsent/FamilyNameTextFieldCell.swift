//
// 🦠 Corona-Warn-App
//

import UIKit

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

	// MARK: - Private

//	private let textField: ENATextField = ENATextField(frame: .zero)
	private var viewModel: String?

	private func setupView() {
		let textField = ENATextField(frame: .zero)
		textField.accessibilityIdentifier = AccessibilityIdentifiers.ContactDiaryInformation.Day.notesTextField
		textField.backgroundColor = .enaColor(for: .darkBackground)
		textField.clearButtonMode = .whileEditing
		textField.textColor = .enaColor(for: .textPrimary1)
		textField.returnKeyType = .done
		textField.delegate = self
		textField.layer.borderWidth = 0
		contentView.addSubview(textField)

		NSLayoutConstraint.activate(
			[
				textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8.0),
				textField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8.0),
				textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8.0),
				textField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -88.0),
				textField.heightAnchor.constraint(equalToConstant: 40.0)
			]
		)

	}

}
