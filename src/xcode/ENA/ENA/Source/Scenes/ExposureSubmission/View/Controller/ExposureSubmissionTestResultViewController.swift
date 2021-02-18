//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class ExposureSubmissionTestResultViewController: DynamicTableViewController, ENANavigationControllerWithFooterChild, DismissHandling {

	// MARK: - Init

	init(
		viewModel: ExposureSubmissionTestResultViewModel,
		exposureSubmissionService: ExposureSubmissionService,
		onDismiss: @escaping (TestResult, @escaping (Bool) -> Void) -> Void
	) {
		self.viewModel = viewModel
		self.exposureSubmissionService = exposureSubmissionService
		self.onDismiss = onDismiss

		super.init(nibName: nil, bundle: nil)
		navigationItem.rightBarButtonItem = dismissHandlingCloseBarButton
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()

		setUpView()
		setUpBindings()
		
		footerView?.primaryButton?.accessibilityIdentifier = AccessibilityIdentifiers.ExposureSubmission.primaryButton
		footerView?.secondaryButton?.accessibilityIdentifier = AccessibilityIdentifiers.ExposureSubmission.secondaryButton
		footerView?.isHidden = false
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		viewModel.updateWarnOthers()
	}

	override var navigationItem: UINavigationItem {
		viewModel.navigationFooterItem
	}
	
	// MARK: - Protocol ENANavigationControllerWithFooterChild

	func navigationController(_ navigationController: ENANavigationControllerWithFooter, didTapPrimaryButton button: UIButton) {
		viewModel.didTapPrimaryButton()
	}

	func navigationController(_ navigationController: ENANavigationControllerWithFooter, didTapSecondaryButton button: UIButton) {
		viewModel.didTapSecondaryButton()
	}

	// MARK: - Protocol DismissHandling

	func wasAttemptedToBeDismissed() {
		onDismiss(viewModel.testResult) { [weak self] isLoading in
			DispatchQueue.main.async {
				self?.navigationItem.rightBarButtonItem?.isEnabled = !isLoading
				self?.navigationFooterItem?.isPrimaryButtonEnabled = !isLoading
				self?.navigationFooterItem?.isSecondaryButtonEnabled = !isLoading
				self?.navigationFooterItem?.isSecondaryButtonLoading = isLoading
			}
		}
	}
	
	// MARK: - Private
	
	private let onDismiss: (TestResult, @escaping (Bool) -> Void) -> Void
	private let exposureSubmissionService: ExposureSubmissionService
	private let viewModel: ExposureSubmissionTestResultViewModel

	private var bindings: [AnyCancellable] = []

	private func setUpView() {
		view.backgroundColor = .enaColor(for: .background)

		setUpDynamicTableView()
	}

	private func setUpDynamicTableView() {
		tableView.separatorStyle = .none

		tableView.register(
			UINib(nibName: String(describing: ExposureSubmissionTestResultHeaderView.self), bundle: nil),
			forHeaderFooterViewReuseIdentifier: HeaderReuseIdentifier.testResult.rawValue
		)
		tableView.register(
			ExposureSubmissionStepCell.self,
			forCellReuseIdentifier: CustomCellReuseIdentifiers.stepCell.rawValue)
	}

	private func setUpBindings() {
		viewModel.$dynamicTableViewModel
			.sink { [weak self] dynamicTableViewModel in
				self?.dynamicTableViewModel = dynamicTableViewModel
				self?.tableView.reloadData()
			}
			.store(in: &bindings)

		viewModel.$shouldShowDeletionConfirmationAlert
			.sink { [weak self] shouldShowDeletionConfirmationAlert in
				guard let self = self, shouldShowDeletionConfirmationAlert else { return }

				self.viewModel.shouldShowDeletionConfirmationAlert = false

				self.showDeletionConfirmationAlert()
			}
			.store(in: &bindings)
		
		viewModel.$shouldAttemptToDismiss
			.sink { [weak self] shouldAttemptToDismiss in
				guard let self = self, shouldAttemptToDismiss else { return }
				
				self.viewModel.shouldAttemptToDismiss = false
				
				self.wasAttemptedToBeDismissed()
			}
			.store(in: &bindings)

		viewModel.$error
			.sink { [weak self] error in
				guard let self = self, let error = error else { return }

				self.viewModel.error = nil

				let alert = self.setupErrorAlert(message: error.localizedDescription)
				self.present(alert, animated: true)
			}
			.store(in: &bindings)
	}

	private func showDeletionConfirmationAlert() {
		let alert = UIAlertController(
			title: AppStrings.ExposureSubmissionResult.removeAlert_Title,
			message: AppStrings.ExposureSubmissionResult.removeAlert_Text,
			preferredStyle: .alert
		)

		let cancelAction = UIAlertAction(
			title: AppStrings.Common.alertActionCancel,
			style: .cancel,
			handler: { _ in
				alert.dismiss(animated: true)
			}
		)

		let deleteAction = UIAlertAction(
			title: AppStrings.Common.alertActionRemove,
			style: .destructive,
			handler: { [weak self] _ in
				self?.viewModel.deleteTest()
			}
		)

		alert.addAction(deleteAction)
		alert.addAction(cancelAction)

		present(alert, animated: true, completion: nil)
	}

}

// MARK: - Custom HeaderReuseIdentifiers.

extension ExposureSubmissionTestResultViewController {
	enum HeaderReuseIdentifier: String, TableViewHeaderFooterReuseIdentifiers {
		case testResult = "testResultCell"
	}
}

// MARK: - Cell reuse identifiers.

extension ExposureSubmissionTestResultViewController {
	enum CustomCellReuseIdentifiers: String, TableViewCellReuseIdentifiers {
		case stepCell
	}
}
