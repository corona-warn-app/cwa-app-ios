////
// 🦠 Corona-Warn-App
//

import UIKit
import Combine

class DiaryAddAndEditEntryViewController: UIViewController {

	// MARK: - Init

	init(
		mode: DiaryAddAndEditEntryViewModel.Mode,
		diaryService: DiaryService,
		onDismiss: @escaping () -> Void
	) {
		self.viewModel = DiaryAddAndEditEntryViewModel(mode: mode, diaryService: diaryService)
		self.onDismiss = onDismiss

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
				self?.onDismiss()
			}
		)
		navigationController?.navigationBar.prefersLargeTitles = true
		navigationItem.largeTitleDisplayMode = .always

		setupView()
		setupBindiungs()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		entryTextField.becomeFirstResponder()
	}

	override var navigationItem: UINavigationItem {
		navigationFooterItem
	}

	// MARK: - Private

	private let viewModel: DiaryAddAndEditEntryViewModel
	private let onDismiss: () -> Void

	private var entryTextField: DiaryEntryTextFiled!
	private var bindings: [AnyCancellable] = []

	private lazy var navigationFooterItem: ENANavigationFooterItem = {
		let item = ENANavigationFooterItem()

		item.primaryButtonTitle = AppStrings.ContactDiary.Information.primaryButtonTitle
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

		entryTextField = DiaryEntryTextFiled(frame: .zero, xDeltaInset: 14.0)
		entryTextField.placeholder = viewModel.placeholderText
		entryTextField.textColor = .enaColor(for: .textPrimary1)
		entryTextField.autocorrectionType = .no
		entryTextField.autocapitalizationType = .sentences
		entryTextField.spellCheckingType = .no
		entryTextField.smartQuotesType = .no
		entryTextField.keyboardAppearance = .default

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

	private func setupBindiungs() {
		viewModel.$textInput.sink { [entryTextField] newText in
			entryTextField?.text = newText
		}.store(in: &bindings)
	}

}
