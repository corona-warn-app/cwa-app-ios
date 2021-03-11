////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class DiaryAddAndEditEntryViewController: UIViewController, UITextFieldDelegate, ENANavigationControllerWithFooterChild, DismissHandling {

	// MARK: - Init

	init(
		textFieldsManager: TextFieldsManager = TextFieldsManager(),
		viewModel: DiaryAddAndEditEntryViewModel,
		dismiss: @escaping () -> Void
	) {
		self.viewModel = viewModel
		self.textFieldsManager = textFieldsManager
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
		
		NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		DispatchQueue.main.async { [weak self] in
			self?.textFieldsManager.nextFirstResponder()
		}
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		textFieldsManager.resignFirstResponder()
		
		NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
		NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
	}

	override var navigationItem: UINavigationItem {
		navigationFooterItem
	}

	// MARK: - Protocol UITextFieldDelegate

	func textFieldShouldClear(_ textField: UITextField) -> Bool {
		guard let keyPath = textFieldsManager.keyPath(for: textField) else {
			Log.debug("Textfield to clear not found", log: .default)
			return false
		}
		viewModel.reset(keyPath: keyPath)
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
			textFieldsManager.resignFirstResponder()
			dismiss()
		case .next, .continue:
			textFieldsManager.nextFirstResponder()
		default:
			Log.debug("unsupport return key type")
		}
		return false
	}

	// MARK: - ENANavigationControllerWithFooterChild

	func navigationController(_ navigationController: ENANavigationControllerWithFooter, didTapPrimaryButton button: UIButton) {
		viewModel.save()
		textFieldsManager.resignFirstResponder()
		dismiss()
	}

	// MARK: - DismissHandling

	func wasAttemptedToBeDismissed() {
		textFieldsManager.resignFirstResponder()
		dismiss()
	}

	// MARK: - Private

	private var scrollView: UIScrollView!
	private let viewModel: DiaryAddAndEditEntryViewModel
	private let textFieldsManager: TextFieldsManager
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

		scrollView = UIScrollView(frame: view.frame)
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
		nameTextField.accessibilityIdentifier = AccessibilityIdentifiers.ContactDiaryInformation.EditEntries.nameTextField
		nameTextField.isUserInteractionEnabled = true
		nameTextField.clearButtonMode = .whileEditing
		nameTextField.placeholder = viewModel.namePlaceholder
		nameTextField.textColor = .enaColor(for: .textPrimary1)
		nameTextField.autocorrectionType = .no
		nameTextField.autocapitalizationType = .sentences
		nameTextField.spellCheckingType = .no
		nameTextField.smartQuotesType = .no
		nameTextField.keyboardAppearance = .default
		nameTextField.keyboardType = .default
		nameTextField.returnKeyType = .continue
		nameTextField.addTarget(self, action: #selector(textValueChanged(sender:)), for: .editingChanged)
		nameTextField.delegate = self
		nameTextField.text = viewModel.entryModel.name

		let phoneNumberTextField = DiaryEntryTextField(frame: .zero)
		phoneNumberTextField.translatesAutoresizingMaskIntoConstraints = false
		phoneNumberTextField.accessibilityIdentifier = AccessibilityIdentifiers.ContactDiaryInformation.EditEntries.phoneNumberTextField
		phoneNumberTextField.isUserInteractionEnabled = true
		phoneNumberTextField.clearButtonMode = .whileEditing
		phoneNumberTextField.placeholder = viewModel.phoneNumberPlaceholder
		phoneNumberTextField.textColor = .enaColor(for: .textPrimary1)
		phoneNumberTextField.autocorrectionType = .no
		phoneNumberTextField.autocapitalizationType = .none
		phoneNumberTextField.spellCheckingType = .no
		phoneNumberTextField.smartQuotesType = .no
		phoneNumberTextField.keyboardAppearance = .default
		phoneNumberTextField.keyboardType = .phonePad
		phoneNumberTextField.returnKeyType = .continue
		phoneNumberTextField.addTarget(self, action: #selector(textValueChanged(sender:)), for: .editingChanged)
		phoneNumberTextField.delegate = self
		phoneNumberTextField.text = viewModel.entryModel.phoneNumber

		let emailTextField = DiaryEntryTextField(frame: .zero)
		emailTextField.translatesAutoresizingMaskIntoConstraints = false
		emailTextField.accessibilityIdentifier = AccessibilityIdentifiers.ContactDiaryInformation.EditEntries.eMailTextField
		emailTextField.isUserInteractionEnabled = true
		emailTextField.clearButtonMode = .whileEditing
		emailTextField.placeholder = viewModel.emailAddressPlaceholder
		emailTextField.textColor = .enaColor(for: .textPrimary1)
		emailTextField.autocorrectionType = .no
		emailTextField.autocapitalizationType = .none
		emailTextField.spellCheckingType = .no
		emailTextField.smartQuotesType = .no
		emailTextField.keyboardAppearance = .default
		emailTextField.keyboardType = .emailAddress
		emailTextField.returnKeyType = .done
		emailTextField.addTarget(self, action: #selector(textValueChanged(sender:)), for: .editingChanged)
		emailTextField.delegate = self
		emailTextField.text = viewModel.entryModel.emailAddress

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

		// register textfields with the associated key path to manage keyboard & input
		textFieldsManager.appendTextField(textfieldWithKayPath: (nameTextField, \DiaryAddAndEditEntryModel.name))
		textFieldsManager.appendTextField(textfieldWithKayPath: (phoneNumberTextField, \DiaryAddAndEditEntryModel.phoneNumber))
		textFieldsManager.appendTextField(textfieldWithKayPath: (emailTextField, \DiaryAddAndEditEntryModel.emailAddress))
	}

	@objc
	private func textValueChanged(sender: UITextField) {
		guard let entryModelKeyPath = textFieldsManager.keyPath(for: sender) else {
			Log.debug("Failed to find matching textfield", log: .default)
			return
		}
		viewModel.update(sender.text, keyPath: entryModelKeyPath)
	}
	
	@objc
	private func adjustForKeyboard(notification: Notification) {
		guard let keyboardFrameEndUserInfo = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
			  let keyboardAnimationDurationUserInfo = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber,
			  let keyboardAnimationCurveUserInfo = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber else { return }

		let keyboardScreenEndFrame = keyboardFrameEndUserInfo.cgRectValue
		let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
		
		let animationDuration = keyboardAnimationDurationUserInfo.doubleValue
		let animationCurve = keyboardAnimationCurveUserInfo.uintValue
		 
		UIView.animate(withDuration: animationDuration, delay: 0, options: UIView.AnimationOptions(rawValue: animationCurve), animations: { [weak self] in
			guard let self = self else { return }
			if notification.name == UIResponder.keyboardWillHideNotification {
				self.scrollView.contentInset = .zero
			} else {
				self.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - self.view.safeAreaInsets.bottom + (self.footerView?.bounds.height ?? 0), right: 0)
			}
		}, completion: nil)
	}

}
