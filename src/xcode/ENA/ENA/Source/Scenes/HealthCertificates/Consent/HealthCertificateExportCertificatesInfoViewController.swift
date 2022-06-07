//
// 🦠 Corona-Warn-App
//

import UIKit

class HealthCertificateExportCertificatesInfoViewController: DynamicTableViewController, FooterViewHandling, DismissHandling {
	
	// MARK: - Init
	
	init(
		viewModel: HealthCertificateExportCertificatesInfoViewModel
	) {
		self.viewModel = viewModel
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
		viewModel.onDismiss(true)
	}
	
	// MARK: - Protocol FooterViewHandling

	func didTapFooterViewButton(_ type: FooterViewModel.ButtonType) {
		switch type {
		case .primary:
			viewModel.onNext()
		default: break
		}
	}
	
	// MARK: - Private
	
	private let viewModel: HealthCertificateExportCertificatesInfoViewModel
	
	private func setupView() {
		dynamicTableViewModel = viewModel.dynamicTableViewModel
		view.backgroundColor = .enaColor(for: .background)
		tableView.contentInsetAdjustmentBehavior = .never
		tableView.separatorStyle = .none
		tableView.allowsSelection = false
	}
}
