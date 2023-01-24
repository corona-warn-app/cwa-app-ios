////
// 🦠 Corona-Warn-App
//

import UIKit

class AntigenTestProfileInputCell: UITableViewCell, ReuseIdentifierProviding {
		
	// MARK: - Init
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Overrides
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)

		selectionStyle = .none
		contentView.backgroundColor = .enaColor(for: .background)
		
		contentView.addSubview(scrollView)
		scrollView.addSubview(stackView)
		
		firstNameTextField = textField()
		firstNameTextField.placeholder = AppStrings.AntigenProfile.Create.firstNameTextFieldPlaceholder
		firstNameTextField.accessibilityIdentifier = AccessibilityIdentifiers.AntigenProfile.Create.firstNameTextField
		firstNameTextField.textContentType = .givenName
		stackView.addArrangedSubview(firstNameTextField)
		textFields.append(firstNameTextField)

		lastNameTextField = textField()
		lastNameTextField.placeholder = AppStrings.AntigenProfile.Create.lastNameTextFieldPlaceholder
		lastNameTextField.accessibilityIdentifier = AccessibilityIdentifiers.AntigenProfile.Create.lastNameTextField
		lastNameTextField.textContentType = .familyName
		stackView.addArrangedSubview(lastNameTextField)
		textFields.append(lastNameTextField)

		birthDateNameTextField = textField()
		birthDateNameTextField.placeholder = AppStrings.AntigenProfile.Create.birthDateTextFieldPlaceholder
		birthDateNameTextField.accessibilityIdentifier = AccessibilityIdentifiers.AntigenProfile.Create.birthDateTextField
		birthDateNameTextField.inputView = birthdayPicker
		stackView.addArrangedSubview(birthDateNameTextField)
		textFields.append(birthDateNameTextField)

		addressLineTextField = textField()
		addressLineTextField.placeholder = AppStrings.AntigenProfile.Create.streetTextFieldPlaceholder
		addressLineTextField.accessibilityIdentifier = AccessibilityIdentifiers.AntigenProfile.Create.streetTextField
		addressLineTextField.textContentType = .streetAddressLine1
		stackView.addArrangedSubview(addressLineTextField)
		textFields.append(addressLineTextField)

		postalCodeTextField = textField()
		postalCodeTextField.placeholder = AppStrings.AntigenProfile.Create.postalCodeTextFieldPlaceholder
		postalCodeTextField.accessibilityIdentifier = AccessibilityIdentifiers.AntigenProfile.Create.postalCodeTextField
		postalCodeTextField.keyboardType = .asciiCapableNumberPad
		postalCodeTextField.textContentType = .postalCode
		stackView.addArrangedSubview(postalCodeTextField)
		textFields.append(postalCodeTextField)

		cityTextField = textField()
		cityTextField.placeholder = AppStrings.AntigenProfile.Create.cityTextFieldPlaceholder
		cityTextField.accessibilityIdentifier = AccessibilityIdentifiers.AntigenProfile.Create.cityTextField
		cityTextField.textContentType = .addressCity
		stackView.addArrangedSubview(cityTextField)
		textFields.append(cityTextField)

		phoneNumberTextField = textField()
		phoneNumberTextField.placeholder = AppStrings.AntigenProfile.Create.phoneNumberTextFieldPlaceholder
		phoneNumberTextField.accessibilityIdentifier = AccessibilityIdentifiers.AntigenProfile.Create.phoneNumberTextField
		phoneNumberTextField.keyboardType = .phonePad
		phoneNumberTextField.textContentType = .telephoneNumber
		stackView.addArrangedSubview(phoneNumberTextField)
		textFields.append(phoneNumberTextField)

		emailAddressTextField = textField()
		emailAddressTextField.placeholder = AppStrings.AntigenProfile.Create.emailAddressTextFieldPlaceholder
		emailAddressTextField.accessibilityIdentifier = AccessibilityIdentifiers.AntigenProfile.Create.emailAddressTextField
		emailAddressTextField.keyboardType = .emailAddress
		emailAddressTextField.textContentType = .emailAddress
		stackView.addArrangedSubview(emailAddressTextField)
		textFields.append(emailAddressTextField)
		
		NSLayoutConstraint.activate([
			
			scrollView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			scrollView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
			scrollView.topAnchor.constraint(equalTo: contentView.topAnchor),
			scrollView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
			
			stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 23),
			stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -23),
			stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 23),
			stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -23)
			
		])
		
		setVoiceOverOrderOfInputFields()
	}

	// MARK: - Internal
	
	let birthdayPicker: UIDatePicker = {
		let birthdayPicker = UIDatePicker()
		birthdayPicker.timeZone = .utcTimeZone
		birthdayPicker.locale = Locale.autoupdatingCurrent
		birthdayPicker.datePickerMode = .date
		birthdayPicker.maximumDate = Date()
		if #available(iOS 13.4, *) {
			birthdayPicker.preferredDatePickerStyle = .wheels
		}
		if let date = ISO8601DateFormatter.justUTCDateFormatter.date(from: "2000-01-01") {
			birthdayPicker.date = date
		}
		return birthdayPicker
	}()
	
	var scrollView: UIScrollView = {
		let scrollView = UIScrollView()
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		return scrollView
	}()
	
	var stackView: UIStackView = {
		let stackView = UIStackView()
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.axis = .vertical
		stackView.distribution = .fillEqually
		stackView.spacing = 10
		return stackView
	}()

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
	
	private func textField() -> ENATextField {
		let textField = ENATextField(frame: .zero)
		textField.autocorrectionType = .no
		textField.isUserInteractionEnabled = true
		textField.font = UIFont.preferredFont(forTextStyle: .body)
		textField.adjustsFontForContentSizeCategory = true
		textField.returnKeyType = .next
		textField.clearButtonMode = .whileEditing
		textField.spellCheckingType = .no
		textField.smartQuotesType = .no
		textField.layer.borderWidth = 0
		textField.keyboardType = .asciiCapable
		textField.translatesAutoresizingMaskIntoConstraints = false
		textField.heightAnchor.constraint(greaterThanOrEqualToConstant: 40).isActive = true
		return textField
	}
	
	private func setVoiceOverOrderOfInputFields() {
		accessibilityElements = [
			firstNameTextField,
			lastNameTextField,
			birthDateNameTextField,
			addressLineTextField,
			postalCodeTextField,
			cityTextField,
			phoneNumberTextField,
			emailAddressTextField
		].compactMap { $0 }
	}
}
