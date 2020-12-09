//
// 🦠 Corona-Warn-App
//

import UIKit
import Combine

class ExposureSubmissionTestResultConsentViewController: DynamicTableViewController, DismissHandling {

	// MARK: - Init
	
	init(
		viewModel: ExposureSubmissionTestResultConsentViewModel
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
		self.title = AppStrings.AutomaticSharingConsent.consentTitle
		self.navigationController?.navigationItem.rightBarButtonItem = nil
		setupView()
	}

	// MARK: - Protocol DismissHandling

	func wasAttemptedToBeDismissed() {
		viewModel.onDismiss?()
	}

	// MARK: - Internal

	enum CustomCellReuseIdentifiers: String, TableViewCellReuseIdentifiers {
		case consentCell = "ConsentCellReuseIdentifier"
	}

	// MARK: - Private
	
	private let viewModel: ExposureSubmissionTestResultConsentViewModel
		
	private func setupView() {
		view.backgroundColor = .enaColor(for: .background)
		
		dynamicTableViewModel = viewModel.dynamicTableViewModel
		tableView.separatorStyle = .none
		hidesBottomBarWhenPushed = true
		
		tableView.register(
			DynamicTableViewConsentCell.self,
			forCellReuseIdentifier: CustomCellReuseIdentifiers.consentCell.rawValue
		)
	}
}
