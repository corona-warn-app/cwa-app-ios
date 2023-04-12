//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class ExposureSubmissionTestResultViewController: DynamicTableViewController, FooterViewHandling, DismissHandling {

	// MARK: - Init

	init(
		viewModel: ExposureSubmissionTestResultModeling,
		onDismiss: @escaping (TestResult, @escaping (Bool) -> Void) -> Void
	) {
		self.viewModel = viewModel
		self.onDismiss = onDismiss
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		guard #available(iOS 13, *) else {
			navigationController?.navigationBar.backgroundColor = .enaColor(for: .backgroundLightGray)
			navigationController?.navigationBar.barTintColor = .enaColor(for: .backgroundLightGray)
			navigationController?.navigationBar.shadowImage = nil
			
			guard let statusBarView = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else {
				return
			}
			statusBarView.backgroundColor = .enaColor(for: .backgroundLightGray)
			return
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		setUpView()
		setUpBindings()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		viewModel.evaluateShowing()
		viewModel.updateTestResultIfPossible()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		revertStatusBarViewBackgroundColorIfNeeded()
	}
	
	// MARK: - Protocol ENANavigationControllerWithFooterChild
	
	func didTapFooterViewButton(_ type: FooterViewModel.ButtonType) {
		switch type {
		case .primary:
			viewModel.didTapPrimaryButton()
		case .secondary:
			viewModel.didTapSecondaryButton()
		}
	}

	// MARK: - Protocol DismissHandling

	func wasAttemptedToBeDismissed() {
		onDismiss(viewModel.testResult) { [weak self] isLoading in
			DispatchQueue.main.async {
				self?.navigationItem.rightBarButtonItem?.isEnabled = !isLoading
				self?.footerView?.setLoadingIndicator(isLoading, disable: false, button: .primary)
				self?.footerView?.setLoadingIndicator(isLoading, disable: isLoading, button: .secondary)
			}
		}
	}
	
	// MARK: - Private
	
	private let onDismiss: (TestResult, @escaping (Bool) -> Void) -> Void
	private let viewModel: ExposureSubmissionTestResultModeling

	private var bindings: [AnyCancellable] = []

	private func setUpView() {
		navigationController?.navigationBar.backgroundView?.backgroundColor = .enaColor(for: .background)
		navigationItem.rightBarButtonItem = dismissHandlingCloseBarButton
		navigationItem.hidesBackButton = true
		navigationItem.largeTitleDisplayMode = .never
		
		view.backgroundColor = .enaColor(for: .background)

		setUpDynamicTableView()
	}
	
	private func setUpDynamicTableView() {
		tableView.separatorStyle = .none

		tableView.register(
			UINib(nibName: String(describing: ExposureSubmissionTestResultHeaderView.self), bundle: nil),
			forHeaderFooterViewReuseIdentifier: HeaderReuseIdentifier.pcrTestResult.rawValue
		)
		tableView.register(
			HealthCertificateCell.self,
			forCellReuseIdentifier: CustomCellReuseIdentifiers.healthCertificateCell.rawValue
		)
		tableView.register(
			AntigenExposureSubmissionNegativeTestResultHeaderView.self,
			forHeaderFooterViewReuseIdentifier: HeaderReuseIdentifier.antigenTestResult.rawValue
		)
		tableView.register(
			ExposureSubmissionStepCell.self,
			forCellReuseIdentifier: CustomCellReuseIdentifiers.stepCell.rawValue)
	}

	private func setUpBindings() {
		viewModel.dynamicTableViewModelPublisher
			.sink { [weak self] dynamicTableViewModel in
				self?.dynamicTableViewModel = dynamicTableViewModel
				self?.tableView.reloadData()
			}
			.store(in: &bindings)

		viewModel.shouldShowDeletionConfirmationAlertPublisher
			.sink { [weak self] shouldShowDeletionConfirmationAlert in
				guard let self = self, shouldShowDeletionConfirmationAlert else { return }

				self.viewModel.shouldShowDeletionConfirmationAlertPublisher.value = false

				self.showDeletionConfirmationAlert()
			}
			.store(in: &bindings)
		
		viewModel.shouldAttemptToDismissPublisher
			.sink { [weak self] shouldAttemptToDismiss in
				guard let self = self, shouldAttemptToDismiss else { return }
				
				self.viewModel.shouldAttemptToDismissPublisher.value = false
				
				self.wasAttemptedToBeDismissed()
			}
			.store(in: &bindings)

		viewModel.errorPublisher
			.sink { [weak self] error in
				guard let self = self,
					  let error = error,
					  !CWAHibernationProvider.shared.isHibernationState else {
					return
				}

				self.viewModel.errorPublisher.value = nil
				
				let alert = self.setupErrorAlert(message: error.localizedDescription)
				self.present(alert, animated: true)
			}
			.store(in: &bindings)
		
		viewModel.footerViewModelPublisher
			.sink { [weak self] footerViewModel in
				guard let self = self, let footerViewModel = footerViewModel else { return }
				guard let topBottomViewController = self.parent as? TopBottomContainerViewController<ExposureSubmissionTestResultViewController, FooterViewController> else { return }
				
				topBottomViewController.updateFooterViewModel(footerViewModel)
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
			title: AppStrings.ExposureSubmissionResult.removeAlert_ConfirmButtonTitle,
			style: .destructive,
			handler: { [weak self] _ in
				self?.viewModel.deleteTest()
			}
		)
		deleteAction.accessibilityIdentifier = AccessibilityIdentifiers.ExposureSubmissionResult.RemoveAlert.deleteButton
		alert.addAction(deleteAction)
		alert.addAction(cancelAction)

		present(alert, animated: true, completion: nil)
	}

}

// MARK: - Custom HeaderReuseIdentifiers.

extension ExposureSubmissionTestResultViewController {
	enum HeaderReuseIdentifier: String, TableViewHeaderFooterReuseIdentifiers {
		case pcrTestResult = "pcrTestResult"
		case antigenTestResult = "antigenTestResult"
	}
}

// MARK: - Cell reuse identifiers.

extension ExposureSubmissionTestResultViewController {
	enum CustomCellReuseIdentifiers: String, TableViewCellReuseIdentifiers {
		case stepCell
		case healthCertificateCell
	}
}
