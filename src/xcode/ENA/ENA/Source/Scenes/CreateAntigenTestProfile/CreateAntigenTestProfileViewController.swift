////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class CreateAntigenTestProfileViewController: UIViewController, FooterViewHandling, DismissHandling, UITextFieldDelegate {

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
			if let currentIndex = textFields.firstIndex(of: textField), (currentIndex + 1) < textFields.count {
				textFields[currentIndex + 1].becomeFirstResponder()
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
	private var scrollView: UIScrollView!
	private var textFields = [UITextField]()
	private var cancellables = [OpenCombine.AnyCancellable]()

	private func setupView() {
		// date
		dateFormatter = DateFormatter()
		dateFormatter.dateStyle = .medium
		dateFormatter.timeStyle = .none
		dateFormatter.locale = Locale(identifier: "de_DE")
		// navigationItem
		parent?.navigationItem.title = AppStrings.AntigenProfile.Create.title
		parent?.navigationItem.rightBarButtonItem = dismissHandlingCloseBarButton
		// view
		view.backgroundColor = .enaColor(for: .background)
		// scrollView
		scrollView = UIScrollView()
		scrollView.contentInsetAdjustmentBehavior = .always
		if #available(iOS 13.0, *) {
			scrollView.automaticallyAdjustsScrollIndicatorInsets = true
		}
		scrollView.keyboardDismissMode = .interactive
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(scrollView)
		// descriptionLabel
		let descriptionLabel = ENALabel()
		descriptionLabel.text = AppStrings.AntigenProfile.Create.description
		descriptionLabel.style = .subheadline
		descriptionLabel.textColor = .enaColor(for: .textPrimary2)
		descriptionLabel.numberOfLines = 0
		descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
		scrollView.addSubview(descriptionLabel)
		//
		let inset: CGFloat = 23
		// firstNameTextField
		let firstNameTextField = textField()
		firstNameTextField.placeholder = AppStrings.AntigenProfile.Create.firstNameTextFieldPlaceholder
		firstNameTextField.accessibilityIdentifier = AccessibilityIdentifiers.AntigenProfile.Create.firstNameTextField
		firstNameTextField.keyboardType = .namePhonePad
		firstNameTextField.text = viewModel.antigenTestProfile.firstName
		firstNameTextField.addTarget(self, action: #selector(firstNameTextFieldDidChange(textField:)), for: .editingChanged)
		scrollView.addSubview(firstNameTextField)
		textFields.append(firstNameTextField)
		// lastNameTextField
		let lastNameTextField = textField()
		lastNameTextField.placeholder = AppStrings.AntigenProfile.Create.lastNameTextFieldPlaceholder
		lastNameTextField.accessibilityIdentifier = AccessibilityIdentifiers.AntigenProfile.Create.lastNameTextField
		lastNameTextField.keyboardType = .namePhonePad
		lastNameTextField.text = viewModel.antigenTestProfile.lastName
		lastNameTextField.addTarget(self, action: #selector(lastNameTextFieldDidChange(textField:)), for: .editingChanged)
		scrollView.addSubview(lastNameTextField)
		textFields.append(lastNameTextField)
		// datePicker
		let datePicker = UIDatePicker()
		if #available(iOS 14.0, *) {
			datePicker.addTarget(self, action: #selector(dateOfBirthDidChange(datePicker:)), for: .editingDidEnd)
		} else {
			datePicker.addTarget(self, action: #selector(dateOfBirthDidChange(datePicker:)), for: .valueChanged)
		}
		// German locale ensures 24h format.
		datePicker.locale = Locale(identifier: "de_DE")
		datePicker.datePickerMode = .date
		if #available(iOS 13.4, *) {
			datePicker.preferredDatePickerStyle = .wheels
		}
		datePicker.addTarget(self, action: #selector(dateOfBirthDidChange(datePicker:)), for: .valueChanged)
		// birthDateNameTextField
		let birthDateNameTextField = textField()
		birthDateNameTextField.placeholder = AppStrings.AntigenProfile.Create.birthDateTextFieldPlaceholder
		birthDateNameTextField.accessibilityIdentifier = AccessibilityIdentifiers.AntigenProfile.Create.birthDateTextField
		birthDateNameTextField.keyboardType = .default
		if let date = viewModel.antigenTestProfile.dateOfBirth {
			birthDateNameTextField.text = dateFormatter.string(from: date)
		}
		birthDateNameTextField.inputView = datePicker
		birthDateNameTextField.addTarget(self, action: #selector(birthDateTextFieldDidChange(textField:)), for: .editingChanged)
		scrollView.addSubview(birthDateNameTextField)
		textFields.append(birthDateNameTextField)
		// addressLineTextField
		let addressLineTextField = textField()
		addressLineTextField.placeholder = AppStrings.AntigenProfile.Create.streetTextFieldPlaceholder
		addressLineTextField.accessibilityIdentifier = AccessibilityIdentifiers.AntigenProfile.Create.streetTextField
		addressLineTextField.keyboardType = .default
		addressLineTextField.text = viewModel.antigenTestProfile.addressLine
		addressLineTextField.addTarget(self, action: #selector(addressLineTextFieldDidChange(textField:)), for: .editingChanged)
		scrollView.addSubview(addressLineTextField)
		textFields.append(addressLineTextField)
		// postalCodeTextField
		let postalCodeTextField = textField()
		postalCodeTextField.placeholder = AppStrings.AntigenProfile.Create.postalCodeTextFieldPlaceholder
		postalCodeTextField.accessibilityIdentifier = AccessibilityIdentifiers.AntigenProfile.Create.postalCodeTextField
		postalCodeTextField.keyboardType = .numberPad
		postalCodeTextField.text = viewModel.antigenTestProfile.zipCode
		postalCodeTextField.addTarget(self, action: #selector(postalCodeTextFieldDidChange(textField:)), for: .editingChanged)
		scrollView.addSubview(postalCodeTextField)
		textFields.append(postalCodeTextField)
		// cityTextField
		let cityTextField = textField()
		cityTextField.placeholder = AppStrings.AntigenProfile.Create.cityTextFieldPlaceholder
		cityTextField.accessibilityIdentifier = AccessibilityIdentifiers.AntigenProfile.Create.cityTextField
		cityTextField.keyboardType = .default
		cityTextField.text = viewModel.antigenTestProfile.city
		cityTextField.addTarget(self, action: #selector(cityTextFieldDidChange(textField:)), for: .editingChanged)
		scrollView.addSubview(cityTextField)
		textFields.append(cityTextField)
		// phoneNumberTextField
		let phoneNumberTextField = textField()
		phoneNumberTextField.placeholder = AppStrings.AntigenProfile.Create.phoneNumberTextFieldPlaceholder
		phoneNumberTextField.accessibilityIdentifier = AccessibilityIdentifiers.AntigenProfile.Create.phoneNumberTextField
		phoneNumberTextField.keyboardType = .phonePad
		phoneNumberTextField.text = viewModel.antigenTestProfile.phoneNumber
		phoneNumberTextField.addTarget(self, action: #selector(phoneNumberTextFieldDidChange(textField:)), for: .editingChanged)
		scrollView.addSubview(phoneNumberTextField)
		textFields.append(phoneNumberTextField)
		// emailAddressTextField
		let emailAddressTextField = textField()
		emailAddressTextField.placeholder = AppStrings.AntigenProfile.Create.emailAddressTextFieldPlaceholder
		emailAddressTextField.accessibilityIdentifier = AccessibilityIdentifiers.AntigenProfile.Create.emailAddressTextField
		emailAddressTextField.keyboardType = .emailAddress
		emailAddressTextField.text = viewModel.antigenTestProfile.email
		emailAddressTextField.addTarget(self, action: #selector(emailAddressTextFieldDidChange(textField:)), for: .editingChanged)
		scrollView.addSubview(emailAddressTextField)
		textFields.append(emailAddressTextField)
		
		// setup constrinats
		NSLayoutConstraint.activate([
			// scrollView
			scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
			scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
			scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
			// descriptionLabel
			descriptionLabel.leadingAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.leadingAnchor, constant: inset),
			descriptionLabel.trailingAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.trailingAnchor, constant: -inset),
			descriptionLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: inset),
			descriptionLabel.bottomAnchor.constraint(lessThanOrEqualTo: scrollView.bottomAnchor, constant: -inset),
			// firstNameTextField
			firstNameTextField.leadingAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.leadingAnchor, constant: inset),
			firstNameTextField.trailingAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.trailingAnchor, constant: -inset),
			firstNameTextField.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: inset),
			firstNameTextField.bottomAnchor.constraint(lessThanOrEqualTo: scrollView.bottomAnchor, constant: -inset),
			// lastNameTextField
			lastNameTextField.leadingAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.leadingAnchor, constant: inset),
			lastNameTextField.trailingAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.trailingAnchor, constant: -inset),
			lastNameTextField.topAnchor.constraint(equalTo: firstNameTextField.bottomAnchor, constant: 7),
			lastNameTextField.bottomAnchor.constraint(lessThanOrEqualTo: scrollView.bottomAnchor, constant: -inset),
			// birthDateNameTextField
			birthDateNameTextField.leadingAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.leadingAnchor, constant: inset),
			birthDateNameTextField.trailingAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.trailingAnchor, constant: -inset),
			birthDateNameTextField.topAnchor.constraint(equalTo: lastNameTextField.bottomAnchor, constant: 7),
			birthDateNameTextField.bottomAnchor.constraint(lessThanOrEqualTo: scrollView.bottomAnchor, constant: -inset),
			// addressLineTextField
			addressLineTextField.leadingAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.leadingAnchor, constant: inset),
			addressLineTextField.trailingAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.trailingAnchor, constant: -inset),
			addressLineTextField.topAnchor.constraint(equalTo: birthDateNameTextField.bottomAnchor, constant: 7),
			addressLineTextField.bottomAnchor.constraint(lessThanOrEqualTo: scrollView.bottomAnchor, constant: -inset),
			// postalCodeTextField
			postalCodeTextField.leadingAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.leadingAnchor, constant: inset),
			postalCodeTextField.trailingAnchor.constraint(lessThanOrEqualTo: scrollView.safeAreaLayoutGuide.trailingAnchor, constant: -inset),
			postalCodeTextField.topAnchor.constraint(equalTo: addressLineTextField.bottomAnchor, constant: 7),
			postalCodeTextField.bottomAnchor.constraint(lessThanOrEqualTo: scrollView.bottomAnchor, constant: -inset),
			postalCodeTextField.widthAnchor.constraint(equalTo: addressLineTextField.widthAnchor, multiplier: 0.4),
			// cityTextField
			cityTextField.leadingAnchor.constraint(equalTo: postalCodeTextField.trailingAnchor, constant: 7),
			cityTextField.trailingAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.trailingAnchor, constant: -inset),
			cityTextField.topAnchor.constraint(equalTo: addressLineTextField.bottomAnchor, constant: 7),
			cityTextField.bottomAnchor.constraint(lessThanOrEqualTo: scrollView.bottomAnchor, constant: -inset),
			// phoneNumberTextField
			phoneNumberTextField.leadingAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.leadingAnchor, constant: inset),
			phoneNumberTextField.trailingAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.trailingAnchor, constant: -inset),
			phoneNumberTextField.topAnchor.constraint(equalTo: cityTextField.bottomAnchor, constant: 7),
			phoneNumberTextField.bottomAnchor.constraint(lessThanOrEqualTo: scrollView.bottomAnchor, constant: -inset),
			// emailAddressTextField
			emailAddressTextField.leadingAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.leadingAnchor, constant: inset),
			emailAddressTextField.trailingAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.trailingAnchor, constant: -inset),
			emailAddressTextField.topAnchor.constraint(equalTo: phoneNumberTextField.bottomAnchor, constant: 7),
			emailAddressTextField.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -inset)
		])
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
	
	private func textField () -> ENATextField {
		let textField = ENATextField(frame: .zero)
		textField.autocorrectionType = .no
		textField.isUserInteractionEnabled = true
		textField.returnKeyType = .next
		textField.clearButtonMode = .whileEditing
		textField.spellCheckingType = .no
		textField.smartQuotesType = .no
		textField.delegate = self
		textField.layer.borderWidth = 0
		textField.translatesAutoresizingMaskIntoConstraints = false
		textField.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
		return textField
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
		textFields[2].text = dateFormatter.string(from: datePicker.date)
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
