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
			guard let cell = tableView.dequeueReusableCell(withIdentifier: CreateAntigenTestProfileDescriptionCell.reuseIdentifier, for: indexPath) as? CreateAntigenTestProfileDescriptionCell else {
				fatalError("Wrong cell")
			}
			return cell
		case 1:
			guard let cell = tableView.dequeueReusableCell(withIdentifier: CreateAntigenTestProfileInputCell.reuseIdentifier, for: indexPath) as? CreateAntigenTestProfileInputCell else {
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
				cell.birthDateNameTextField.text = DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none)
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
			if let cell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? CreateAntigenTestProfileInputCell,
			   let currentIndex = cell.textFields.firstIndex(of: textField), (currentIndex + 1) < cell.textFields.count {
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

	private var viewModel: CreateAntigenTestProfileViewModel
	private let didTapSave: () -> Void
	private let dismiss: () -> Void
	
	private var cancellables = [OpenCombine.AnyCancellable]()

	private func setupView() {
		// navigationItem
		parent?.navigationItem.title = AppStrings.AntigenProfile.Create.title
		parent?.navigationItem.rightBarButtonItem = dismissHandlingCloseBarButton
		// view
		view.backgroundColor = .enaColor(for: .background)
		// tableView
		tableView.separatorStyle = .none
		tableView.register(CreateAntigenTestProfileDescriptionCell.self, forCellReuseIdentifier: CreateAntigenTestProfileDescriptionCell.reuseIdentifier)
		tableView.register(CreateAntigenTestProfileInputCell.self, forCellReuseIdentifier: CreateAntigenTestProfileInputCell.reuseIdentifier)
		tableView.keyboardDismissMode = .interactive
	}
	
	private func setupBindings() {
		viewModel.$antigenTestProfile
			.sink { [weak self] antigenTestProfile in
				self?.footerView?.setEnabled(antigenTestProfile.isEligibleToSave, button: .primary)
			}
			.store(in: &cancellables)
	}
	
	@objc
	private func firstNameTextFieldDidChange(textField: UITextField) {
		viewModel.update(textField.text, keyPath: \.firstName)
	}
	
	@objc
	private func lastNameTextFieldDidChange(textField: UITextField) {
		viewModel.update(textField.text, keyPath: \.lastName)
	}
	
	@objc
	private func birthDateTextFieldDidChange(textField: UITextField) {
		viewModel.antigenTestProfile.dateOfBirth = nil
	}
	
	@objc
	private func dateOfBirthDidChange(datePicker: UIDatePicker) {
		viewModel.antigenTestProfile.dateOfBirth = datePicker.date
		if let cell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? CreateAntigenTestProfileInputCell {
			cell.textFields[2].text = DateFormatter.localizedString(from: datePicker.date, dateStyle: .medium, timeStyle: .none)
		}
	}
	
	@objc
	private func addressLineTextFieldDidChange(textField: UITextField) {
		viewModel.update(textField.text, keyPath: \.addressLine)
	}
	
	@objc
	private func postalCodeTextFieldDidChange(textField: UITextField) {
		viewModel.update(textField.text, keyPath: \.zipCode)
	}
	
	@objc
	private func cityTextFieldDidChange(textField: UITextField) {
		viewModel.update(textField.text, keyPath: \.city)
	}
	
	@objc
	private func phoneNumberTextFieldDidChange(textField: UITextField) {
		viewModel.update(textField.text, keyPath: \.phoneNumber)
	}
	
	@objc
	private func emailAddressTextFieldDidChange(textField: UITextField) {
		viewModel.update( textField.text, keyPath: \.email)
	}
	
	
}
