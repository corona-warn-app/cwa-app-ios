//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class TanInputViewController: UIViewController, FooterViewHandling {

	// MARK: - Init

	init(
		viewModel: TanInputViewModel,
		dismiss: @escaping () -> Void
	) {
		self.viewModel = viewModel
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
		view.backgroundColor = ColorCompatibility.systemBackground
		setupViews()
		setupViewModelBindings()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		DispatchQueue.main.async { [weak self] in
			self?.tanInputView.becomeFirstResponder()
		}
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		tanInputView.resignFirstResponder()
	}

	// MARK: - Protocol ENANavigationControllerWithFooterChild
	
	func didTapFooterViewButton(_ type: FooterViewModel.ButtonType) {
		viewModel.submitTan()
	}

	// MARK: - Private
	
	private let viewModel: TanInputViewModel
	private let dismiss: () -> Void
	private var bindings: Set<AnyCancellable> = []

	private var tanInputView: TanInputView!
	private var errorLabel: ENALabel!

	private var scrollView: UIScrollView!
	private var stackView: UIStackView!

	private var observer: NSKeyValueObservation?

	private func setupViews() {
		
		parent?.navigationItem.title = AppStrings.ExposureSubmissionTanEntry.title
		parent?.navigationItem.rightBarButtonItem = CloseBarButtonItem(onTap: dismiss)
		
		// scrollView needs to respect footerView, this gets done with a bottom insert by 55
		scrollView = UIScrollView(frame: view.frame)
		scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 55, right: 0.0)
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(scrollView)

		// Scrollview content size will change if we set the errorLabel to a text.
		// We need to scroll the content area to show the error, if the footer view intersects with the error label.
		// Ff the error label resets to empty we will scroll back to a negative top value to make sure scrollview
		// is in top position (-103 is basically the default value).
		observer = scrollView.observe(\UIScrollView.contentSize, options: .new, changeHandler: { [weak self] scrollView, _ in
			var y = scrollView.safeAreaInsets.top
			if let errorText = self?.errorLabel.text, !errorText.isEmpty {
				Log.debug("ContentSize changed - we might need to scroll to the visible rect by now")
				y += scrollView.contentSize.height
			}
			scrollView.scrollRectToVisible(CGRect(x: 0, y: y, width: 1, height: 1), animated: true)
		})
		
		NSLayoutConstraint.activate([
			view.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
			view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
			view.topAnchor.constraint(equalTo: scrollView.topAnchor),
			view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
		])

		stackView = UIStackView()
		stackView.axis = .vertical
		stackView.spacing = 18.0
		stackView.translatesAutoresizingMaskIntoConstraints = false
		scrollView.addSubview(stackView)

		NSLayoutConstraint.activate([
			stackView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
			stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 15.0),
			stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: 15.0),
			stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 15),
			stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
		])

		let descriptionLabel = ENALabel()
		descriptionLabel.style = .headline
		descriptionLabel.text = AppStrings.ExposureSubmissionTanEntry.description
		descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
		descriptionLabel.textColor = .enaColor(for: .textPrimary1)
		descriptionLabel.numberOfLines = 0

		tanInputView = TanInputView(frame: .zero, viewModel: viewModel)
		tanInputView.isUserInteractionEnabled = true
		tanInputView.translatesAutoresizingMaskIntoConstraints = false

		errorLabel = ENALabel()
		errorLabel.style = .headline
		errorLabel.text = ""
		errorLabel.translatesAutoresizingMaskIntoConstraints = false
		errorLabel.textColor = .enaColor(for: .textSemanticRed)
		errorLabel.numberOfLines = 0

		stackView.addArrangedSubview(descriptionLabel)
		stackView.addArrangedSubview(tanInputView)
		stackView.addArrangedSubview(errorLabel)
	}

	private func setupViewModelBindings() {
		// viewModel will notify controller to enabled / disabler primary footer button
		viewModel.$isPrimaryButtonEnabled
			.receive(on: DispatchQueue.main.ocombine)
			.sink { [weak self] isEnabled in
				self?.footerView?.setEnabled(isEnabled, button: .primary)
			}
			.store(in: &bindings)

		// viewModel will notify controller to enable / disable loadingIndicator on primary footer button
		viewModel.$isPrimaryBarButtonIsLoading
			.receive(on: DispatchQueue.main.ocombine)
			.sink { [weak self] isLoading in
				guard let self = self else {
					return
				}
				self.footerView?.setLoadingIndicator(isLoading, disable: !self.viewModel.isPrimaryButtonEnabled, button: .primary)
			}
			.store(in: &bindings)

		// viewModel will notify about changes on errorText
		viewModel.$errorText
			.receive(on: DispatchQueue.main.ocombine)
			.sink { [weak self] newErrorText in
				Log.debug("viewModel errorText did update to: \(newErrorText)")
				self?.errorLabel.text = newErrorText
			}
			.store(in: &bindings)

		viewModel.didDissMissInvalidTanAlert = { [weak self] in
			self?.footerView?.setLoadingIndicator(false, disable: true, button: .primary)
			self?.tanInputView.becomeFirstResponder()
		}
	}
}
