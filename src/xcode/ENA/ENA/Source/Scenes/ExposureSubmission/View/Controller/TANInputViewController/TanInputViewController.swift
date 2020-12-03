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
		setupViewModel()

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
	
	// MARK: - Protocol ENATanInputDelegate
/*
	func enaTanInputDidBeginEditing(_ tanInput: ENATanInput) {
		let rect = contentView.convert(tanInput.frame, from: tanInput)
		scrollView.scrollRectToVisible(rect, animated: true)
	}
*/

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

	private func setupViews() {
		scrollView = UIScrollView(frame: view.frame)
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(scrollView)

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

	private func setupViewModel() {
		// viewModel will notify controller to enabled / disabler Primary Footer Button
		// this will happend while ExposureSubmissionService is making a network request
		viewModel.$isPrimaryBarButtonDisabled.sink { [weak self] isDisabled in
			DispatchQueue.main.async {
				self?.navigationFooterItem?.isPrimaryButtonEnabled = !isDisabled
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

		// viewModel will notify that tanInputView has become the first responder
		viewModel.$tanInputViewIsFirstResponder.sink { [weak self] isFirstResponder in
			guard isFirstResponder,
				  let self = self,
				  let footerView = self.footerView else { return }
			// calculate the offset needed to push up scrollview
			// because we use that special footerView - calculation ist based in it
			// otherwise we should have used the keyboard frame
			DispatchQueue.main.async {
				let footerViewRect = footerView.convert(footerView.bounds, to: self.scrollView)
				if footerViewRect.intersects(self.stackView.frame) {
					Log.debug("we need to scroll TanInputView a little bit up - it got hidden")
					let delta = footerViewRect.height - (self.stackView.frame.origin.y + self.stackView.frame.size.height) + self.scrollView.contentOffset.y
					let bottomOffset = CGPoint(x: 0, y: delta)
					self.scrollView.setContentOffset(bottomOffset, animated: true)
				}
			}
		}.store(in: &bindings)
	}

}
