//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class TestTypeSelectionViewController: DynamicTableViewController {
	
	// MARK: - Init
	
	init(
		viewModel: TestTypeSelectionViewModel,
		onPrimaryButtonTap: @escaping (SAP_Internal_SubmissionPayload.SubmissionType) -> Void,
		onDismiss: @escaping CompletionVoid
	) {
		self.viewModel = viewModel
		self.onPrimaryButtonTap = onPrimaryButtonTap
		self.onDismiss = onDismiss

		super.init(nibName: nil, bundle: nil)
	}
	
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Overrides

    override func viewDidLoad() {
        super.viewDidLoad()

		setupNavigation()
		setupView()
		setupTableView()
		setupBindings()
    }

	// MARK: - Private
	
	private let viewModel: TestTypeSelectionViewModel
	private let onPrimaryButtonTap: (SAP_Internal_SubmissionPayload.SubmissionType) -> Void
	private let onDismiss: CompletionVoid
	private var subscriptions = Set<AnyCancellable>()
	
	private func setupNavigation() {
		navigationItem.title = "Art des Tests"
		navigationItem.rightBarButtonItem = dismissHandlingCloseBarButton
	}
	
	private func setupView() {
		view.backgroundColor = .enaColor(for: .background)
	}
	
	private func setupTableView() {
		tableView.separatorStyle = .none
		
		tableView.register(
			DynamicTableViewOptionGroupCell.self,
			forCellReuseIdentifier: ExposureSubmissionSymptomsViewController.CustomCellReuseIdentifiers.optionGroupCell.rawValue
		)
		
		dynamicTableViewModel = viewModel.dynamicTableViewModel
	}
	
	private func setupBindings() {
		viewModel.$selectedSubmissionType
			.sink { [weak self] in
				self?.footerView?.setEnabled($0 != nil, button: .primary)
			}
			.store(in: &subscriptions)
	}
	
	private func showWarnProcessCancelAlert() {
		let alert = UIAlertController(
			title: "Warn-Vorgang abbrechen?",
			message: "Sind Sie sich sicher, dass Sie den Warn-Vorgang abbrechen wollen?\n\nWenn Ihr Test positiv war, können Sie mit einer Warnung helfen, Infektionsketten zu unterbrechen.",
			preferredStyle: .alert
		)
		
		alert.addAction(UIAlertAction(
			title: "Warnen fortsetzen",
			style: .default
		))
		
		alert.addAction(UIAlertAction(
			title: "Nicht warnen",
			style: .cancel,
			handler: { [weak self] _ in
				self?.onDismiss()
			}
		))
		
		navigationController?.topViewController?.present(alert, animated: true)
	}
}

extension TestTypeSelectionViewController: FooterViewHandling {

	func didTapFooterViewButton(_ type: FooterViewModel.ButtonType) {
		guard let submissionType = viewModel.selectedSubmissionType else {
			Log.error("\(#function): Primary button must not be enabled before the user has selected an option")
			return
		}
		
		onPrimaryButtonTap(submissionType)
	}
}

extension TestTypeSelectionViewController: DismissHandling {
	
	func wasAttemptedToBeDismissed() {
		showWarnProcessCancelAlert()
	}
}
