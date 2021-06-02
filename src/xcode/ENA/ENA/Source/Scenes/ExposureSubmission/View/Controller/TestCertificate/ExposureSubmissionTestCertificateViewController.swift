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
		didTapPrimaryButton: @escaping (CoronaTestType, String?) -> Void,
		didTapSecondaryButton: @escaping () -> Void
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
			if let date = viewModel.dateOfBirth {
				let dateOfBirthString = ISO8601DateFormatter.justLocalDateFormatter.string(from: date)
				didTapPrimaryButton(viewModel.testType, dateOfBirthString)
			} else {
				didTapPrimaryButton(viewModel.testType, nil)
			}
		case .secondary:
			didTapSecondaryButton()
		}
	}

	// MARK: - Private

	private let viewModel: ExposureSubmissionTestCertificateViewModel
	private let showCancelAlert: () -> Void
	private let didTapPrimaryButton: (CoronaTestType, String?) -> Void
	private let didTapSecondaryButton: () -> Void

	private var subscriptions = Set<AnyCancellable>()

	private func setupView() {
		parent?.navigationItem.title = AppStrings.ExposureSubmission.TestCertificate.Info.title
		parent?.navigationItem.rightBarButtonItem = dismissHandlingCloseBarButton
		parent?.navigationItem.hidesBackButton = true

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
