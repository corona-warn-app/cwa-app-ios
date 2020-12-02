//
// 🦠 Corona-Warn-App
//

import UIKit
import Combine

class TanInputViewController: UIViewController, ENANavigationControllerWithFooterChild, ENATanInputDelegate {

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

//		errorView.alpha = 0
		footerView?.isHidden = false

		// disable keyboadr notifications for the moment
//		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeShown(note:)), name: UIResponder.keyboardWillShowNotification, object: nil)

//		viewModel.togglePrimaryButton = { [weak self] onOff in
//			self?.togglePrimaryNavigationButton()
//		}
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
//		viewModel.submitTan(tanInput.text)
	}
	
	// MARK: - Protocol ENATanInputDelegate
/*
	func enaTanInputDidBeginEditing(_ tanInput: ENATanInput) {
		let rect = contentView.convert(tanInput.frame, from: tanInput)
		scrollView.scrollRectToVisible(rect, animated: true)
	}

	func enaTanInput(_ tanInput: ENATanInput, didChange text: String, isValid: Bool, isChecksumValid: Bool, isBlocked: Bool) {
		navigationFooterItem?.isPrimaryButtonEnabled = (isValid && isChecksumValid)

		UIView.animate(withDuration: CATransaction.animationDuration()) {

			var errorTexts = [String]()

			if isValid && !isChecksumValid { errorTexts.append(AppStrings.ExposureSubmissionTanEntry.invalidError) }
			if isBlocked { errorTexts.append(AppStrings.ExposureSubmissionTanEntry.invalidCharacterError) }

			self.errorView.alpha = errorTexts.isEmpty ? 0 : 1
			self.errorLabel.text = errorTexts.joined(separator: "\n\n")

			self.view.layoutIfNeeded()
		}
	}

	func enaTanInputDidTapReturn(_ tanInput: ENATanInput) -> Bool {
//		return submitTan()
		return false
	}

	// MARK: - Public
	
	// MARK: - Internal
*/

	func togglePrimaryNavigationButton() {
		navigationFooterItem?.isPrimaryButtonLoading.toggle()
		navigationFooterItem?.isPrimaryButtonEnabled.toggle()
	}

	// MARK: - Private
	
	private let viewModel: TanInputViewModel
	private var bindings: Set<AnyCancellable> = []

	private var descriptionLabel: UILabel!
	private var tanInputView: TanInputView!
	private var errorLabel: UILabel!

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
		stackView.spacing = 35.0
		stackView.translatesAutoresizingMaskIntoConstraints = false
		scrollView.addSubview(stackView)

		NSLayoutConstraint.activate([
			stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 15.0),
			stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: 15.0),
			stackView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
			stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 15),
			stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
		])

		descriptionLabel = UILabel(frame: .zero)
		descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
		descriptionLabel.text = AppStrings.ExposureSubmissionTanEntry.description
		descriptionLabel.numberOfLines = 0

		tanInputView = TanInputView(frame: .zero, viewModel: viewModel)
		tanInputView.isUserInteractionEnabled = true
		tanInputView.translatesAutoresizingMaskIntoConstraints = false


		errorLabel = UILabel(frame: .zero)
		errorLabel.translatesAutoresizingMaskIntoConstraints = false
		errorLabel.text = "no error yet"
		errorLabel.numberOfLines = 0

		stackView.addArrangedSubview(descriptionLabel)
		stackView.addArrangedSubview(tanInputView)
		stackView.addArrangedSubview(errorLabel)
	}

	private func setupViewModel() {
		viewModel.$text.sink { [weak self] newText in
			Log.debug("Viewmodel did uodate to: \(newText)")
			DispatchQueue.main.async {
				self?.navigationFooterItem?.isPrimaryButtonEnabled = self?.viewModel.isChecksumValid ?? false
			}

		}.store(in: &bindings)
	}

	@objc
	func keyboardWillBeShown(note: Notification) {
		guard let footerView = footerView else { return }
		// calculate the offset needed to push up scrollview
		// because we use that special footerView - calculation ist based in it
		// otherwise we should have used the keyboard frame
		let footerViewRect = footerView.convert(footerView.bounds, to: scrollView)
		if footerViewRect.intersects(stackView.frame) {
			let delta = footerViewRect.height - (stackView.frame.origin.y + stackView.frame.size.height) + scrollView.contentOffset.y
			let bottomOffset = CGPoint(x: 0, y: delta)
			scrollView.setContentOffset(bottomOffset, animated: true)
		}
	}

}
