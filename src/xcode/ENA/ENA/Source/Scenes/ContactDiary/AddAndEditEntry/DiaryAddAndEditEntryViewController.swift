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
		self.dismiss = dismiss

		super.init(nibName: nil, bundle: nil)

		view.backgroundColor = .enaColor(for: .background)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()

		navigationController?.navigationBar.prefersLargeTitles = true

		setupBindings()
		setupView()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		DispatchQueue.main.async { [weak self] in
			self?.entryTextField.becomeFirstResponder()
		}
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		entryTextField.resignFirstResponder()
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
		entryTextField.resignFirstResponder()
		viewModel.save()
		entryTextField.resignFirstResponder()
		dismiss()
		return false
	}

	// MARK: - ENANavigationControllerWithFooterChild

	func navigationController(_ navigationController: ENANavigationControllerWithFooter, didTapPrimaryButton button: UIButton) {
		viewModel.save()
		entryTextField.resignFirstResponder()
		dismiss()
	}

	// MARK: - DismissHandling

	func wasAttemptedToBeDismissed() {
		entryTextField.resignFirstResponder()
		dismiss()
	}

	// MARK: - Private

	private let viewModel: DiaryAddAndEditEntryViewModel
	private let dismiss: () -> Void

	private var entryTextField: DiaryEntryTextField!
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
		viewModel.$textInput.sink { [navigationFooterItem] updatedText in
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

		entryTextField = DiaryEntryTextField(frame: .zero)
		entryTextField.clearButtonMode = .whileEditing
		entryTextField.placeholder = viewModel.placeholderText
		entryTextField.textColor = .enaColor(for: .textPrimary1)
		entryTextField.autocorrectionType = .no
		entryTextField.autocapitalizationType = .sentences
		entryTextField.spellCheckingType = .no
		entryTextField.smartQuotesType = .no
		entryTextField.keyboardAppearance = .default
		entryTextField.returnKeyType = .done
		entryTextField.addTarget(self, action: #selector(textValueChanged(sender:)), for: .editingChanged)
		entryTextField.delegate = self
		entryTextField.text = viewModel.textInput

		entryTextField.translatesAutoresizingMaskIntoConstraints = false
		entryTextField.isUserInteractionEnabled = true
		contentView.addSubview(entryTextField)

		NSLayoutConstraint.activate([
			entryTextField.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.0),
			entryTextField.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.0),
			entryTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 39.0),
			entryTextField.heightAnchor.constraint(greaterThanOrEqualToConstant: 40.0)
		])

		footerView?.isHidden = false
	}

	@objc
	private func textValueChanged(sender: UITextField) {
		viewModel.update(sender.text)
	}

}
