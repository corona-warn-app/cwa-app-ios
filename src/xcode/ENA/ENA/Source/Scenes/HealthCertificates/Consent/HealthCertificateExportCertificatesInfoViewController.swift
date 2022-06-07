//
// 🦠 Corona-Warn-App
//

import UIKit

class HealthCertificateExportCertificatesInfoViewController: DynamicTableViewController, FooterViewHandling, DismissHandling {
	
	// MARK: - Init
	
	init(
		viewModel: HealthCertificateExportCertificatesInfoViewModel,
		onDismiss: @escaping CompletionBool
	) {
		self.viewModel = viewModel
		self.onDismiss = onDismiss
		
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Overrides
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		if !viewModel.hidesCloseButton {
			navigationItem.rightBarButtonItem = dismissHandlingCloseBarButton
		}
		
		setupView()
	}
	
	// MARK: - Protocol DismissHandling

	func wasAttemptedToBeDismissed() {
		onDismiss(true)
	}
	
	// MARK: - Protocol FooterViewHandling

	func didTapFooterViewButton(_ type: FooterViewModel.ButtonType) {
		// TODO: handle tap footer
		print(#function)
	}
	
	// MARK: - Private
	
	private let viewModel: HealthCertificateExportCertificatesInfoViewModel
	private let onDismiss: CompletionBool
	
	private func setupView() {
		dynamicTableViewModel = viewModel.dynamicTableViewModel
		view.backgroundColor = .enaColor(for: .background)
		tableView.contentInsetAdjustmentBehavior = .never
		tableView.separatorStyle = .none
		tableView.allowsSelection = false
	}
}
