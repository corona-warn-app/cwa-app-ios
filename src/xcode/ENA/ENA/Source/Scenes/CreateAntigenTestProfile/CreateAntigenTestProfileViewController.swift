////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class CreateAntigenTestProfileViewController: UITableViewController, FooterViewHandling, DismissHandling, UITextFieldDelegate {

	// MARK: - Init

	deinit {
		cancellables.forEach { $0.cancel() }
	}
	
	init(
		store: AntigenTestProfileStoring,
		didTapSave: @escaping () -> Void,
		dismiss: @escaping () -> Void
	) {
		self.viewModel = CreateAntigenTestProfileViewModel(store: store)
		self.didTapSave = didTapSave
		self.dismiss = dismiss

		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()
		setupView()
		setupBindings()
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 2
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch indexPath.row {
		case 0:
			guard let cell = tableView.dequeueReusableCell(withIdentifier: DescriptionCell.identifier, for: indexPath) as? DescriptionCell else {
				fatalError("Wrong cell")
			}
			return cell
		case 1:
			guard let cell = tableView.dequeueReusableCell(withIdentifier: InputCell.identifier, for: indexPath) as? InputCell else {
				fatalError("Wrong cell")
			}
			if #available(iOS 14.0, *) {
				cell.birthdayPicker.addTarget(self, action: #selector(dateOfBirthDidChange(datePicker:)), for: .editingDidEnd)
			} else {
				cell.birthdayPicker.addTarget(self, action: #selector(dateOfBirthDidChange(datePicker:)), for: .valueChanged)
			}
			cell.birthdayPicker.addTarget(self, action: #selector(dateOfBirthDidChange(datePicker:)), for: .valueChanged)
			
			cell.firstNameTextField.text = viewModel.antigenTestProfile.firstName
			cell.firstNameTextField.delegate = self
			cell.firstNameTextField.addTarget(self, action: #selector(firstNameTextFieldDidChange(textField:)), for: .editingChanged)
			
			cell.lastNameTextField.text = viewModel.antigenTestProfile.lastName
			cell.lastNameTextField.delegate = self
			cell.lastNameTextField.addTarget(self, action: #selector(lastNameTextFieldDidChange(textField:)), for: .editingChanged)
			
			if let date = viewModel.antigenTestProfile.dateOfBirth {
				cell.birthDateNameTextField.text = dateFormatter.string(from: date)
			}
			cell.birthDateNameTextField.delegate = self
			cell.birthDateNameTextField.addTarget(self, action: #selector(birthDateTextFieldDidChange(textField:)), for: .editingChanged)
			
			cell.addressLineTextField.text = viewModel.antigenTestProfile.addressLine
			cell.addressLineTextField.delegate = self
			cell.addressLineTextField.addTarget(self, action: #selector(addressLineTextFieldDidChange(textField:)), for: .editingChanged)
			
			cell.postalCodeTextField.text = viewModel.antigenTestProfile.zipCode
			cell.postalCodeTextField.delegate = self
			cell.postalCodeTextField.addTarget(self, action: #selector(postalCodeTextFieldDidChange(textField:)), for: .editingChanged)
			
			cell.cityTextField.text = viewModel.antigenTestProfile.city
			cell.cityTextField.delegate = self
			cell.cityTextField.addTarget(self, action: #selector(cityTextFieldDidChange(textField:)), for: .editingChanged)
			
			cell.phoneNumberTextField.text = viewModel.antigenTestProfile.phoneNumber
			cell.phoneNumberTextField.delegate = self
			cell.phoneNumberTextField.addTarget(self, action: #selector(phoneNumberTextFieldDidChange(textField:)), for: .editingChanged)
			
			cell.emailAddressTextField.text = viewModel.antigenTestProfile.email
			cell.emailAddressTextField.delegate = self
			cell.emailAddressTextField.addTarget(self, action: #selector(emailAddressTextFieldDidChange(textField:)), for: .editingChanged)
			return cell
		default:
			fatalError("Too many cells")
		}
	}
	
	// MARK: - Protocol FooterViewHandling

	func didTapFooterViewButton(_ type: FooterViewModel.ButtonType) {
		guard case .primary = type else {
			return
		}
		viewModel.save()
		didTapSave()
	}

	// MARK: - Protocol DismissHandling

	func wasAttemptedToBeDismissed() {
		dismiss()
	}
	
	// MARK: - Protocol UITextFieldDelegate

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		if textField.returnKeyType == .next {
			if let cell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? InputCell, let currentIndex = cell.textFields.firstIndex(of: textField), (currentIndex + 1) < cell.textFields.count {
				cell.textFields[currentIndex + 1].becomeFirstResponder()
			} else {
				textField.resignFirstResponder()
			}
		} else {
			textField.resignFirstResponder()
		}
		return true
	}

	// MARK: - Private

	private let viewModel: CreateAntigenTestProfileViewModel
	private let didTapSave: () -> Void
	private let dismiss: () -> Void
	
	private var dateFormatter: DateFormatter!
	private var cancellables = [OpenCombine.AnyCancellable]()

	private func setupView() {
		// navigationItem
		parent?.navigationItem.title = AppStrings.AntigenProfile.Create.title
		parent?.navigationItem.rightBarButtonItem = dismissHandlingCloseBarButton
		// view
		view.backgroundColor = .enaColor(for: .background)
		// tableView
		tableView.separatorStyle = .none
		tableView.register(DescriptionCell.self, forCellReuseIdentifier: DescriptionCell.identifier)
		tableView.register(InputCell.self, forCellReuseIdentifier: InputCell.identifier)
		tableView.keyboardDismissMode = .interactive
		// date
		dateFormatter = DateFormatter()
		dateFormatter.dateStyle = .medium
		dateFormatter.timeStyle = .none
		dateFormatter.locale = Locale(identifier: "de_DE")
	}
	
	private func setupBindings() {
		viewModel.$antigenTestProfile
			.sink { [weak self] antigenTestProfile in
				let isSaveButtonEnabled =
						!(antigenTestProfile.firstName?.isEmpty ?? true) ||
						!(antigenTestProfile.lastName?.isEmpty ?? true) ||
						(antigenTestProfile.dateOfBirth != nil) ||
						!(antigenTestProfile.addressLine?.isEmpty ?? true) ||
						!(antigenTestProfile.zipCode?.isEmpty ?? true) ||
						!(antigenTestProfile.city?.isEmpty ?? true) ||
						!(antigenTestProfile.phoneNumber?.isEmpty ?? true) ||
						!(antigenTestProfile.email?.isEmpty ?? true)
				self?.footerView?.setEnabled(isSaveButtonEnabled, button: .primary)
			}
			.store(in: &cancellables)
	}
	
	@objc
	private func firstNameTextFieldDidChange(textField: UITextField) {
		viewModel.antigenTestProfile.firstName = textField.text
	}
	
	@objc
	private func lastNameTextFieldDidChange(textField: UITextField) {
		viewModel.antigenTestProfile.lastName = textField.text
	}
	
	@objc
	private func birthDateTextFieldDidChange(textField: UITextField) {
		viewModel.antigenTestProfile.dateOfBirth = nil
	}
	
	@objc
	private func dateOfBirthDidChange(datePicker: UIDatePicker) {
		viewModel.antigenTestProfile.dateOfBirth = datePicker.date
		if let cell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? InputCell {
			cell.textFields[2].text = dateFormatter.string(from: datePicker.date)
		}
	}
	
	@objc
	private func addressLineTextFieldDidChange(textField: UITextField) {
		viewModel.antigenTestProfile.addressLine = textField.text
	}
	
	@objc
	private func postalCodeTextFieldDidChange(textField: UITextField) {
		viewModel.antigenTestProfile.zipCode = textField.text
	}
	
	@objc
	private func cityTextFieldDidChange(textField: UITextField) {
		viewModel.antigenTestProfile.city = textField.text
	}
	
	@objc
	private func phoneNumberTextFieldDidChange(textField: UITextField) {
		viewModel.antigenTestProfile.phoneNumber = textField.text
	}
	
	@objc
	private func emailAddressTextFieldDidChange(textField: UITextField) {
		viewModel.antigenTestProfile.email = textField.text
	}
}

private class DescriptionCell: UITableViewCell {
	
	static let identifier = "DescriptionCell"
		
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		// self
		selectionStyle = .none
		// label
		let label = ENALabel()
		label.text = AppStrings.AntigenProfile.Create.description
		label.style = .subheadline
		label.textColor = .enaColor(for: .textPrimary2)
		label.numberOfLines = 0
		label.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(label)
		//
		NSLayoutConstraint.activate([
			label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 23),
			label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -23),
			label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
			label.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -2)
		])
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

private class InputCell: UITableViewCell {
	
	static let identifier = "InputCell"
	
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
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		// self
		selectionStyle = .none
		// firstNameTextField
		firstNameTextField = textField()
		firstNameTextField.placeholder = AppStrings.AntigenProfile.Create.firstNameTextFieldPlaceholder
		firstNameTextField.accessibilityIdentifier = AccessibilityIdentifiers.AntigenProfile.Create.firstNameTextField
		firstNameTextField.keyboardType = .namePhonePad
		contentView.addSubview(firstNameTextField)
		textFields.append(firstNameTextField)
		// lastNameTextField
		lastNameTextField = textField()
		lastNameTextField.placeholder = AppStrings.AntigenProfile.Create.lastNameTextFieldPlaceholder
		lastNameTextField.accessibilityIdentifier = AccessibilityIdentifiers.AntigenProfile.Create.lastNameTextField
		lastNameTextField.keyboardType = .namePhonePad
		contentView.addSubview(lastNameTextField)
		textFields.append(lastNameTextField)
		// birthdayPicker
		birthdayPicker = UIDatePicker()
		birthdayPicker.locale = Locale(identifier: "de_DE")
		birthdayPicker.datePickerMode = .date
		if #available(iOS 13.4, *) {
			birthdayPicker.preferredDatePickerStyle = .wheels
		}
		// birthDateNameTextField
		birthDateNameTextField = textField()
		birthDateNameTextField.placeholder = AppStrings.AntigenProfile.Create.birthDateTextFieldPlaceholder
		birthDateNameTextField.accessibilityIdentifier = AccessibilityIdentifiers.AntigenProfile.Create.birthDateTextField
		birthDateNameTextField.keyboardType = .default
		birthDateNameTextField.inputView = birthdayPicker
		contentView.addSubview(birthDateNameTextField)
		textFields.append(birthDateNameTextField)
		// addressLineTextField
		addressLineTextField = textField()
		addressLineTextField.placeholder = AppStrings.AntigenProfile.Create.streetTextFieldPlaceholder
		addressLineTextField.accessibilityIdentifier = AccessibilityIdentifiers.AntigenProfile.Create.streetTextField
		addressLineTextField.keyboardType = .default
		contentView.addSubview(addressLineTextField)
		textFields.append(addressLineTextField)
		// postalCodeTextField
		postalCodeTextField = textField()
		postalCodeTextField.placeholder = AppStrings.AntigenProfile.Create.postalCodeTextFieldPlaceholder
		postalCodeTextField.accessibilityIdentifier = AccessibilityIdentifiers.AntigenProfile.Create.postalCodeTextField
		postalCodeTextField.keyboardType = .numberPad
		contentView.addSubview(postalCodeTextField)
		textFields.append(postalCodeTextField)
		// cityTextField
		cityTextField = textField()
		cityTextField.placeholder = AppStrings.AntigenProfile.Create.cityTextFieldPlaceholder
		cityTextField.accessibilityIdentifier = AccessibilityIdentifiers.AntigenProfile.Create.cityTextField
		cityTextField.keyboardType = .default
		contentView.addSubview(cityTextField)
		textFields.append(cityTextField)
		// phoneNumberTextField
		phoneNumberTextField = textField()
		phoneNumberTextField.placeholder = AppStrings.AntigenProfile.Create.phoneNumberTextFieldPlaceholder
		phoneNumberTextField.accessibilityIdentifier = AccessibilityIdentifiers.AntigenProfile.Create.phoneNumberTextField
		phoneNumberTextField.keyboardType = .phonePad
		contentView.addSubview(phoneNumberTextField)
		textFields.append(phoneNumberTextField)
		// emailAddressTextField
		emailAddressTextField = textField()
		emailAddressTextField.placeholder = AppStrings.AntigenProfile.Create.emailAddressTextFieldPlaceholder
		emailAddressTextField.accessibilityIdentifier = AccessibilityIdentifiers.AntigenProfile.Create.emailAddressTextField
		emailAddressTextField.keyboardType = .emailAddress
		contentView.addSubview(emailAddressTextField)
		textFields.append(emailAddressTextField)
		// setup constrinats
		let inset: CGFloat = 23
		NSLayoutConstraint.activate([
			// firstNameTextField
			firstNameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: inset),
			firstNameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -inset),
			firstNameTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: inset),
			firstNameTextField.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -inset),
			// lastNameTextField
			lastNameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: inset),
			lastNameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -inset),
			lastNameTextField.topAnchor.constraint(equalTo: firstNameTextField.bottomAnchor, constant: 7),
			lastNameTextField.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -inset),
			// birthDateNameTextField
			birthDateNameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: inset),
			birthDateNameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -inset),
			birthDateNameTextField.topAnchor.constraint(equalTo: lastNameTextField.bottomAnchor, constant: 7),
			birthDateNameTextField.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -inset),
			// addressLineTextField
			addressLineTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: inset),
			addressLineTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -inset),
			addressLineTextField.topAnchor.constraint(equalTo: birthDateNameTextField.bottomAnchor, constant: 7),
			addressLineTextField.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -inset),
			// postalCodeTextField
			postalCodeTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: inset),
			postalCodeTextField.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -inset),
			postalCodeTextField.topAnchor.constraint(equalTo: addressLineTextField.bottomAnchor, constant: 7),
			postalCodeTextField.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -inset),
			postalCodeTextField.widthAnchor.constraint(equalTo: addressLineTextField.widthAnchor, multiplier: 0.4),
			// cityTextField
			cityTextField.leadingAnchor.constraint(equalTo: postalCodeTextField.trailingAnchor, constant: 7),
			cityTextField.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -inset),
			cityTextField.topAnchor.constraint(equalTo: addressLineTextField.bottomAnchor, constant: 7),
			cityTextField.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -inset),
			// phoneNumberTextField
			phoneNumberTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: inset),
			phoneNumberTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -inset),
			phoneNumberTextField.topAnchor.constraint(equalTo: cityTextField.bottomAnchor, constant: 7),
			phoneNumberTextField.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -inset),
			// emailAddressTextField
			emailAddressTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: inset),
			emailAddressTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -inset),
			emailAddressTextField.topAnchor.constraint(equalTo: phoneNumberTextField.bottomAnchor, constant: 7),
			emailAddressTextField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -inset)
		])
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
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
