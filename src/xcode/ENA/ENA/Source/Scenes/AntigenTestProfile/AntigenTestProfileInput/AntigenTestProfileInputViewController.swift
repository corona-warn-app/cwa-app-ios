////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class AntigenTestProfileInputViewController: UITableViewController, FooterViewHandling, DismissHandling, UITextFieldDelegate {

	// MARK: - Init

	deinit {
		cancellables.forEach { $0.cancel() }
	}
	
	init(
		viewModel: AntigenTestProfileInputViewModel,
		store: AntigenTestProfileStoring,
		didTapSave: @escaping (AntigenTestProfile) -> Void,
		dismiss: @escaping () -> Void
	) {
		self.viewModel = viewModel
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
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		// dismiss any presented keyboard
		view.endEditing(true)
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return Row.allCases.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch Row(rawValue: indexPath.row) {
		case .description:
			guard let cell = tableView.dequeueReusableCell(withIdentifier: AntigenTestProfileInputDescriptionCell.reuseIdentifier, for: indexPath) as? AntigenTestProfileInputDescriptionCell else {
				fatalError("Wrong cell")
			}
			return cell
		case .inputFields:
			guard let cell = tableView.dequeueReusableCell(withIdentifier: AntigenTestProfileInputCell.reuseIdentifier, for: indexPath) as? AntigenTestProfileInputCell else {
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
				cell.birthDateNameTextField.text = dateOfBirthFormatter.string(from: date)
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
		case .none:
			fatalError("Could not init `Row` from indexPath.row")
		}
	}
	
	// MARK: - Protocol FooterViewHandling

	func didTapFooterViewButton(_ type: FooterViewModel.ButtonType) {
		guard case .primary = type else {
			return
		}
		viewModel.save()
		didTapSave(viewModel.antigenTestProfile)
	}

	// MARK: - Protocol DismissHandling

	func wasAttemptedToBeDismissed() {
		dismiss()
	}
	
	// MARK: - Protocol UITextFieldDelegate

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		guard textField.returnKeyType == .next else {
			textField.resignFirstResponder()
			return true
		}
		if let cell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? AntigenTestProfileInputCell,
		   let currentIndex = cell.textFields.firstIndex(of: textField), (currentIndex + 1) < cell.textFields.count {
			cell.textFields[currentIndex + 1].becomeFirstResponder()
		} else {
			textField.resignFirstResponder()
		}
		return true
	}
	
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		// filtering out emojis and any other unwanted characters. These are not wanted in the test profile.
		var string = string
		
		if string.last?.isWhitespace == true { // possible keyboard suggestion
			// -> remove last character and pass that on to validation below
			let lastIndex = string.index(string.endIndex, offsetBy: -1)
			string.remove(at: lastIndex)
		}
		
		return string.trimmingCharacters(in: CharacterSet.alphanumerics).isEmpty
			|| string.trimmingCharacters(in: CharacterSet.punctuationCharacters).isEmpty
			|| string.trimmingCharacters(in: CharacterSet.symbols).isEmpty
			|| string.trimmingCharacters(in: CharacterSet.urlHostAllowed).isEmpty
			|| string.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty
			|| string.contains(where: { $0 == "@" })
	}
	
	// MARK: - Private
	
	enum Row: Int, CaseIterable {
		case description
		case inputFields
	}

	// MARK: - Private

	private var viewModel: AntigenTestProfileInputViewModel
	private let didTapSave: (AntigenTestProfile) -> Void
	private let dismiss: () -> Void
	private let dateOfBirthFormatter = AntigenTestProfileViewModel.dateOfBirthFormatter()
	private var cancellables = [OpenCombine.AnyCancellable]()

	private func setupView() {

		navigationItem.title = AppStrings.AntigenProfile.Create.title
		navigationItem.rightBarButtonItem = dismissHandlingCloseBarButton

		view.backgroundColor = .enaColor(for: .background)

		tableView.separatorStyle = .none
		tableView.register(AntigenTestProfileInputDescriptionCell.self, forCellReuseIdentifier: AntigenTestProfileInputDescriptionCell.reuseIdentifier)
		tableView.register(AntigenTestProfileInputCell.self, forCellReuseIdentifier: AntigenTestProfileInputCell.reuseIdentifier)
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
		viewModel.update(nil, keyPath: \.dateOfBirth)
	}
	
	@objc
	private func dateOfBirthDidChange(datePicker: UIDatePicker) {
		viewModel.update(datePicker.date, keyPath: \.dateOfBirth)
		if let cell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? AntigenTestProfileInputCell {
			cell.textFields[2].text = dateOfBirthFormatter.string(from: datePicker.date)
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
		viewModel.update(textField.text, keyPath: \.email)
	}
	
}
