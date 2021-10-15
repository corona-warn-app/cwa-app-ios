//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class OnBehalfDateTimeSelectionViewController: DynamicTableViewController, FooterViewHandling, DismissHandling {

	// MARK: - Init

	init(
		traceLocation: TraceLocation,
		onPrimaryButtonTap: @escaping (Checkin) -> Void,
		onDismiss: @escaping () -> Void
	) {
		self.onDismiss = onDismiss

		self.viewModel = OnBehalfDateTimeSelectionViewModel(
			traceLocation: traceLocation,
			onPrimaryButtonTap: onPrimaryButtonTap
		)

		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()

		navigationItem.rightBarButtonItems = [dismissHandlingCloseBarButton(.normal)]
		navigationItem.title = AppStrings.OnBehalfCheckinSubmission.DateTimeSelection.title

		setupTableView()

		view.backgroundColor = .enaColor(for: .background)
	}

	// MARK: - Protocol FooterViewHandling

	func didTapFooterViewButton(_ type: FooterViewModel.ButtonType) {
		guard type == .primary else { return }

		viewModel.createCheckin()
	}

	// MARK: - Protocol DismissHandling

	func wasAttemptedToBeDismissed() {
		onDismiss()
	}

	// MARK: - Private

	private let onDismiss: () -> Void

	private let viewModel: OnBehalfDateTimeSelectionViewModel
	private var subscriptions = Set<AnyCancellable>()

	private func setupTableView() {
		tableView.separatorStyle = .none
		dynamicTableViewModel = viewModel.dynamicTableViewModel

		tableView.register(
			UINib(nibName: String(describing: EventTableViewCell.self), bundle: nil),
			forCellReuseIdentifier: EventTableViewCell.reuseIdentifier
		)

		tableView.register(
			OnBehalfDateSelectionCell.self,
			forCellReuseIdentifier: OnBehalfDateSelectionCell.reuseIdentifier
		)

		tableView.register(
			OnBehalfDurationSelectionCell.self,
			forCellReuseIdentifier: OnBehalfDurationSelectionCell.reuseIdentifier
		)
	}

}
