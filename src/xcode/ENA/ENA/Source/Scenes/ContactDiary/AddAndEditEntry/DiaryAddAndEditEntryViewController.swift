////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class DiaryAddAndEditEntryViewController: UITableViewController, UITextFieldDelegate, ENANavigationControllerWithFooterChild, DismissHandling {

	// MARK: - Init

	init(
		viewModel: DiaryAddAndEditEntryViewModel,
		dismiss: @escaping () -> Void
	) {
		self.viewModel = viewModel
		self.dismiss = dismiss

		super.init(style: .plain)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()

		view.backgroundColor = .enaColor(for: .background)

		navigationItem.largeTitleDisplayMode = .always

		setupBindings()
		setupView()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		navigationController?.navigationBar.prefersLargeTitles = true
		navigationController?.navigationBar.sizeToFit()
	}

	override var navigationItem: UINavigationItem {
		navigationFooterItem
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return Row.allCases.count
	}
	
	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.heightAnchor.constraint(equalToConstant: 30).isActive = true
		return view
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: TextFieldCell.identifier, for: indexPath) as? TextFieldCell else {
			fatalError("No registered cell found")
		}
		guard let row = Row(rawValue: indexPath.row) else {
			fatalError("Something went horribly wrong")
		}
		cell.textField.tag = row.rawValue
		cell.textField.addTarget(self, action: #selector(textValueChanged(sender:)), for: .editingChanged)
		cell.textField.delegate = self
		switch row {
		case .name:
			cell.textField.accessibilityIdentifier = AccessibilityIdentifiers.ContactDiaryInformation.EditEntries.nameTextField
			cell.textField.placeholder = viewModel.namePlaceholder
			cell.textField.autocapitalizationType = .sentences
			cell.textField.keyboardType = .default
			cell.textField.returnKeyType = .continue
			cell.textField.text = viewModel.entryModel.name
		case .phoneNumber:
			cell.textField.accessibilityIdentifier = AccessibilityIdentifiers.ContactDiaryInformation.EditEntries.phoneNumberTextField
			cell.textField.placeholder = viewModel.phoneNumberPlaceholder
			cell.textField.autocapitalizationType = .none
			cell.textField.keyboardType = .phonePad
			cell.textField.returnKeyType = .continue
			cell.textField.text = viewModel.entryModel.phoneNumber
		case .email:
			cell.textField.accessibilityIdentifier = AccessibilityIdentifiers.ContactDiaryInformation.EditEntries.eMailTextField
			cell.textField.placeholder = viewModel.emailAddressPlaceholder
			cell.textField.autocapitalizationType = .none
			cell.textField.keyboardType = .emailAddress
			cell.textField.returnKeyType = .done
			cell.textField.text = viewModel.entryModel.emailAddress
		}
		return cell
	}

	// MARK: - Protocol UITextFieldDelegate

	func textFieldShouldClear(_ textField: UITextField) -> Bool {
		switch Row(rawValue: textField.tag) {
		case .name:
			viewModel.reset(keyPath: \DiaryAddAndEditEntryModel.name)
		case .phoneNumber:
			viewModel.reset(keyPath: \DiaryAddAndEditEntryModel.phoneNumber)
		case .email:
			viewModel.reset(keyPath: \DiaryAddAndEditEntryModel.emailAddress)
		default:
			Log.debug("Textfield to clear not found", log: .default)
		}
		return true
	}

	func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
		return true
	}

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		switch textField.returnKeyType {
		case .default, .done, .send:
			if !viewModel.entryModel.isEmpty {
				viewModel.save()
			}
			textField.resignFirstResponder()
			dismiss()
		case .next, .continue:
			self.textField(for: textField.tag + 1)?.becomeFirstResponder()
		default:
			Log.debug("unsupport return key type")
		}
		return false
	}

	// MARK: - ENANavigationControllerWithFooterChild

	func navigationController(_ navigationController: ENANavigationControllerWithFooter, didTapPrimaryButton button: UIButton) {
		viewModel.save()
		dismiss()
	}

	// MARK: - DismissHandling

	func wasAttemptedToBeDismissed() {
		dismiss()
	}

	// MARK: - Private

	enum Row: Int, CaseIterable {
		case name
		case phoneNumber
		case email
	}
	
	private let viewModel: DiaryAddAndEditEntryViewModel
	private let dismiss: () -> Void
	private var bindings: [AnyCancellable] = []

	private lazy var navigationFooterItem: ENANavigationFooterItem = {
		let item = ENANavigationFooterItem()

		item.primaryButtonTitle = AppStrings.ContactDiary.AddEditEntry.primaryButtonTitle
		item.isPrimaryButtonEnabled = true
		item.isSecondaryButtonHidden = true

		item.title = viewModel.title
		item.largeTitleDisplayMode = .always
		item.rightBarButtonItem = CloseBarButtonItem(
			onTap: { [weak self] in
				self?.dismiss()
			}
		)
		return item
	}()

	private func setupBindings() {
		viewModel.$entryModel.sink { [navigationFooterItem] updatedText in
			navigationFooterItem.isPrimaryButtonEnabled = !updatedText.isEmpty
		}.store(in: &bindings)
	}

	private func setupView() {
		title = viewModel.title

		tableView.separatorStyle = .none
		tableView.register(
			TextFieldCell.self,
			forCellReuseIdentifier: TextFieldCell.identifier)

		footerView?.isHidden = false
	}

	@objc
	private func textValueChanged(sender: UITextField) {
		switch Row(rawValue: sender.tag) {
		case .name:
			viewModel.update(sender.text, keyPath: \DiaryAddAndEditEntryModel.name)
		case .phoneNumber:
			viewModel.update(sender.text, keyPath: \DiaryAddAndEditEntryModel.phoneNumber)
		case .email:
			viewModel.update(sender.text, keyPath: \DiaryAddAndEditEntryModel.emailAddress)
		default:
			Log.debug("Failed to find matching textfield", log: .default)
		}
	}
	
	private func textField(for row: Int) -> UITextField? {
		guard let cell = tableView.visibleCells.first(where: { ($0 as? TextFieldCell)?.textField.tag == row }) as? TextFieldCell else {
			return nil
		}
		return cell.textField
	}
}

private final class TextFieldCell: UITableViewCell {
	
	// MARK: - Init
	
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Overrides
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		// self
		selectionStyle = .none
		// textField
		textField = DiaryEntryTextField(frame: .zero)
		textField.autocorrectionType = .no
		textField.isUserInteractionEnabled = true
		textField.clearButtonMode = .whileEditing
		textField.spellCheckingType = .no
		textField.smartQuotesType = .no
		textField.keyboardAppearance = .default
		textField.textColor = .enaColor(for: .textPrimary1)
		textField.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(textField)
		// activate constraints
		NSLayoutConstraint.activate([
			textField.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.0),
			textField.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.0),
			textField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
			textField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
			textField.heightAnchor.constraint(greaterThanOrEqualToConstant: 40.0)
		])
	}
	
	// MARK: - Internal
	
	static let identifier = "TextFieldCell"
	
	var textField: DiaryEntryTextField!
}
