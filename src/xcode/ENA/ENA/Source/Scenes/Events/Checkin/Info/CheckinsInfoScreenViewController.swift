////
// 🦠 Corona-Warn-App
//

import Foundation
import UIKit

class CheckinsInfoScreenViewController: DynamicTableViewController, FooterViewHandling, DismissHandling {

	// MARK: - Init
	
	init(
		viewModel: CheckInsInfoScreenViewModel,
		store: Store,
		onDemand: Bool,
		onDismiss: @escaping (_ animated: Bool) -> Void
	) {
		self.viewModel = viewModel
		self.store = store
		self.onDemand = onDemand
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
			navigationItem.rightBarButtonItem = dismissHandlingCloseBarButton
		}

		navigationItem.title = AppStrings.Checkins.Information.title
		navigationController?.navigationBar.prefersLargeTitles = true
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		if store.checkinInfoScreenShown && !onDemand {
			onDismiss(false)
		}
	}

	// MARK: - Protocol DismissHandling

	func wasAttemptedToBeDismissed() {
		onDismiss(true)
	}

	// MARK: - Protocol FooterViewHandling

	func didTapFooterViewButton(_ type: FooterViewModel.ButtonType) {
		if type == .primary {
			onDismiss(true)
		}
	}

	// MARK: - Internal
	
	private enum ReuseIdentifiers: String, TableViewCellReuseIdentifiers {
		case legalExtended = "DynamicLegalExtendedCell"
	}
	
	// MARK: - Private

	private let viewModel: CheckInsInfoScreenViewModel
	private let store: Store
	private let onDemand: Bool
	private let onDismiss: (_ animated: Bool) -> Void

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
