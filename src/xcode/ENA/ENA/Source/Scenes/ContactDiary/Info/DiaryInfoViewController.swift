//
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

class DiaryInfoViewController: DynamicTableViewController, FooterViewHandling {
	
	// MARK: - Init
	
	init(
		viewModel: DiaryInfoViewModel,
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
	}

	// MARK: - Protocol FooterViewHandling

	func didTapFooterViewButton(_ type: FooterViewModel.ButtonType) {
		onDismiss()
	}
	
	// MARK: - Internal
	
	enum ReuseIdentifiers: String, TableViewCellReuseIdentifiers {
		case legalExtended = "DynamicLegalExtendedCell"
	}
	
	// MARK: - Private

	private let viewModel: DiaryInfoViewModel
	private let onDismiss: () -> Void

	private func setupView() {
		
		parent?.navigationItem.title = AppStrings.ContactDiary.Information.title
		
		if !viewModel.hidesCloseButton {
			parent?.navigationItem.rightBarButtonItem = CloseBarButtonItem(
				onTap: { [weak self] in
					self?.onDismiss()
				}
			)
		}

		parent?.navigationController?.navigationBar.prefersLargeTitles = true
		view.backgroundColor = .enaColor(for: .background)

		tableView.register(
			UINib(nibName: String(describing: DynamicLegalExtendedCell.self), bundle: nil),
			forCellReuseIdentifier: ReuseIdentifiers.legalExtended.rawValue
		)

		dynamicTableViewModel = viewModel.dynamicTableViewModel
		tableView.separatorStyle = .none
	}
}
