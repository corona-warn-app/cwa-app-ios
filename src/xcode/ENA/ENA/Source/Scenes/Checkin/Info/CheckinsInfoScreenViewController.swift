////
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

class CheckinsInfoScreenViewController: DynamicTableViewController, FooterViewHandling {

	// MARK: - Init
	
	init(
		viewModel: CheckInsInfoScreenViewModel,
		onDismiss: @escaping () -> Void
	) {
		self.viewModel = viewModel
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

		if !viewModel.hidesCloseButton {
			parent?.navigationItem.rightBarButtonItem = CloseBarButtonItem(
				onTap: { [weak self] in
					self?.onDismiss()
				}
			)
		}
		parent?.navigationItem.title = AppStrings.Checkins.Information.title
		navigationController?.navigationBar.prefersLargeTitles = true
	}

	// MARK: - Protocol FooterViewHandling

	func didTapFooterViewButton(_ type: FooterViewModel.ButtonType) {
		if type == .primary {
			onDismiss()
		}
	}

	// MARK: - Internal
	
	private enum ReuseIdentifiers: String, TableViewCellReuseIdentifiers {
		case legalExtended = "DynamicLegalExtendedCell"
	}
	
	// MARK: - Private

	private let viewModel: CheckInsInfoScreenViewModel
	private let onDismiss: () -> Void

	private func setupView() {
		view.backgroundColor = .enaColor(for: .background)

		tableView.register(
			UINib(nibName: String(describing: DynamicLegalExtendedCell.self), bundle: nil),
			forCellReuseIdentifier: ReuseIdentifiers.legalExtended.rawValue
		)

		dynamicTableViewModel = viewModel.dynamicTableViewModel
		tableView.separatorStyle = .none
	}
}
