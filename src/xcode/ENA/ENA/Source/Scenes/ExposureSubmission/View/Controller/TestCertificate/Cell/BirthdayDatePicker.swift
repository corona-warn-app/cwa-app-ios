////
// 🦠 Corona-Warn-App
//

import UIKit

class BirthdayDatePicker: UITableViewCell, ReuseIdentifierProviding {

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

	// MARK: - Protocol <#Name#>

	// MARK: - Public

	// MARK: - Internal

	func configure(placeHolder: String, accessibilityIdentifier: String?) {
		textField.placeholder = placeHolder
		self.accessibilityIdentifier = accessibilityIdentifier
	}

	// MARK: - Private

	private let textField = ENATextField()

	private func setupView() {
		textField.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(textField)

		NSLayoutConstraint.activate(
			[
				textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15.0),
				textField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15.0),
				textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15.0),
				textField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15.0),
				textField.heightAnchor.constraint(equalToConstant: 40.0)
			]
		)

		let datePicker = UIDatePicker()
		datePicker.datePickerMode = .date
		datePicker.maximumDate = Date()

		if #available(iOS 13.4, *) {
			datePicker.preferredDatePickerStyle = .wheels
		}

		textField.inputView = datePicker
	}

}

extension DynamicCell {
	/// A `BirthDateInputCell` to display input picker for a date picker
	/// - Parameters:
	///   - placeholder: text show as a placeholder inside the testfield
	/// - Returns: A `DynamicCell` to display legal texts
	static func birthdayDateInputCell(
		placeholder: String,
		accessibilityIdentifier: String? = nil
	) -> Self {
		.identifier(ExposureSubmissionTestCertificateViewModel.ReuseIdentifiers.birthdayDatePicker) { viewController, cell, indexPath in
			guard let cell = cell as? BirthdayDatePicker else {
				fatalError("could not initialize cell of type `BirthdayDatePicker`")
			}
			cell.configure(placeHolder: placeholder, accessibilityIdentifier: accessibilityIdentifier)
		}
	}

}

