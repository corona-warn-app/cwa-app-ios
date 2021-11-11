//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

class FirstTicketValidationConsentViewController: DynamicTableViewController, FooterViewHandling {
	
	// MARK: - Init
	
	init(
		viewModel: FirstTicketValidationConsentViewModel,
		onPrimaryButtonTap: @escaping () -> Void,
		onDismiss: @escaping () -> Void
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
		setupView()
	}

	// MARK: - Protocol FooterViewHandling

	func didTapFooterViewButton(_ type: FooterViewModel.ButtonType) {
		switch type {
		case .primary:
			onPrimaryButtonTap()
		case .secondary:
			onDismiss()
		}
	}
	
	// MARK: - Private

	private let viewModel: FirstTicketValidationConsentViewModel
	private let onPrimaryButtonTap: () -> Void
	private let onDismiss: () -> Void

	private func setupView() {
		navigationItem.rightBarButtonItem = CloseBarButtonItem(
			onTap: { [weak self] in
				self?.onDismiss()
			}
		)

		view.backgroundColor = .enaColor(for: .background)

		dynamicTableViewModel = viewModel.dynamicTableViewModel
		tableView.separatorStyle = .none
	}

}
