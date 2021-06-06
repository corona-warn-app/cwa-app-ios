////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class BirthdayDatePickerCell: UITableViewCell, ReuseIdentifierProviding, UITextFieldDelegate {

	// MARK: - Init

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupView()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Protocol UITextFieldDelegate

	func textFieldShouldClear(_ textField: UITextField) -> Bool {
		dateOfBirth = nil
		return true
	}

	// MARK: - Internal

	@OpenCombine.Published var dateOfBirth: Date?

	func configure(
		placeHolder: String,
		accessibilityIdentifier: String?
	) {
		textField.placeholder = placeHolder
		self.accessibilityIdentifier = accessibilityIdentifier
	}

	// MARK: - Private

	private let textField = ENATextField()
	private var subscriptions = Set<AnyCancellable>()

	private func setupView() {
		selectionStyle = .none
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
		datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
		textField.inputView = datePicker

		textField.clearButtonMode = .whileEditing
		textField.delegate = self

		$dateOfBirth
			.dropFirst()
			.sink { [weak self] dateOfBirth in
				guard let date = dateOfBirth else {
					self?.textField.text = nil
					return
				}
				self?.textField.text = DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none)
			}
			.store(in: &subscriptions)
	}

	@objc
	private func datePickerValueChanged(_ datePicker: UIDatePicker) {
		dateOfBirth = datePicker.date
	}
}

extension DynamicCell {
	/// A `BirthdayDatePickerCell` to display input picker for a date picker
	/// - Parameters:
	///   - placeholder: text show as a placeholder inside the textField
	/// - Returns: A `DynamicCell` to display legal texts
	static func birthdayDatePicker(
		placeholder: String,
		accessibilityIdentifier: String? = nil,
		configure: CellConfigurator? = nil
	) -> Self {
		.identifier(ExposureSubmissionTestCertificateViewModel.ReuseIdentifiers.birthdayDatePicker) { viewController, cell, indexPath in
			guard let cell = cell as? BirthdayDatePickerCell else {
				fatalError("could not initialize cell of type `BirthdayDatePickerCell`")
			}
			cell.configure(placeHolder: placeholder, accessibilityIdentifier: accessibilityIdentifier)
			configure?(viewController, cell, indexPath)
		}
	}
}
