////
// 🦠 Corona-Warn-App
//

import UIKit

class CreateAntigenTestProfileInputCell: UITableViewCell, ReuseIdentifierProviding {
		
	// MARK: - Init
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Overrides
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)

		selectionStyle = .none

		firstNameTextField = textField()
		firstNameTextField.placeholder = AppStrings.AntigenProfile.Create.firstNameTextFieldPlaceholder
		firstNameTextField.accessibilityIdentifier = AccessibilityIdentifiers.AntigenProfile.Create.firstNameTextField
		firstNameTextField.keyboardType = .default
		firstNameTextField.textContentType = .givenName
		contentView.addSubview(firstNameTextField)
		textFields.append(firstNameTextField)

		lastNameTextField = textField()
		lastNameTextField.placeholder = AppStrings.AntigenProfile.Create.lastNameTextFieldPlaceholder
		lastNameTextField.accessibilityIdentifier = AccessibilityIdentifiers.AntigenProfile.Create.lastNameTextField
		lastNameTextField.keyboardType = .default
		lastNameTextField.textContentType = .familyName
		contentView.addSubview(lastNameTextField)
		textFields.append(lastNameTextField)

		birthdayPicker = UIDatePicker()
		birthdayPicker.timeZone = .utcTimeZone
		birthdayPicker.locale = Locale.autoupdatingCurrent
		birthdayPicker.datePickerMode = .date
		if #available(iOS 13.4, *) {
			birthdayPicker.preferredDatePickerStyle = .wheels
		}

		birthDateNameTextField = textField()
		birthDateNameTextField.placeholder = AppStrings.AntigenProfile.Create.birthDateTextFieldPlaceholder
		birthDateNameTextField.accessibilityIdentifier = AccessibilityIdentifiers.AntigenProfile.Create.birthDateTextField
		birthDateNameTextField.keyboardType = .default
		birthDateNameTextField.inputView = birthdayPicker
		contentView.addSubview(birthDateNameTextField)
		textFields.append(birthDateNameTextField)

		addressLineTextField = textField()
		addressLineTextField.placeholder = AppStrings.AntigenProfile.Create.streetTextFieldPlaceholder
		addressLineTextField.accessibilityIdentifier = AccessibilityIdentifiers.AntigenProfile.Create.streetTextField
		addressLineTextField.keyboardType = .default
		addressLineTextField.textContentType = .streetAddressLine1
		contentView.addSubview(addressLineTextField)
		textFields.append(addressLineTextField)

		postalCodeTextField = textField()
		postalCodeTextField.placeholder = AppStrings.AntigenProfile.Create.postalCodeTextFieldPlaceholder
		postalCodeTextField.accessibilityIdentifier = AccessibilityIdentifiers.AntigenProfile.Create.postalCodeTextField
		postalCodeTextField.keyboardType = .numberPad
		postalCodeTextField.textContentType = .postalCode
		contentView.addSubview(postalCodeTextField)
		textFields.append(postalCodeTextField)

		cityTextField = textField()
		cityTextField.placeholder = AppStrings.AntigenProfile.Create.cityTextFieldPlaceholder
		cityTextField.accessibilityIdentifier = AccessibilityIdentifiers.AntigenProfile.Create.cityTextField
		cityTextField.keyboardType = .default
		cityTextField.textContentType = .addressCity
		contentView.addSubview(cityTextField)
		textFields.append(cityTextField)

		phoneNumberTextField = textField()
		phoneNumberTextField.placeholder = AppStrings.AntigenProfile.Create.phoneNumberTextFieldPlaceholder
		phoneNumberTextField.accessibilityIdentifier = AccessibilityIdentifiers.AntigenProfile.Create.phoneNumberTextField
		phoneNumberTextField.keyboardType = .phonePad
		phoneNumberTextField.textContentType = .telephoneNumber
		contentView.addSubview(phoneNumberTextField)
		textFields.append(phoneNumberTextField)

		emailAddressTextField = textField()
		emailAddressTextField.placeholder = AppStrings.AntigenProfile.Create.emailAddressTextFieldPlaceholder
		emailAddressTextField.accessibilityIdentifier = AccessibilityIdentifiers.AntigenProfile.Create.emailAddressTextField
		emailAddressTextField.keyboardType = .emailAddress
		emailAddressTextField.textContentType = .emailAddress
		contentView.addSubview(emailAddressTextField)
		textFields.append(emailAddressTextField)

		let inset: CGFloat = 23
		
		NSLayoutConstraint.activate([

			firstNameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: inset),
			firstNameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -inset),
			firstNameTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: inset),
			firstNameTextField.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -inset),

			lastNameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: inset),
			lastNameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -inset),
			lastNameTextField.topAnchor.constraint(equalTo: firstNameTextField.bottomAnchor, constant: 7),
			lastNameTextField.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -inset),

			birthDateNameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: inset),
			birthDateNameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -inset),
			birthDateNameTextField.topAnchor.constraint(equalTo: lastNameTextField.bottomAnchor, constant: 7),
			birthDateNameTextField.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -inset),

			addressLineTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: inset),
			addressLineTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -inset),
			addressLineTextField.topAnchor.constraint(equalTo: birthDateNameTextField.bottomAnchor, constant: 7),
			addressLineTextField.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -inset),

			postalCodeTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: inset),
			postalCodeTextField.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -inset),
			postalCodeTextField.topAnchor.constraint(equalTo: addressLineTextField.bottomAnchor, constant: 7),
			postalCodeTextField.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -inset),
			postalCodeTextField.widthAnchor.constraint(equalTo: addressLineTextField.widthAnchor, multiplier: 0.4),

			cityTextField.leadingAnchor.constraint(equalTo: postalCodeTextField.trailingAnchor, constant: 7),
			cityTextField.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -inset),
			cityTextField.topAnchor.constraint(equalTo: addressLineTextField.bottomAnchor, constant: 7),
			cityTextField.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -inset),

			phoneNumberTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: inset),
			phoneNumberTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -inset),
			phoneNumberTextField.topAnchor.constraint(equalTo: cityTextField.bottomAnchor, constant: 7),
			phoneNumberTextField.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -inset),

			emailAddressTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: inset),
			emailAddressTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -inset),
			emailAddressTextField.topAnchor.constraint(equalTo: phoneNumberTextField.bottomAnchor, constant: 7),
			emailAddressTextField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -inset)
		])
	}
	
	// MARK: - Internal
	
	var birthdayPicker: UIDatePicker!
	var textFields = [UITextField]()
	var firstNameTextField: ENATextField!
	var lastNameTextField: ENATextField!
	var birthDateNameTextField: ENATextField!
	var addressLineTextField: ENATextField!
	var postalCodeTextField: ENATextField!
	var cityTextField: ENATextField!
	var phoneNumberTextField: ENATextField!
	var emailAddressTextField: ENATextField!
	
	// MARK: - Private

	private func textField () -> ENATextField {
		let textField = ENATextField(frame: .zero)
		textField.autocorrectionType = .no
		textField.isUserInteractionEnabled = true
		textField.returnKeyType = .next
		textField.clearButtonMode = .whileEditing
		textField.spellCheckingType = .no
		textField.smartQuotesType = .no
		textField.layer.borderWidth = 0
		textField.translatesAutoresizingMaskIntoConstraints = false
		textField.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
		return textField
	}
}
