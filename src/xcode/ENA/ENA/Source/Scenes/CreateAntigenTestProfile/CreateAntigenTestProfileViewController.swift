////
// 🦠 Corona-Warn-App
//

import UIKit

class CreateAntigenTestProfileViewController: UIViewController, FooterViewHandling, DismissHandling, UITextFieldDelegate {

	// MARK: - Init

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
		view.endEditing(true)
	}

	// MARK: - Public

	// MARK: - Internal

	// MARK: - Private

	private let viewModel: CreateAntigenTestProfileViewModel
	private let didTapSave: () -> Void
	private let dismiss: () -> Void

	private func setupView() {
		// navigationItem
		parent?.navigationItem.title = AppStrings.AntigenProfile.Create.title
		parent?.navigationItem.rightBarButtonItem = dismissHandlingCloseBarButton
		// view
		view.backgroundColor = .enaColor(for: .background)
		// scrollView
		let scrollView = UIScrollView()
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
		scrollView.addSubview(firstNameTextField)
		
		// setup constrinats
		NSLayoutConstraint.activate([
			// scrollView
			scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			scrollView.topAnchor.constraint(equalTo: view.topAnchor),
			scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			// descriptionLabel
			descriptionLabel.leadingAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.leadingAnchor, constant: inset),
			descriptionLabel.trailingAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.trailingAnchor, constant: -inset),
			descriptionLabel.topAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.topAnchor, constant: inset),
			descriptionLabel.bottomAnchor.constraint(lessThanOrEqualTo: scrollView.safeAreaLayoutGuide.bottomAnchor, constant: -inset),
			// firstNameTextField
			firstNameTextField.leadingAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.leadingAnchor, constant: inset),
			firstNameTextField.trailingAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.trailingAnchor, constant: -inset),
			firstNameTextField.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: inset),
			firstNameTextField.bottomAnchor.constraint(lessThanOrEqualTo: scrollView.safeAreaLayoutGuide.bottomAnchor, constant: -inset),
		])
	}
	
	private func textField () -> ENATextField {
		let textField = ENATextField(frame: .zero)
		//textField.backgroundColor = .enaColor(for: .backgroundLightGray)
		textField.clearButtonMode = .whileEditing
		textField.textColor = .enaColor(for: .textPrimary1)
		
		textField.autocorrectionType = .no
		textField.isUserInteractionEnabled = true
		textField.clearButtonMode = .whileEditing
		textField.spellCheckingType = .no
		textField.smartQuotesType = .no
		
		textField.returnKeyType = .done
		textField.delegate = self
		textField.layer.borderWidth = 0
		textField.translatesAutoresizingMaskIntoConstraints = false
		textField.heightAnchor.constraint(greaterThanOrEqualToConstant: 40.0).isActive = true
		return textField
	}
}
