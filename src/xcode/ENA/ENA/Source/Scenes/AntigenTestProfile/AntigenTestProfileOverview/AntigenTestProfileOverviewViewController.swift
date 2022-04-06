//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class AntigenTestProfileOverviewViewController: UITableViewController, DismissHandling {

	// MARK: - Init

	init(
		viewModel: AntigenTestProfileOverviewViewModel,
		onInfoButtonTap: @escaping () -> Void,
		onAddEntryCellTap: @escaping () -> Void,
		onDismiss: @escaping () -> Void
	) {
		self.viewModel = viewModel
		self.onInfoButtonTap = onInfoButtonTap
		self.onAddEntryCellTap = onAddEntryCellTap
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

		view.backgroundColor = .enaColor(for: .darkBackground)

		setupBarButtonItems()
		setupTableView()
		navigationItem.largeTitleDisplayMode = .always
		navigationItem.title = AppStrings.AntigenProfile.Overview.title

		/*
		viewModel.$traceLocations
			.receive(on: DispatchQueue.main.ocombine)
			.sink { [weak self] _ in
				guard let self = self, self.shouldReload else { return }

				self.tableView.reloadData()
				self.updateEmptyState()
			}
			.store(in: &subscriptions)
		 */
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		parent?.navigationController?.navigationBar.prefersLargeTitles = true
		parent?.navigationController?.navigationBar.sizeToFit()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		updateEmptyState()
	}

	// MARK: - Protocol UITableViewDataSource

	override func numberOfSections(in tableView: UITableView) -> Int {
		return viewModel.numberOfSections
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return viewModel.numberOfRows(in: section)
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch AntigenTestProfileOverviewViewModel.Section(rawValue: indexPath.section) {
		case .add:
			return antigenTestProfileAddCell(forRowAt: indexPath)
		/*
		case .entries: break
			return traceLocationCell(forRowAt: indexPath)
	    */
		case .none:
			fatalError("Invalid section")
		}
	}

	// MARK: - Protocol UITableViewDelegate

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		switch AntigenTestProfileOverviewViewModel.Section(rawValue: indexPath.section) {
		case .add:
			onAddEntryCellTap()
		/*
		case .entries:
			viewModel.didTapEntryCell(at: indexPath)
		*/
		case .none:
			fatalError("Invalid section")
		}
	}

	// MARK: - Protocol DismissHandling

	func wasAttemptedToBeDismissed() {
		onDismiss()
	}
	
	// MARK: - Private

	private let viewModel: AntigenTestProfileOverviewViewModel
	private let onInfoButtonTap: () -> Void
	private let onAddEntryCellTap: () -> Void
	private let onDismiss: () -> Void

	private var subscriptions = [AnyCancellable]()

	private var shouldReload = true
	private var addEntryCellModel = AddAntigenTestProfileCellModel()

	private func setupBarButtonItems() {
		let infoButton = UIButton(type: .infoLight)
		infoButton.addTarget(self, action: #selector(infoButtonTapped), for: .touchUpInside)
		navigationItem.rightBarButtonItems = [dismissHandlingCloseBarButton, UIBarButtonItem(customView: infoButton)]
		/*
		navigationItem.rightBarButtonItem?.isAccessibilityElement = true
		navigationItem.rightBarButtonItem?.accessibilityLabel = AppStrings.Home.rightBarButtonDescription
		navigationItem.rightBarButtonItem?.accessibilityIdentifier = AccessibilityIdentifiers.Home.rightBarButtonDescription
		 */
	}
	
	private func setupTableView() {
		tableView.register(
			UINib(nibName: String(describing: AddButtonAsTableViewCell.self), bundle: nil),
			forCellReuseIdentifier: String(describing: AddButtonAsTableViewCell.self)
		)

		/*
		tableView.register(
			UINib(nibName: String(describing: EventTableViewCell.self), bundle: nil),
			forCellReuseIdentifier: String(describing: EventTableViewCell.self)
		)*/

		tableView.separatorStyle = .none
		tableView.rowHeight = UITableView.automaticDimension
		tableView.estimatedRowHeight = 60
		tableView.accessibilityIdentifier = AccessibilityIdentifiers.AntigenProfile.Overview.tableView
	}

	private func animateChanges(of cell: UITableViewCell) {
		DispatchQueue.main.async { [self] in
			guard tableView.visibleCells.contains(cell) else {
				return
			}

			tableView.performBatchUpdates(nil, completion: nil)
		}
	}

	private func antigenTestProfileAddCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: AddButtonAsTableViewCell.self), for: indexPath) as? AddButtonAsTableViewCell else {
			fatalError("Could not dequeue AddButtonAsTableViewCell")
		}

		cell.configure(cellModel: addEntryCellModel)

		return cell
	}

	/*
	private func traceLocationCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: EventTableViewCell.self), for: indexPath) as? EventTableViewCell else {
			fatalError("Could not dequeue EventTableViewCell")
		}

		let cellModel = viewModel.traceLocationCellModel(
			at: indexPath,
			onUpdate: { [weak self] in
				self?.animateChanges(of: cell)
			}
		)
		cell.configure(
			cellModel: cellModel,
			onButtonTap: { [weak self] in
				guard let self = self,
					  let currentIndexPath = self.tableView.indexPath(for: cell) else {
					return
				}
				self.viewModel.didTapEntryCellButton(at: currentIndexPath)
			}
		)

		return cell
	}*/

	private func updateEmptyState() {
		// Since we set the empty state view as a background view we need to push it into the visible area by
		// adding the height of the button cell to the safe area (navigation bar and status bar)
		let safeInsetTop = tableView.rectForRow(at: IndexPath(row: 0, section: 0)).maxY + tableView.adjustedContentInset.top
		// If possible, we want to push it to a position that looks good on large and small screens and that is aligned
		// between CheckinsOverviewViewController, TraceLocationsOverviewViewController and HealthCertificateOverviewViewController.
		let alignmentPadding = UIScreen.main.bounds.height / 3
		tableView.backgroundView = viewModel.isEmpty
			? EmptyStateView(
				viewModel: AntigenTestProfileOverviewEmptyStateViewModel(),
				safeInsetTop: safeInsetTop,
				alignmentPadding: alignmentPadding
			)
			: nil
	}

	@objc
	private func infoButtonTapped() {
		onInfoButtonTap()
	}
}
