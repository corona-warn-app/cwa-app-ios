//
// 🦠 Corona-Warn-App
//

import UIKit
import Combine

class ExposureSubmissionTestResultConsentViewController: DynamicTableViewController, ENANavigationControllerWithFooterChild {
	
	
	// MARK: - Init
	
	init(exposureSubmissionService: ExposureSubmissionService) {
				
		self.viewModel = ExposureSubmissionTestResultConsentViewModel(exposureSubmissionService: exposureSubmissionService)
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
	
	override var navigationItem: UINavigationItem {
		navigationFooterItem
	}

	// MARK: - Private
	
	private let viewModel: ExposureSubmissionTestResultConsentViewModel
	private lazy var navigationFooterItem: ENANavigationFooterItem = {
		let item = ENANavigationFooterItem()
		
		item.primaryButtonTitle = AppStrings.ExposureSubmissionQRInfo.primaryButtonTitle
		item.isPrimaryButtonEnabled = true
		item.isSecondaryButtonHidden = true
		
		item.title = AppStrings.AutomaticSharingConsent.consentTitle
		
		return item
	}()
	
	private func setupView() {
		view.backgroundColor = .enaColor(for: .background)
		cellBackgroundColor = .clear
		
		dynamicTableViewModel = viewModel.dynamicTableViewModel
		tableView.separatorStyle = .none
		
		tableView.register(
			DynamicTableViewConsentCell.self,
			forCellReuseIdentifier: CustomCellReuseIdentifiers.consentCell.rawValue
		)

		
	}
	
}

extension ExposureSubmissionTestResultConsentViewController {
	enum CustomCellReuseIdentifiers: String, TableViewCellReuseIdentifiers {
		case consentCell
	}
}
