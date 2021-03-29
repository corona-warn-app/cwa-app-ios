//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

class ExposureSubmissionQRInfoViewController: DynamicTableViewController, FooterViewHandling {
	
	// MARK: - Init
	
	init(
		supportedCountries: [Country],
		onPrimaryButtonTap: @escaping (@escaping (Bool) -> Void) -> Void,
		dismiss: @escaping () -> Void
	) {
		self.viewModel = ExposureSubmissionQRInfoViewModel(supportedCountries: supportedCountries)
		self.onPrimaryButtonTap = onPrimaryButtonTap
		self.dismiss = dismiss
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

	// MARK: - Protocol FooterViewHandling

	func didTapFooterViewButton(_ type: FooterViewModel.ButtonType) {
		onPrimaryButtonTap { [weak self] isLoading in
			DispatchQueue.main.async {
				self?.footerView?.setLoadingIndicator(isLoading, disable: isLoading, button: .primary)
			}
		}
	}

	// MARK: - Internal

	enum ReuseIdentifiers: String, TableViewCellReuseIdentifiers {
		case legal = "DynamicLegalCell"
		case countries = "LabeledCountriesCell"
	}

	// MARK: - Private

	private let viewModel: ExposureSubmissionQRInfoViewModel
	private let onPrimaryButtonTap: (@escaping (Bool) -> Void) -> Void
	private let dismiss: () -> Void
	
	private func setupView() {
		
		parent?.navigationItem.title = AppStrings.ExposureSubmissionQRInfo.title
		parent?.navigationItem.rightBarButtonItem = CloseBarButtonItem(onTap: dismiss)
		
		view.backgroundColor = .enaColor(for: .background)

		tableView.register(
			UINib(nibName: String(describing: DynamicLegalCell.self), bundle: nil),
			forCellReuseIdentifier: ReuseIdentifiers.legal.rawValue
		)

		tableView.register(
			UINib(nibName: String(describing: LabeledCountriesCell.self), bundle: nil),
			forCellReuseIdentifier: ReuseIdentifiers.countries.rawValue
		)

		dynamicTableViewModel = viewModel.dynamicTableViewModel
		tableView.separatorStyle = .none
	}
}
