//
// 🦠 Corona-Warn-App
//

import UIKit

class SRSConsentViewController: DynamicTableViewController, FooterViewHandling {
	
	// MARK: - Init
	
	init(
		viewModel: SRSConsentViewModel,
		onPrimaryButtonTap: @escaping (@escaping (Bool) -> Void) -> Void,
		dismiss: @escaping () -> Void
	) {
		self.viewModel = viewModel
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
		
		viewModel.refreshTableView = { [weak self] in
			guard let self = self else { return }
			self.dynamicTableViewModel = self.viewModel.dynamicTableViewModel

			DispatchQueue.main.async { [weak self] in
				self?.tableView.reloadData()
			}
		}
	}
	
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		
		dynamicTableViewModel = viewModel.dynamicTableViewModel
	}

	// MARK: - Protocol FooterViewHandling

	func didTapFooterViewButton(_ type: FooterViewModel.ButtonType) {
		switch type {
		case .primary:
			onPrimaryButtonTap { [weak self] isLoading in
				DispatchQueue.main.async {
					self?.footerView?.setLoadingIndicator(isLoading, disable: isLoading, button: .primary)
				}
			}
		case .secondary:
			dismiss()
		}
	}

	// MARK: - Private

	private let viewModel: SRSConsentViewModel
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
			UINib(nibName: String(describing: DynamicLegalExtendedCell.self), bundle: nil),
			forCellReuseIdentifier: DynamicLegalExtendedCell.reuseIdentifier
		)

		dynamicTableViewModel = viewModel.dynamicTableViewModel
		tableView.separatorStyle = .none
	}
}
