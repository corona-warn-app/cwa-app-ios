////
// 🦠 Corona-Warn-App
//

import UIKit
import Combine

class DiaryAddAndEditEntryViewController: UIViewController, UITextFieldDelegate, ENANavigationControllerWithFooterChild {

	// MARK: - Init

	init(
		viewModel: DiaryAddAndEditEntryViewModel
	) {
		self.viewModel = viewModel

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

		navigationItem.rightBarButtonItem = CloseBarButtonItem(
			onTap: { [weak self] in
				self?.viewModel.dismiss()
			}
		)
		navigationController?.navigationBar.prefersLargeTitles = true
		navigationItem.largeTitleDisplayMode = .always

		setupView()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		entryTextField.becomeFirstResponder()
	}

	override var navigationItem: UINavigationItem {
		navigationFooterItem
	}

	// MARK: - ENANavigationControllerWithFooterChild

	func navigationController(_ navigationController: ENANavigationControllerWithFooter, didTapPrimaryButton button: UIButton) {
		viewModel.save()
	}

	// MARK: - Protocol UITextFieldDelegate

	func textFieldDidEndEditing(_ textField: UITextField) {
		viewModel.update(textField.text)
	}

	// MARK: - Private

	private let viewModel: DiaryAddAndEditEntryViewModel

	private var entryTextField: DiaryEntryTextFiled!
	private var bindings: [AnyCancellable] = []

	private lazy var navigationFooterItem: ENANavigationFooterItem = {
		let item = ENANavigationFooterItem()

		item.primaryButtonTitle = AppStrings.ContactDiary.AddEditEntry.primaryButtonTitle
		item.isPrimaryButtonEnabled = true
		item.isSecondaryButtonHidden = true

		item.title = viewModel.title

		return item
	}()

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
			contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
			contentView.widthAnchor.constraint(equalTo: view.widthAnchor)
		])

		entryTextField = DiaryEntryTextFiled(frame: .zero)
		entryTextField.placeholder = viewModel.placeholderText
		entryTextField.textColor = .enaColor(for: .textPrimary1)
		entryTextField.autocorrectionType = .no
		entryTextField.autocapitalizationType = .sentences
		entryTextField.spellCheckingType = .no
		entryTextField.smartQuotesType = .no
		entryTextField.keyboardAppearance = .default
		entryTextField.addTarget(self, action: #selector(textValueChanged(sender:)), for: .editingChanged)
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
	}

	@objc
	private func textValueChanged(sender: UITextField) {
		viewModel.update(sender.text)
	}

}
