//
// 🦠 Corona-Warn-App
//

import UIKit

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
//		descriptionLabel.text = AppStrings.ExposureSubmissionTanEntry.description
//		errorView.alpha = 0
		footerView?.isHidden = false

//		tanInput.delegate = self

		viewModel.togglePrimaryButton = { [weak self] in
			self?.togglePrimaryNavigationButton()
		}
	}
	
	override var navigationItem: UINavigationItem {
		navigationFooterItem
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		DispatchQueue.main.async { [weak self] in
			self?.tanInputView.becomeFirstResponder()
//			self?.tanInput.becomeFirstResponder()
		}
	}

//

	// MARK: - Protocol ENANavigationControllerWithFooterChild
	
	func navigationController(_ navigationController: ENANavigationControllerWithFooter, didTapPrimaryButton button: UIButton) {
		tanInput.resignFirstResponder()
		viewModel.submitTan(tanInput.text)
	}
	
	// MARK: - Protocol ENATanInputDelegate

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
	
	let viewModel: TanInputViewModel

	func togglePrimaryNavigationButton() {
		navigationFooterItem?.isPrimaryButtonLoading.toggle()
		navigationFooterItem?.isPrimaryButtonEnabled.toggle()
	}

	// MARK: - Private
	
	@IBOutlet private var scrollView: UIScrollView!
	@IBOutlet private var contentView: UIView!
	@IBOutlet private var descriptionLabel: UILabel!
	@IBOutlet var errorLabel: UILabel!
	@IBOutlet var errorView: UIView!
	@IBOutlet var tanInput: ENATanInput!

	private lazy var tanInputView: TanInputView = {
		let tanInputView = TanInputView(frame: .zero, viewModel: viewModel)
		tanInputView.isUserInteractionEnabled = true
		tanInputView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(tanInputView)

		NSLayoutConstraint.activate([
			tanInputView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			tanInputView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
//			tanInputView.heightAnchor.constraint(equalToConstant: 50.0),
			tanInputView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			tanInputView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
		])
		return tanInputView
	}()

	private lazy var navigationFooterItem: ENANavigationFooterItem = {
		let item = ENANavigationFooterItem()
		item.primaryButtonTitle = AppStrings.ExposureSubmissionTanEntry.submit
		item.isPrimaryButtonEnabled = false
		item.isSecondaryButtonHidden = true
		item.title = AppStrings.ExposureSubmissionTanEntry.title
		return item
	}()

}
