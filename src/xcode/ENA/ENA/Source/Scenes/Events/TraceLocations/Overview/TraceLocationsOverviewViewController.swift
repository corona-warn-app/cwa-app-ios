//
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

class TraceLocationsOverviewViewController: UITableViewController, FooterViewHandling {

	// MARK: - Init

	init(
		viewModel: TraceLocationsOverviewViewModel,
		onInfoButtonTap: @escaping () -> Void,
		onOnBehalfCheckinSubmissionTap: @escaping () -> Void,
		onAddEntryCellTap: @escaping () -> Void
	) {
		self.viewModel = viewModel
		self.onInfoButtonTap = onInfoButtonTap
		self.onOnBehalfCheckinSubmissionTap = onOnBehalfCheckinSubmissionTap
		self.onAddEntryCellTap = onAddEntryCellTap

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
		footerView?.setBackgroundColor(.enaColor(for: .darkBackground))

		setupTableView()
		navigationItem.largeTitleDisplayMode = .always
		navigationItem.title = AppStrings.TraceLocations.Overview.title
		updateRightBarButtonItem(isEditing: false)

		viewModel.$traceLocations
			.receive(on: DispatchQueue.main.ocombine)
			.sink { [weak self] _ in
				guard let self = self, self.shouldReload else { return }

				self.tableView.reloadData()
				self.updateEmptyState()
			}
			.store(in: &subscriptions)
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
	
	override func setEditing(_ editing: Bool, animated: Bool) {
		super.setEditing(editing, animated: animated)

		// Only reset to false because it is also set to true for single-row swipe to delete and we don't want to enter edit mode then.
		if editing == false {
			updateFor(isEditing: false)
		}
	}

	// MARK: - FooterViewHandling

	func didTapFooterViewButton(_ type: FooterViewModel.ButtonType) {
		if type == .primary {
			didTapDeleteAllButton()
		}
	}

	// MARK: - Protocol UITableViewDataSource

	override func numberOfSections(in tableView: UITableView) -> Int {
		return viewModel.numberOfSections
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return viewModel.numberOfRows(in: section)
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch TraceLocationsOverviewViewModel.Section(rawValue: indexPath.section) {
		case .add:
			return traceLocationAddCell(forRowAt: indexPath)
		case .entries:
			return traceLocationCell(forRowAt: indexPath)
		case .none:
			fatalError("Invalid section")
		}
	}

	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		viewModel.canEditRow(at: indexPath)
	}

	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		guard editingStyle == .delete else { return }

		showAlert(
			title: AppStrings.TraceLocations.Overview.DeleteOneAlert.title,
			message: AppStrings.TraceLocations.Overview.DeleteOneAlert.message,
			cancelButtonTitle: AppStrings.TraceLocations.Overview.DeleteOneAlert.cancelButtonTitle,
			confirmButtonTitle: AppStrings.TraceLocations.Overview.DeleteOneAlert.confirmButtonTitle,
			confirmAction: { [weak self] in
				guard let self = self else { return }

				self.shouldReload = false
				self.viewModel.removeEntry(at: indexPath)
				tableView.performBatchUpdates({
					tableView.deleteRows(at: [indexPath], with: .automatic)
				}, completion: { _ in
					self.shouldReload = true

					if self.viewModel.isEmpty {
						self.setEditing(false, animated: true)
						self.updateEmptyState()
					}
				})
			}
		)
	}

	// MARK: - Protocol UITableViewDelegate

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		switch TraceLocationsOverviewViewModel.Section(rawValue: indexPath.section) {
		case .add:
			onAddEntryCellTap()
		case .entries:
			viewModel.didTapEntryCell(at: indexPath)
		case .none:
			fatalError("Invalid section")
		}
	}

	// MARK: - Private

	private let viewModel: TraceLocationsOverviewViewModel
	private let onInfoButtonTap: () -> Void
	private let onOnBehalfCheckinSubmissionTap: () -> Void
	private let onAddEntryCellTap: () -> Void

	private var subscriptions = [AnyCancellable]()

	private var shouldReload = true
	private var addEntryCellModel = AddTraceLocationCellModel()

	private func setupTableView() {
		tableView.register(
			UINib(nibName: String(describing: AddButtonAsTableViewCell.self), bundle: nil),
			forCellReuseIdentifier: String(describing: AddButtonAsTableViewCell.self)
		)

		tableView.register(
			UINib(nibName: String(describing: EventTableViewCell.self), bundle: nil),
			forCellReuseIdentifier: String(describing: EventTableViewCell.self)
		)

		tableView.separatorStyle = .none
		tableView.rowHeight = UITableView.automaticDimension
		tableView.estimatedRowHeight = 60
		tableView.accessibilityIdentifier = AccessibilityIdentifiers.TraceLocation.Overview.tableView
	}

	private func animateChanges(of cell: UITableViewCell) {
		DispatchQueue.main.async { [self] in
			guard tableView.visibleCells.contains(cell) else {
				return
			}

			tableView.performBatchUpdates(nil, completion: nil)
		}
	}

	private func updateFor(isEditing: Bool) {
		updateRightBarButtonItem(isEditing: isEditing)
		addEntryCellModel.setEnabled(!isEditing)

		let newState: FooterViewModel.VisibleButtons = isEditing ? .primary : .none
		footerView?.update(to: newState)
	}

	private func updateRightBarButtonItem(isEditing: Bool) {
		// Only update if necessary to prevent unnecessary animations
		if isEditing && navigationItem.rightBarButtonItem != editButtonItem {
			navigationItem.setRightBarButton(editButtonItem, animated: true)
		} else if navigationItem.rightBarButtonItem == nil || navigationItem.rightBarButtonItem == editButtonItem {
			let barButtonItem = UIBarButtonItem(
				image: UIImage(named: "Icons_More_Circle"),
				style: .plain,
				target: self,
				action: #selector(didTapMoreButton)
			)
			barButtonItem.accessibilityLabel = AppStrings.TraceLocations.Overview.menuButtonTitle
			barButtonItem.accessibilityIdentifier = AccessibilityIdentifiers.TraceLocation.Overview.menueButton
			barButtonItem.tintColor = .enaColor(for: .tint)

			navigationItem.setRightBarButton(barButtonItem, animated: true)
		}
	}

	private func traceLocationAddCell(forRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: AddButtonAsTableViewCell.self), for: indexPath) as? AddButtonAsTableViewCell else {
			fatalError("Could not dequeue AddButtonAsTableViewCell")
		}

		cell.configure(cellModel: addEntryCellModel)

		return cell
	}

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
	}

	private func updateEmptyState() {
		// Since we set the empty state view as a background view we need to push it into the visible area by
		// adding the height of the button cell to the safe area (navigation bar and status bar)
		let safeInsetTop = tableView.rectForRow(at: IndexPath(row: 0, section: 0)).maxY + tableView.adjustedContentInset.top
		// If possible, we want to push it to a position that looks good on large and small screens and that is aligned
		// between CheckinsOverviewViewController, TraceLocationsOverviewViewController and HealthCertificateOverviewViewController.
		let alignmentPadding = UIScreen.main.bounds.height / 3
		tableView.backgroundView = viewModel.isEmpty
			? EmptyStateView(
				viewModel: TraceLocationsOverviewEmptyStateViewModel(),
				safeInsetTop: safeInsetTop,
				alignmentPadding: alignmentPadding
			)
			: nil
	}

	@objc
	private func didTapMoreButton() {
		let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

		let infoAction = UIAlertAction(
			title: AppStrings.TraceLocations.Overview.ActionSheet.infoTitle,
			style: .default,
			handler: { [weak self] _ in
				self?.onInfoButtonTap()
			}
		)
		actionSheet.addAction(infoAction)

		let editAction = UIAlertAction(
			title: AppStrings.TraceLocations.Overview.ActionSheet.editTitle,
			style: .default,
			handler: { [weak self] _ in
				self?.setEditing(true, animated: true)
				self?.updateFor(isEditing: true)
			}
		)
		editAction.isEnabled = !viewModel.isEmpty
		actionSheet.addAction(editAction)

		let onBehalfCheckinSubmissionAction = UIAlertAction(
			title: AppStrings.TraceLocations.Overview.ActionSheet.onBehalfCheckinSubmissionTitle,
			style: .default,
			handler: { [weak self] _ in
				self?.onOnBehalfCheckinSubmissionTap()
			}
		)
		actionSheet.addAction(onBehalfCheckinSubmissionAction)

		let cancelAction = UIAlertAction(title: AppStrings.Common.alertActionCancel, style: .cancel)
		actionSheet.addAction(cancelAction)

		present(actionSheet, animated: true, completion: nil)
	}

	private func didTapDeleteAllButton() {
		showAlert(
			title: AppStrings.TraceLocations.Overview.DeleteAllAlert.title,
			message: AppStrings.TraceLocations.Overview.DeleteAllAlert.message,
			cancelButtonTitle: AppStrings.TraceLocations.Overview.DeleteAllAlert.cancelButtonTitle,
			confirmButtonTitle: AppStrings.TraceLocations.Overview.DeleteAllAlert.confirmButtonTitle,
			confirmAction: { [weak self] in
				guard let self = self else { return }

				let numberOfRows = self.viewModel.traceLocations.count

				self.shouldReload = false
				self.viewModel.removeAll()
				self.tableView.performBatchUpdates({
					self.tableView.deleteRows(
						at: (0..<numberOfRows).map {
							IndexPath(row: $0, section: TraceLocationsOverviewViewModel.Section.entries.rawValue)
						},
						with: .automatic
					)
				}, completion: { _ in
					self.shouldReload = true

					self.setEditing(false, animated: true)
					self.updateEmptyState()
				})
			}
		)
	}

	private func showAlert(
		title: String,
		message: String,
		cancelButtonTitle: String,
		confirmButtonTitle: String,
		confirmAction: @escaping () -> Void
	) {
		let alert = UIAlertController(
			title: title,
			message: message,
			preferredStyle: .alert
		)

		alert.addAction(
			UIAlertAction(
				title: cancelButtonTitle,
				style: .cancel
			)
		)

		alert.addAction(
			UIAlertAction(
				title: confirmButtonTitle,
				style: .destructive,
				handler: { _ in
					confirmAction()
				}
			)
		)

		present(alert, animated: true, completion: nil)
	}

}
