//
// Corona-Warn-App
//
// SAP SE and all other contributors
// copyright owners license this file to you under the Apache
// License, Version 2.0 (the "License"); you may not use this
// file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.
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
		
		item.isPrimaryButtonHidden = true
		
		item.primaryButtonTitle = AppStrings.ExposureSubmissionQRInfo.primaryButtonTitle
		item.isPrimaryButtonEnabled = false
		item.isSecondaryButtonHidden = false
		
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
