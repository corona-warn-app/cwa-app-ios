////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class ExposureSubmissionTestCertificateViewController: DynamicTableViewController, DismissHandling, FooterViewHandling {

	// MARK: - Init

	init(
		_ viewModel: ExposureSubmissionTestCertificateViewModel,
		showCancelAlert: @escaping () -> Void,
		didTapPrimaryButton: @escaping (String?, @escaping (Bool) -> Void) -> Void,
		didTapSecondaryButton: @escaping (@escaping (Bool) -> Void) -> Void
	) {
		self.viewModel = viewModel
		self.showCancelAlert = showCancelAlert
		self.didTapPrimaryButton = didTapPrimaryButton
		self.didTapSecondaryButton = didTapSecondaryButton
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

	// MARK: - Protocol DismissHandling

	func wasAttemptedToBeDismissed() {
		showCancelAlert()
	}

	// MARK: FooterViewHandling

	func didTapFooterViewButton(_ type: FooterViewModel.ButtonType) {
		switch type {
		case .primary:
			let dateOfBirthString = viewModel.dateOfBirth.map {
				ISO8601DateFormatter.justLocalDateFormatter.string(from: $0)
			}

			didTapPrimaryButton(dateOfBirthString) { [weak self] isLoading in
				guard let self = self else { return }

				self.footerView?.setLoadingIndicator(isLoading, disable: isLoading ? true : !self.viewModel.isPrimaryButtonEnabled, button: .primary)
				self.footerView?.setLoadingIndicator(false, disable: isLoading, button: .secondary)

				// Required to disable changing the date of birth while loading
				self.tableView.isUserInteractionEnabled = !isLoading

			}
		case .secondary:
			didTapSecondaryButton { [weak self] isLoading in
				guard let self = self else { return }

				self.footerView?.setLoadingIndicator(false, disable: isLoading ? true : !self.viewModel.isPrimaryButtonEnabled, button: .primary)
				self.footerView?.setLoadingIndicator(isLoading, disable: isLoading, button: .secondary)

				// Required to disable changing the date of birth while loading
				self.tableView.isUserInteractionEnabled = !isLoading
			}
		}
	}

	// MARK: - Private

	private let viewModel: ExposureSubmissionTestCertificateViewModel
	private let showCancelAlert: () -> Void
	private let didTapPrimaryButton: (String?, @escaping (Bool) -> Void) -> Void
	private let didTapSecondaryButton: (@escaping (Bool) -> Void) -> Void

	private var subscriptions = Set<AnyCancellable>()

	private func setupView() {
		navigationItem.title = AppStrings.ExposureSubmission.TestCertificate.Info.title
		navigationItem.rightBarButtonItem = dismissHandlingCloseBarButton
		navigationItem.hidesBackButton = true

		view.backgroundColor = .enaColor(for: .background)

		tableView.register(
			UINib(nibName: String(describing: DynamicLegalExtendedCell.self), bundle: nil),
			forCellReuseIdentifier: ExposureSubmissionTestCertificateViewModel.ReuseIdentifiers.legalExtended.rawValue
		)

		tableView.register(
			BirthdayDatePickerCell.self,
			forCellReuseIdentifier: BirthdayDatePickerCell.reuseIdentifier
		)

		dynamicTableViewModel = viewModel.dynamicTableViewModel
		tableView.separatorStyle = .none

		viewModel.$isPrimaryButtonEnabled
			.receive(on: DispatchQueue.main.ocombine)
			.sink { [weak self] isEnabled in
				self?.footerView?.setEnabled(isEnabled, button: .primary)
			}
			.store(in: &subscriptions)

		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapView))
		tapGesture.cancelsTouchesInView = false
		view.addGestureRecognizer(tapGesture)
	}

	@objc
	private func didTapView() {
		view.endEditing(true)
	}

}
