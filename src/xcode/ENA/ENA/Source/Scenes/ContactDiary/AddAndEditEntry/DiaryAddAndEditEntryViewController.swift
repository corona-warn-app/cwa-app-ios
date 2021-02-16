////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class DiaryAddAndEditEntryViewController: UIViewController, UITextFieldDelegate, ENANavigationControllerWithFooterChild, DismissHandling {

	// MARK: - Init

	init(
		viewModel: DiaryAddAndEditEntryViewModel,
		dismiss: @escaping () -> Void
	) {
		self.viewModel = viewModel
		self.inputManager = TextFieldsManager()
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

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		DispatchQueue.main.async { [weak self] in
			self?.inputManager.nextFirtResponder()
		}
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		inputManager.resignFirstResponder()
	}

	override var navigationItem: UINavigationItem {
		navigationFooterItem
	}

	// MARK: - Protocol UITextFieldDelegate

	func textFieldShouldClear(_ textField: UITextField) -> Bool {
		viewModel.reset()
		return true
	}

	func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
		return true
	}

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		switch textField.returnKeyType {
		case .default, .done, .send:
			viewModel.save()
			inputManager.resignFirstResponder()
			dismiss()
		case .next, .continue:
			inputManager.nextFirtResponder()
		default:
			Log.debug("unsupport return key type")
		}
		return false
	}

	// MARK: - ENANavigationControllerWithFooterChild

	func navigationController(_ navigationController: ENANavigationControllerWithFooter, didTapPrimaryButton button: UIButton) {
		viewModel.save()
		inputManager.resignFirstResponder()
		dismiss()
	}

	// MARK: - DismissHandling

	func wasAttemptedToBeDismissed() {
		inputManager.resignFirstResponder()
		dismiss()
	}

	// MARK: - Private

	private let viewModel: DiaryAddAndEditEntryViewModel
	private let inputManager: TextFieldsManager
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

		let scrollView = UIScrollView(frame: view.frame)
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(scrollView)

		NSLayoutConstraint.activate([
			view.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
			view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
			view.topAnchor.constraint(equalTo: scrollView.topAnchor),
			view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
		])

		let contentView = UIView(frame: .zero)
		contentView.translatesAutoresizingMaskIntoConstraints = false
		scrollView.addSubview(contentView)

		NSLayoutConstraint.activate([
			contentView.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
			contentView.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
			contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
			contentView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			contentView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
			contentView.widthAnchor.constraint(equalTo: view.widthAnchor)
		])

		let nameTextField = DiaryEntryTextField(frame: .zero)
		nameTextField.translatesAutoresizingMaskIntoConstraints = false
		nameTextField.isUserInteractionEnabled = true
		nameTextField.clearButtonMode = .whileEditing
		nameTextField.placeholder = viewModel.placeholderText
		nameTextField.textColor = .enaColor(for: .textPrimary1)
		nameTextField.autocorrectionType = .no
		nameTextField.autocapitalizationType = .sentences
		nameTextField.spellCheckingType = .no
		nameTextField.smartQuotesType = .no
		nameTextField.keyboardAppearance = .default
		nameTextField.returnKeyType = .continue
		nameTextField.addTarget(self, action: #selector(textValueChanged(sender:)), for: .editingChanged)
		nameTextField.delegate = self
		nameTextField.text = viewModel.entryModel.name

		let phoneNumberTextField = DiaryEntryTextField(frame: .zero)
		phoneNumberTextField.translatesAutoresizingMaskIntoConstraints = false
		phoneNumberTextField.isUserInteractionEnabled = true
		phoneNumberTextField.clearButtonMode = .whileEditing
		phoneNumberTextField.placeholder = "NYD" //viewModel.placeholderText
		phoneNumberTextField.textColor = .enaColor(for: .textPrimary1)
		phoneNumberTextField.autocorrectionType = .no
		phoneNumberTextField.autocapitalizationType = .sentences
		phoneNumberTextField.spellCheckingType = .no
		phoneNumberTextField.smartQuotesType = .no
		phoneNumberTextField.keyboardAppearance = .default
		phoneNumberTextField.returnKeyType = .continue
		phoneNumberTextField.addTarget(self, action: #selector(textValueChanged(sender:)), for: .editingChanged)
		phoneNumberTextField.delegate = self
//		phoneNumberTextField.text = viewModel.textInput

		let emailTextField = DiaryEntryTextField(frame: .zero)
		emailTextField.translatesAutoresizingMaskIntoConstraints = false
		emailTextField.isUserInteractionEnabled = true
		emailTextField.clearButtonMode = .whileEditing
		emailTextField.placeholder = "NYD" //viewModel.placeholderText
		emailTextField.textColor = .enaColor(for: .textPrimary1)
		emailTextField.autocorrectionType = .no
		emailTextField.autocapitalizationType = .sentences
		emailTextField.spellCheckingType = .no
		emailTextField.smartQuotesType = .no
		emailTextField.keyboardAppearance = .default
		emailTextField.returnKeyType = .done
		emailTextField.addTarget(self, action: #selector(textValueChanged(sender:)), for: .editingChanged)
		emailTextField.delegate = self
//		emailTextField.text = viewModel.textInput

		nameTextField.translatesAutoresizingMaskIntoConstraints = false
		nameTextField.isUserInteractionEnabled = true

		let stackView = UIStackView(arrangedSubviews: [nameTextField, phoneNumberTextField, emailTextField])
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.alignment = .fill
		stackView.axis = .vertical
		stackView.spacing = 8.0
		contentView.addSubview(stackView)

		NSLayoutConstraint.activate([
			stackView.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.0),
			stackView.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.0),
			stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 39.0),
			nameTextField.heightAnchor.constraint(greaterThanOrEqualToConstant: 40.0),
			phoneNumberTextField.heightAnchor.constraint(greaterThanOrEqualToConstant: 40.0),
			emailTextField.heightAnchor.constraint(greaterThanOrEqualToConstant: 40.0)
		])

		footerView?.isHidden = false

		// register textfields with the associated keypath to manage keyboard & input
		inputManager.appendTextField(textfiledWithKayPath: (nameTextField, \DiaryAddAndEditEntryModel.name))
		inputManager.appendTextField(textfiledWithKayPath: (phoneNumberTextField, \DiaryAddAndEditEntryModel.phoneNumber))
		inputManager.appendTextField(textfiledWithKayPath: (emailTextField, \DiaryAddAndEditEntryModel.emailAddress))
	}

	@objc
	private func textValueChanged(sender: UITextField) {
		guard let entryModelKeyPath = inputManager.keyPath(for: sender) else {
			Log.debug("Failed to find matching textfiled", log: .default)
			return
		}
		viewModel.update(sender.text, keyPath: entryModelKeyPath)
	}

}
