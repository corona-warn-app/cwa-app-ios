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

		setupView()
		navigationItem.rightBarButtonItem = CloseBarButtonItem(
			onTap: { [weak self] in
				self?.onDismiss()
			}
		)
		navigationController?.navigationBar.prefersLargeTitles = true
		navigationItem.largeTitleDisplayMode = .always

		setupBindiungs()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		entryTextField.becomeFirstResponder()
	}

	// MARK: - Private

	private let viewModel: DiaryAddAndEditEntryViewModel
	private let onDismiss: () -> Void

	private var entryTextField: DiaryEntryTextFiled!
	private var bindings: [AnyCancellable] = []

	private func setupView() {
		title = viewModel.title

		let scrollView = UIScrollView(frame: view.frame)
		scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 55, right: 0.0)
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
		entryTextField.placeholder = "Bezeichung"
		entryTextField.textColor = .enaColor(for: .textPrimary1)
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
