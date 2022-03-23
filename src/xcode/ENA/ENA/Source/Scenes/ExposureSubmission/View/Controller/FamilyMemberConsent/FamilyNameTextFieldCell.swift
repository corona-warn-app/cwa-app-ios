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

	private var viewModel: String?

	private func setupView() {
		let textField = ENATextField(frame: .zero)
		textField.translatesAutoresizingMaskIntoConstraints = false
		textField.accessibilityIdentifier = AccessibilityIdentifiers.ContactDiaryInformation.Day.notesTextField
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
