//
// 🦠 Corona-Warn-App
//

import UIKit

class SRSConsentViewController: DynamicTableViewController, FooterViewHandling {
	
	// MARK: - Init
	
	init(
		onPrimaryButtonTap: @escaping (@escaping (Bool) -> Void) -> Void,
		dismiss: @escaping () -> Void
	) {
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
		case legalExtended = "DynamicLegalExtendedCell"
	}

	// MARK: - Private

	private let viewModel = SRSConsentViewModel()
	private let onPrimaryButtonTap: (@escaping (Bool) -> Void) -> Void
	private let dismiss: () -> Void
	
	private func setupView() {
		
		navigationItem.title = AppStrings.SRSConsentScreen.title
		navigationItem.rightBarButtonItem = CloseBarButtonItem(onTap: dismiss)
		
		if traitCollection.userInterfaceStyle == .dark {
			navigationController?.navigationBar.tintColor = .enaColor(for: .textContrast)
		} else {
			navigationController?.navigationBar.tintColor = .enaColor(for: .tint)
		}
		
		view.backgroundColor = .enaColor(for: .background)

		tableView.register(
			DynamicLegalExtendedCell.self,
			forCellReuseIdentifier: DynamicLegalExtendedCell.reuseIdentifier
		)

		dynamicTableViewModel = viewModel.dynamicTableViewModel
		tableView.separatorStyle = .none
	}
}
