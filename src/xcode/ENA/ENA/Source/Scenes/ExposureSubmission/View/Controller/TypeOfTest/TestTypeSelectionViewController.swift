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
		onDismiss: @escaping CompletionBool
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
	private let onDismiss: CompletionBool
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
		onDismiss(true)
	}
}
