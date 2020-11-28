//
// 🦠 Corona-Warn-App
//

import UIKit

class TanInputViewController: UIViewController, ENANavigationControllerWithFooterChild, ENATanInputDelegate {

	// MARK: - Init

	init(
		coordinator: ExposureSubmissionCoordinating,
		exposureSubmissionService: ExposureSubmissionService
	) {
		self.coordinator = coordinator
		self.exposureSubmissionService = exposureSubmissionService
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Overrides
	
	override func viewDidLoad() {
		super.viewDidLoad()

		navigationItem.title = AppStrings.ExposureSubmissionTanEntry.title

		navigationFooterItem?.primaryButtonTitle = AppStrings.ExposureSubmissionTanEntry.submit
		navigationFooterItem?.isPrimaryButtonEnabled = false

		descriptionLabel.text = AppStrings.ExposureSubmissionTanEntry.description
		errorView.alpha = 0
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		if let tan = initialTan {
			tanInput.clear()
			tanInput.insertText(tan)
			initialTan = nil
		} else {
			DispatchQueue.main.async {
				self.tanInput.becomeFirstResponder()
			}
		}
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		tanInput.resignFirstResponder()
	}
	
	// MARK: - Protocol ENANavigationControllerWithFooterChild
	
	func navigationController(_ navigationController: ENANavigationControllerWithFooter, didTapPrimaryButton button: UIButton) {
		tanInput.resignFirstResponder()
		submitTan()
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
		return submitTan()
	}

	// MARK: - Public
	
	// MARK: - Internal

	var initialTan: String?
	
	@discardableResult
	func submitTan() -> Bool {
		guard tanInput.isValid && tanInput.isChecksumValid else { return false }

		navigationFooterItem?.isPrimaryButtonLoading = true
		navigationFooterItem?.isPrimaryButtonEnabled = false

		// If teleTAN is correct, show Alert Controller
		// to check permissions to request TAN.
		let teleTan = tanInput.text

		exposureSubmissionService?.getRegistrationToken(forKey: .teleTan(teleTan)) { result in

			switch result {
			case let .failure(error):

				let alert = self.setupErrorAlert(
					message: error.localizedDescription,
					completion: {
						self.navigationFooterItem?.isPrimaryButtonLoading = false
						self.navigationFooterItem?.isPrimaryButtonEnabled = true
						self.tanInput.becomeFirstResponder()
					}
				)
				self.present(alert, animated: true, completion: nil)

			case .success:
				// A TAN always indicates a positive test result.
				self.coordinator?.showTestResultScreen(with: .positive)
			}
		}

		return true
	}

	// MARK: - Private
	
	@IBOutlet private var scrollView: UIScrollView!
	@IBOutlet private var contentView: UIView!
	@IBOutlet private var descriptionLabel: UILabel!
	@IBOutlet var errorLabel: UILabel!
	@IBOutlet var errorView: UIView!
	@IBOutlet var tanInput: ENATanInput! { didSet { tanInput.delegate = self } }

	private(set) weak var exposureSubmissionService: ExposureSubmissionService?
	private(set) weak var coordinator: ExposureSubmissionCoordinating?

	// MARK: - Attributes.


	// MARK: - Initializers.

	// MARK: - View lifecycle methods.
}
