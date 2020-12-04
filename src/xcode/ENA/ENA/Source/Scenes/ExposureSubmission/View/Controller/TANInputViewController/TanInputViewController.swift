//
// 🦠 Corona-Warn-App
//

import UIKit
import Combine

class TanInputViewController: UIViewController, ENANavigationControllerWithFooterChild {

	// MARK: - Init

	init(
		viewModel: TanInputViewModel
	) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Overrides
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .systemBackground
		setupViews()
		setupViewModelBindings()

		footerView?.isHidden = false

		// disable keyboadr notifications for the moment
//		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeShown(note:)), name: UIResponder.keyboardWillShowNotification, object: nil)
	}
	
	override var navigationItem: UINavigationItem {
		navigationFooterItem
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		DispatchQueue.main.async { [weak self] in
			self?.tanInputView.becomeFirstResponder()
		}
	}

	// MARK: - Protocol ENANavigationControllerWithFooterChild
	
	func navigationController(_ navigationController: ENANavigationControllerWithFooter, didTapPrimaryButton button: UIButton) {
		tanInputView.resignFirstResponder()
		viewModel.submitTan()
	}

	// MARK: - Public
	
	// MARK: - Internal

	func togglePrimaryNavigationButton() {
		navigationFooterItem?.isPrimaryButtonLoading.toggle()
		navigationFooterItem?.isPrimaryButtonEnabled.toggle()
	}

	// MARK: - Private
	
	private let viewModel: TanInputViewModel
	private var bindings: Set<AnyCancellable> = []

	private var tanInputView: TanInputView!
	private var errorLabel: ENALabel!

	private var scrollView: UIScrollView!
	private var stackView: UIStackView!

	private lazy var navigationFooterItem: ENANavigationFooterItem = {
		let item = ENANavigationFooterItem()
		item.primaryButtonTitle = AppStrings.ExposureSubmissionTanEntry.submit
		item.isPrimaryButtonEnabled = false
		item.isSecondaryButtonHidden = true
		item.title = AppStrings.ExposureSubmissionTanEntry.title
		return item
	}()

	private var observer: NSKeyValueObservation?

	private func setupViews() {
		// scrolliew needs respect footerView, this gets done with a bottom insert by 55
		scrollView = UIScrollView(frame: view.frame)
		scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 55, right: 0.0)
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(scrollView)

		// scrollview content size will chnage if we set the errorLabel to a text
		// we need to scroll content area to show the error if the footerView intersects with the error label
		// if the error label resets to nil  we will scroll back to a minus top value to make sure scrollview
		// is in top position (-103 is basically the default value)
		observer = scrollView.observe(\UIScrollView.contentSize, options: .new, changeHandler: { [weak self] scrollView, _ in
			if self?.errorLabel.text != nil {
				guard let self = self,
					  let footerView = self.footerView else {
					return
				}

				DispatchQueue.main.async {
					let footerViewRect = footerView.convert(footerView.bounds, to: scrollView)
					if footerViewRect.intersects(self.stackView.frame) {
						Log.debug("ContentSize changed - we might need to scroll to the visible rect by now")
						let delta = footerViewRect.height - (self.stackView.frame.origin.y + self.stackView.frame.size.height) + scrollView.contentOffset.y
						let bottomOffset = CGPoint(x: 0, y: delta)
						scrollView.setContentOffset(bottomOffset, animated: true)
					}
				}
			} else {
				let bottomOffset = CGPoint(x: 0, y: -103)
				scrollView.setContentOffset(bottomOffset, animated: true)
			}
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
			stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 15.0),
			stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: 15.0),
			stackView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
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
		errorLabel.text = nil
		errorLabel.translatesAutoresizingMaskIntoConstraints = false
		errorLabel.textColor = .enaColor(for: .textSemanticRed)
		errorLabel.numberOfLines = 0

		stackView.addArrangedSubview(descriptionLabel)
		stackView.addArrangedSubview(tanInputView)
		stackView.addArrangedSubview(errorLabel)
	}

	private func setupViewModelBindings() {
		// viewModel will notify controller to enabled / disabler Primary Footer Button
		// this will happend while ExposureSubmissionService is making a network request
		viewModel.$isPrimaryBarButtonDisabled.sink { [weak self] isDisabled in
			DispatchQueue.main.async {
				self?.navigationFooterItem?.isPrimaryButtonEnabled = !isDisabled
				self?.navigationFooterItem?.isPrimaryButtonLoading = isDisabled
			}
		}.store(in: &bindings)

		// wieModel will notify about text (tan) changes here
		viewModel.$text.sink { [weak self] newText in
			Log.debug("viewModel text did uodate to: \(newText)")
			DispatchQueue.main.async {
				self?.navigationFooterItem?.isPrimaryButtonEnabled = self?.viewModel.isChecksumValid ?? false
			}

		}.store(in: &bindings)

		// viewModel will notify about changes on errorText
		viewModel.$errorText.sink { [weak self] newErrorText in
			Log.debug("viewModel errorText did uodate to: \(newErrorText)")

			DispatchQueue.main.async {
				self?.errorLabel.text = newErrorText.isEmpty ? nil : newErrorText
			}

		}.store(in: &bindings)
	}

}
